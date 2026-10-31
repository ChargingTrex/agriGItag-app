/**
 * Tests the Ready lots → Create batch flow against the MSW mock API: share % arithmetic, greyed lots with the
 * reason, the non-GI toggle, create → batch ID page, the second sign-off state, refused-gate reasons, axe.
 * Serves: plan §7.3 P03 acceptance ({100,200,20} → 31.25/62.5/6.25; out-of-GI greyed with tooltip; create → id +
 * QR; threshold → second sign-off state), FR9, FR29, FR60. Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { MOCK_FPO_ID, MOCK_REF_LOT_IDS, MOCK_USER_ID, mockState } from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import { lotBlock, signoffBlock, splitShares, toGrams, type LotOut } from './batchModel';

/**
 * Asserts that axe finds no violations in the rendered page (colour contrast needs layout, absent in jsdom).
 * @param container The RTL container.
 */
async function expectNoAxeViolations(container: HTMLElement): Promise<void> {
  const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
  expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
}

/** Registers the processor the batch is sold to. */
function addProcessor(): void {
  mockState.processors.push({
    id: 'c0000000-0000-7000-8000-000000000001',
    fpo_id: MOCK_FPO_ID,
    name: 'Sattur Spices Pvt Ltd',
    kind: 'company',
    address: null,
    address_line: '',
    fssai_no: null,
    gi_authorised_user_no: null,
  });
}

/**
 * Opens Ready lots, ticks the three reference lots and picks the processor.
 * @param user The user-event instance.
 * @returns The RTL container.
 */
async function tickReferenceBatch(user: ReturnType<typeof userEvent.setup>) {
  const { container } = renderApp('/ready-lots', true);
  await screen.findByRole('table', { name: 'Ready lots' });
  for (const code of ['VSV-0001-L1', 'VSV-0004-L1', 'VSV-0005-L1']) {
    await user.click(screen.getByRole('checkbox', { name: `Tick lot ${code}` }));
  }
  await user.click(screen.getByRole('combobox', { name: 'Processor' }));
  await user.click(await screen.findByRole('option', { name: 'Sattur Spices Pvt Ltd' }));
  return container;
}

describe('splitShares (same rounding as lots_batches/shares.py)', () => {
  it('{100,200,20} → 31.250 / 62.500 / 6.250', () => {
    const pct = splitShares([
      ['a', toGrams('100')],
      ['b', toGrams('200')],
      ['c', toGrams('20')],
    ]);
    expect([...pct.values()]).toEqual(['31.250', '62.500', '6.250']);
  });

  it('{1,1,1}: residual 0.001 goes to the first of the tied largest lots', () => {
    const pct = splitShares([
      ['a', 1000],
      ['b', 1000],
      ['c', 1000],
    ]);
    expect([...pct.values()]).toEqual(['33.334', '33.333', '33.333']);
  });

  it('rounds half to even (1/64 = 1.5625 → 1.562) and still sums to 100', () => {
    const pct = splitShares([
      ['a', 1000],
      ['b', 63000],
    ]);
    expect([...pct.values()]).toEqual(['1.562', '98.438']);
  });
});

describe('lotBlock and signoffBlock', () => {
  const lot = mockState.lots[0] as LotOut;

  it('names every reason a lot cannot be ticked', () => {
    expect(lotBlock(lot, false)).toBeNull();
    expect(lotBlock({ ...lot, status: 'batched' }, false)).toBe('Already in a batch.');
    expect(lotBlock({ ...lot, status: 'drying' }, true)).toMatch(/^Not ready/);
    expect(lotBlock({ ...lot, packed: null }, false)).toMatch(/No packed weight/);
    expect(lotBlock({ ...lot, gi_eligible: false }, false)).toBe(
      'Outside the GI region. It can only go into a non-GI batch.',
    );
    expect(lotBlock({ ...lot, gi_eligible: false }, true)).toBeNull();
  });

  it('lets only another FPO admin sign off', () => {
    const batch = { created_by: 'u1' };
    expect(signoffBlock(batch, 'u2', ['fpo_admin'])).toBeNull();
    expect(signoffBlock(batch, 'u1', ['fpo_admin'])).toMatch(/different FPO admin/);
    expect(signoffBlock(batch, undefined, ['fpo_admin'])).toMatch(/Checking/);
    expect(signoffBlock(batch, 'u2', ['field_officer'])).toMatch(/Only an FPO admin/);
  });
});

describe('Ready lots page', () => {
  it('ticks {100,200,20}: running total 320 kg and shares 31.25/62.5/6.25 %; axe clean; no phone number', async () => {
    addProcessor();
    const user = userEvent.setup();
    const container = await tickReferenceBatch(user);

    expect(screen.getByText('3 lots ticked, total')).toHaveTextContent(
      '3 lots ticked, total 320 kg',
    );
    /**
     * The table row of a lot.
     * @param code Lot code.
     * @returns The row.
     */
    const row = (code: string) => screen.getByRole('row', { name: new RegExp(code) });
    expect(within(row('VSV-0001-L1')).getByText('Muthu Kumar')).toBeInTheDocument();
    expect(row('VSV-0001-L1')).toHaveTextContent('100 kg');
    expect(row('VSV-0001-L1')).toHaveTextContent('31.250 %');
    expect(row('VSV-0004-L1')).toHaveTextContent('62.500 %');
    expect(row('VSV-0005-L1')).toHaveTextContent('6.250 %');
    expect(document.body.textContent).not.toMatch(/\d{10}/);
    await expectNoAxeViolations(container);
  });

  it('greys out-of-GI, held and not-received lots with the reason in a tooltip; non-GI un-greys GI ones', async () => {
    const user = userEvent.setup();
    renderApp('/ready-lots', true);
    await screen.findByRole('table', { name: 'Ready lots' });

    const outOfGi = screen.getByRole('checkbox', {
      name: /^Lot VSV-0006-L1: Outside the GI region/,
    });
    expect(outOfGi).toBeDisabled();
    await user.hover(outOfGi.closest('span[title], span[aria-describedby]') ?? outOfGi);
    expect(await screen.findByRole('tooltip')).toHaveTextContent(
      'Outside the GI region (plot outside the GI region). It can only go into a non-GI batch.',
    );
    const held = screen.getByRole('checkbox', {
      name: /^Lot VSV-0010-L2: On hold: Yield above the ceiling/,
    });
    expect(held).toBeDisabled();
    // P02's hold hook adds the flag name as a secondary hint.
    expect(await screen.findByText('Hold flag: Yield above the ceiling')).toBeInTheDocument();
    expect(screen.getByRole('checkbox', { name: /^Lot VSV-0007-L1: Not ready/ })).toBeDisabled();

    await user.click(screen.getByRole('switch', { name: /Non-GI batch/ }));
    expect(screen.getByRole('checkbox', { name: 'Tick lot VSV-0006-L1' })).toBeEnabled();
    expect(screen.getByRole('checkbox', { name: 'Tick lot VSV-0010-L2' })).toBeEnabled();
    expect(screen.getByRole('checkbox', { name: /^Lot VSV-0007-L1: Not ready/ })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Create non-GI batch' })).toBeDisabled();
    expect(screen.getByText('Tick at least one lot.')).toBeInTheDocument();
  });

  it('create → batch ID page with QR placeholder and shares; a double click makes one batch; axe clean', async () => {
    addProcessor();
    const user = userEvent.setup();
    await tickReferenceBatch(user);
    await user.dblClick(screen.getByRole('button', { name: 'Create batch' }));

    expect(await screen.findByRole('heading', { name: 'Batch FGP000000001' })).toBeInTheDocument();
    expect(mockState.batches).toHaveLength(1);
    const batch = mockState.batches[0];
    expect(batch?.shares.map((s) => s.lot_id)).toEqual([...MOCK_REF_LOT_IDS]);
    expect(screen.getByRole('heading', { name: 'Batch ID and QR' })).toBeInTheDocument();
    expect(screen.getByText(/opens the public page at \/b\/FGP000000001/)).toBeInTheDocument();
    expect(screen.getByText('GI verified')).toBeInTheDocument();
    expect(screen.queryByText(/Waiting for a second admin/)).toBeNull();
    const shares = within(screen.getByRole('table', { name: 'Farmer shares' }));
    expect(await shares.findByText('Muthu Kumar')).toBeInTheDocument();
    expect(shares.getByText('31.250 %')).toBeInTheDocument();
    await expectNoAxeViolations(document.body);
  });

  it('a non-GI batch with an out-of-GI lot is labelled non-GI', async () => {
    addProcessor();
    const user = userEvent.setup();
    renderApp('/ready-lots', true);
    await screen.findByRole('table', { name: 'Ready lots' });
    await user.click(screen.getByRole('switch', { name: /Non-GI batch/ }));
    await user.click(screen.getByRole('checkbox', { name: 'Tick lot VSV-0006-L1' }));
    await user.click(screen.getByRole('combobox', { name: 'Processor' }));
    await user.click(await screen.findByRole('option', { name: 'Sattur Spices Pvt Ltd' }));
    await user.click(screen.getByRole('button', { name: 'Create non-GI batch' }));
    expect(await screen.findByText('Non-GI batch')).toBeInTheDocument();
    expect(mockState.batches[0]?.gi_label_requested).toBe(false);
  });

  it('threshold → waiting for a second admin; the creator cannot sign off, another admin can', async () => {
    addProcessor();
    mockState.features.second_signoff_threshold_kg = 300;
    const user = userEvent.setup();
    await tickReferenceBatch(user);
    expect(screen.getByText(/Above 300 kg: a second FPO admin must sign off/)).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Create batch' }));

    expect(await screen.findByText(/Waiting for a second admin/)).toBeInTheDocument();
    expect(
      await screen.findByText(
        'You created this batch; a different FPO admin must give the second sign-off.',
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Sign off' })).toBeDisabled();

    // A second admin opens the same batch.
    const id = mockState.batches[0]?.id ?? '';
    mockState.userId = 'a0000000-0000-7000-8000-000000000002';
    document.body.innerHTML = '';
    renderApp(`/batches/${id}`, true);
    const signOff = await screen.findByRole('button', { name: 'Sign off' });
    await waitFor(() => {
      expect(signOff).toBeEnabled();
    });
    await user.click(signOff);
    expect(await screen.findByText('Second sign-off recorded.')).toBeInTheDocument();
    expect(mockState.batches[0]?.second_signoff_by).toBe(mockState.userId);
  });

  it('a field officer sees Sign off disabled with the reason', async () => {
    mockState.batches.push(storedBatch());
    mockState.roles = ['field_officer'];
    renderApp('/batches/b0000000-0000-7000-8000-000000000009', true);
    expect(await screen.findByText('Only an FPO admin can sign off a batch.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Sign off' })).toBeDisabled();
  });

  it('a refused sign-off lists the server reason', async () => {
    mockState.batches.push(storedBatch());
    // The creator signs from a stale page: the server refuses with `same_approver`.
    mockState.userId = 'a0000000-0000-7000-8000-000000000002';
    const user = userEvent.setup();
    renderApp('/batches/b0000000-0000-7000-8000-000000000009', true);
    const signOff = await screen.findByRole('button', { name: 'Sign off' });
    await waitFor(() => {
      expect(signOff).toBeEnabled();
    });
    mockState.userId = MOCK_USER_ID;
    await user.click(signOff);
    expect(
      await screen.findByText('The second sign-off must come from another admin.'),
    ).toBeInTheDocument();
  });

  it('shows every reason of a 409 gate_not_met as a list', async () => {
    addProcessor();
    server.use(
      http.post('/v1/batches', () =>
        HttpResponse.json(
          {
            error: {
              code: 'gate_not_met',
              message: 'gate_not_met',
              details: {
                reasons: [
                  {
                    code: 'lot_not_received_by_processor',
                    message: 'The lot was received by another processor.',
                  },
                  { code: 'mixed_crops' },
                ],
              },
            },
          },
          { status: 409 },
        ),
      ),
    );
    const user = userEvent.setup();
    await tickReferenceBatch(user);
    await user.click(screen.getByRole('button', { name: 'Create batch' }));
    const list = await screen.findByRole('list', { name: 'Unmet conditions' });
    expect(
      within(list)
        .getAllByRole('listitem')
        .map((li) => li.textContent),
    ).toEqual(['The lot was received by another processor.', 'mixed crops']);
    expect(screen.getByText('The conditions for this step are not met yet.')).toBeInTheDocument();
  });

  it('points to the Processors page when no processor is registered', async () => {
    renderApp('/ready-lots', true);
    expect(await screen.findByRole('link', { name: 'Register a processor first' })).toHaveAttribute(
      'href',
      '/processors',
    );
  });
});

/**
 * A batch above the sign-off weight created by MOCK_USER_ID, for pages that start from an existing batch.
 * @returns The batch.
 */
function storedBatch(): (typeof mockState.batches)[number] {
  return {
    id: 'b0000000-0000-7000-8000-000000000009',
    code: 'FGP8T4033HM7',
    crop_id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
    processor_id: 'c0000000-0000-7000-8000-000000000001',
    created_by: MOCK_USER_ID,
    status: 'created',
    current_build_no: 0,
    gi_label_requested: true,
    gi_verified: false,
    gi_block_reasons: [
      { reason: 'lot_on_hold', lot_id: null, detail: 'flags: yield_over_ceiling' },
    ],
    second_signoff_required: true,
    second_signoff_by: null,
    shares: [],
  };
}
