/**
 * Tests the batch detail and the Batches list against the MSW mock API: Approve greyed with the exact reason
 * (declared above computed, missing reading, not graded, hold flag, role), final packing ≤ graded kg, Publish
 * greyed with every unmet reason, the happy path to a published page (URL, QR, labels, sandboxed preview,
 * builds, Rebuild), a failed build, server 409 reasons as labels, the list's status filter and paging, axe.
 * Serves: plan §7.3 P04 acceptance (declared Special/computed Standard → Approve disabled with reason; missing
 * reading → disabled; happy path → published + URL), FR15, FR48, FR49, FR62. Called by: Vitest (`npm test`).
 */
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import {
  MOCK_INSTRUMENT_ID,
  MOCK_LOT_ID,
  MOCK_OUT_OF_GI_LOT_ID,
  MOCK_PROFILE_VERSION_ID,
  MOCK_USER_ID,
  mockState,
} from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import {
  approveReasons,
  gateReasonText,
  packReasons,
  publishReasons,
  type BatchOut,
  type GradeOut,
} from './batchModel';

const BATCH_ID = 'b0000000-0000-7000-8000-000000000001';
const CODE = 'FGP8T4033HM7';

/**
 * Asserts that axe finds no violations in the rendered page (colour contrast needs layout, absent in jsdom).
 * @param container The element to check.
 */
async function expectNoAxeViolations(container: HTMLElement): Promise<void> {
  // The preview iframe is not loaded in jsdom; axe must not try to message it.
  const result = await axe.run(container, {
    iframes: false,
    rules: { 'color-contrast': { enabled: false } },
  });
  expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
}

/**
 * A created 320 kg GI batch under the sign-off weight, made by MOCK_USER_ID.
 * @param extra Fields to override.
 * @returns The batch.
 */
function batch(extra: Partial<BatchOut> = {}): BatchOut {
  return {
    id: BATCH_ID,
    code: CODE,
    crop_id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
    processor_id: 'c0000000-0000-7000-8000-000000000001',
    created_by: MOCK_USER_ID,
    status: 'created',
    current_build_no: 0,
    gi_label_requested: true,
    gi_verified: true,
    gi_block_reasons: [],
    second_signoff_required: false,
    second_signoff_by: null,
    total_received: { value: '320', unit: 'kg' },
    shares: [],
    ...extra,
  };
}

/**
 * A grade computation of the batch.
 * @param extra Fields to override.
 * @returns The grade.
 */
function grade(extra: Partial<GradeOut> = {}): GradeOut {
  return {
    id: 'g0000000-0000-7000-8000-000000000001',
    batch_id: BATCH_ID,
    computed_at: '2026-10-30T06:00:00Z',
    computed_grade: 'Special',
    declared_grade: 'Special',
    lab_certified: false,
    profile_version_id: MOCK_PROFILE_VERSION_ID,
    status: 'ok',
    per_parameter: {
      moisture: {
        parameter: 'moisture',
        outcome: 'graded',
        grade: 'Special',
        source: 'instrument',
        capped_by_source: false,
        lab_certified: false,
      },
    },
    ...extra,
  };
}

/** Seeds one instrument moisture reading and one visual colour reading on the batch. */
function seedReadings(): void {
  const base = {
    batch_id: BATCH_ID,
    lot_id: null,
    fpo_id: '0b9d6a52-3f7e-4c1a-9a51-6d3c1f0e2a10',
    measured_at: '2026-10-30T05:30:00Z',
    measured_by_user_id: MOCK_USER_ID,
    server_received_at: '2026-10-30T05:31:00Z',
    stage: 'grading',
    calibration_due_on_at_time: null,
    lab_name: null,
    lab_nabl_no: null,
    method_ref: null,
    profile_version_id: MOCK_PROFILE_VERSION_ID,
    reason_code: null,
    sample_id: null,
  } as const;
  mockState.readings.push(
    {
      ...base,
      id: 'r0000000-0000-7000-8000-000000000001',
      parameter_code: 'moisture',
      measurement: { value: '10.2', unit: 'pct' },
      source: 'instrument',
      instrument_id: MOCK_INSTRUMENT_ID,
    },
    {
      ...base,
      id: 'r0000000-0000-7000-8000-000000000002',
      parameter_code: 'colour',
      measurement: { value: '9.8', unit: 'asta' },
      source: 'visual',
      instrument_id: null,
    },
  );
}

/**
 * The Approve button, whatever its accessible name says after the label.
 * @returns The button.
 */
const approveButton = () =>
  // The first render of a cold test file can take longer than the default 5 s on a loaded runner.
  screen.findByRole('button', { name: /^Approve grading/ }, { timeout: 15_000 });

describe('gate previews (mirror of B09 approve_grading, final_packing, publish)', () => {
  it('approve: declared above computed, missing readings, never graded, role and holds', () => {
    const above = grade({
      status: 'declared_above_computed',
      declared_grade: 'Special',
      computed_grade: 'Standard',
    });
    expect(approveReasons(above, true, []).map(gateReasonText)).toEqual([
      'Declared grade Special is above the computed grade Standard: correct the readings, re-test or lower the declared grade.',
    ]);
    const incomplete = grade({
      status: 'incomplete',
      computed_grade: null,
      per_parameter: {
        pungency: {
          parameter: 'pungency',
          outcome: 'missing',
          capped_by_source: false,
          lab_certified: false,
        },
        moisture: {
          parameter: 'moisture',
          outcome: 'missing',
          capped_by_source: false,
          lab_certified: false,
        },
      },
    });
    expect(approveReasons(incomplete, true, []).map(gateReasonText)).toEqual([
      'A required quality reading is missing: moisture, pungency.',
    ]);
    expect(
      approveReasons(null, false, [
        { code: 'open_hold_flag', rule_code: 'yield_over_ceiling' },
      ]).map(gateReasonText),
    ).toEqual([
      'Only an FPO admin can do this.',
      'Not graded yet: the QC officer records the readings and the declared grade first.',
      'Open hold flag: Yield above the ceiling',
    ]);
    expect(approveReasons(grade(), true, [])).toEqual([]);
  });

  it('pack and publish list every unmet reason', () => {
    expect(packReasons({ status: 'created' }, true, []).map((r) => r.code)).toEqual([
      'grading_not_approved',
    ]);
    expect(packReasons({ status: 'graded' }, true, [])).toEqual([]);
    const big = { second_signoff_required: true, second_signoff_by: null };
    expect(publishReasons({ status: 'created', ...big }, false, []).map((r) => r.code)).toEqual([
      'fpo_admin_only',
      'grading_not_approved',
      'final_packing_missing',
      'second_signoff_missing',
    ]);
    expect(publishReasons({ status: 'packed', ...big, second_signoff_by: 'x' }, true, [])).toEqual(
      [],
    );
    expect(
      publishReasons({ status: 'published', ...big, second_signoff_by: 'x' }, true, []).map(
        (r) => r.code,
      ),
    ).toEqual(['already_published']);
  });

  it('labels server reasons with their context, else the server message, else the code', () => {
    expect(gateReasonText({ code: 'packed_above_graded', graded_kg: '300' })).toBe(
      'The packed quantity is above the graded quantity (300 kg).',
    );
    expect(gateReasonText({ code: 'grade_incomplete' })).toBe(
      'A required quality reading is missing.',
    );
    expect(gateReasonText({ code: 'same_approver', message: 'Another admin.' })).toBe(
      'Another admin.',
    );
    expect(gateReasonText({ code: 'mixed_crops' })).toBe('mixed crops');
  });
});

describe('Batch detail', () => {
  it('declared Special / computed Standard → Approve disabled with the reason; axe clean', async () => {
    mockState.batches.push(batch());
    mockState.grades[BATCH_ID] = grade({
      status: 'declared_above_computed',
      declared_grade: 'Special',
      computed_grade: 'Standard',
    });
    seedReadings();
    renderApp(`/batches/${BATCH_ID}`, true);

    const reason =
      'Declared grade Special is above the computed grade Standard: correct the readings, re-test or lower the declared grade.';
    const approve = await approveButton();
    expect(approve).toBeDisabled();
    expect(approve).toHaveAccessibleName(`Approve grading: ${reason}`);
    expect(screen.getByText(reason)).toBeVisible();
    expect(screen.getByText('Standard', { selector: 'strong' })).toBeInTheDocument();
    expect(screen.getByText('Special', { selector: 'strong' })).toBeInTheDocument();
    // Readings with source and instrument; the standard's edition from the profile version.
    const readings = within(screen.getByRole('table', { name: 'Quality readings' }));
    expect(await readings.findByText('Draminski GMM (DR-0042)')).toBeInTheDocument();
    expect(readings.getByText('Visual')).toBeInTheDocument();
    expect(readings.getByText('10.2 pct')).toBeInTheDocument();
    expect(
      await screen.findByText(
        /Agmark Chillies Grading and Marking Rules, edition 2005, Schedule II/,
      ),
    ).toBeInTheDocument();
    // An Indian mobile number (UUIDs in the page are all zeros and ones).
    expect(document.body.textContent).not.toMatch(/[6-9]\d{9}/);
    await expectNoAxeViolations(document.body);
  });

  it('missing reading → Approve disabled naming the parameter', async () => {
    mockState.batches.push(batch());
    mockState.grades[BATCH_ID] = grade({
      status: 'incomplete',
      computed_grade: null,
      per_parameter: {
        moisture: {
          parameter: 'moisture',
          outcome: 'missing',
          capped_by_source: false,
          lab_certified: false,
        },
      },
    });
    renderApp(`/batches/${BATCH_ID}`, true);
    const approve = await approveButton();
    expect(approve).toBeDisabled();
    expect(approve).toHaveAccessibleName(
      'Approve grading: A required quality reading is missing: moisture.',
    );
    expect(screen.getByText('No quality reading recorded on this batch.')).toBeInTheDocument();
  });

  it('a never-graded batch and a lot on hold grey Approve; a field officer also sees the role reason', async () => {
    mockState.roles = ['field_officer'];
    mockState.batches.push(
      batch({
        shares: [
          {
            lot_id: MOCK_LOT_ID,
            farmer_id: '20000000-0000-4000-8000-000000000010',
            contributed: { value: '320', unit: 'kg' },
            share_pct: '100.000',
          },
        ],
      }),
    );
    renderApp(`/batches/${BATCH_ID}`, true);
    const approve = await approveButton();
    await waitFor(() => {
      expect(approve).toHaveAccessibleName(
        'Approve grading: Only an FPO admin can do this. Not graded yet: the QC officer records the readings and the declared grade first. Open hold flag: Yield above the ceiling',
      );
    });
    expect(approve).toBeDisabled();
  });

  it('Publish lists every unmet reason before grading', async () => {
    mockState.batches.push(batch({ second_signoff_required: true }));
    renderApp(`/batches/${BATCH_ID}`, true);
    const publish = await screen.findByRole('button', { name: /^Publish/ });
    expect(publish).toBeDisabled();
    expect(publish).toHaveAccessibleName(
      'Publish: The grading has not been approved. Final packing has not been signed off. A second FPO admin must sign off this batch.',
    );
    expect(
      screen.getByRole('button', {
        name: /^Sign off final packing: The grading has not been approved/,
      }),
    ).toBeDisabled();
  });

  it('happy path → approved, packed (≤ graded), published with URL, QR, labels, preview and Rebuild; axe clean', async () => {
    mockState.batches.push(batch());
    mockState.grades[BATCH_ID] = grade();
    seedReadings();
    const createObjectURL = vi.fn(() => 'blob:labels');
    const revokeObjectURL = vi.fn();
    // jsdom has no object URLs.
    Object.assign(URL, { createObjectURL, revokeObjectURL });
    const click = vi
      .spyOn(HTMLAnchorElement.prototype, 'click')
      .mockImplementation(() => undefined);
    const user = userEvent.setup();
    renderApp(`/batches/${BATCH_ID}`, true);

    // Approve with the graded kg.
    const approve = await approveButton();
    await waitFor(() => {
      expect(approve).toBeEnabled();
    });
    await user.click(approve);
    expect(await screen.findByText('Enter kilograms, e.g. 300 or 272.5.')).toBeInTheDocument();
    await user.type(screen.getByLabelText('Graded quantity (kg)'), '300');
    await user.click(approve);
    expect(
      await screen.findByText('Grading approved: grade Special, 300 kg graded.'),
    ).toBeInTheDocument();

    // Final packing: above graded is refused in the form, then 300 kg with dates.
    await user.type(screen.getByLabelText('Packed quantity (kg)'), '400');
    fireEvent.change(screen.getByLabelText('Pack date'), { target: { value: '2026-11-02' } });
    fireEvent.change(screen.getByLabelText('Best before'), { target: { value: '2026-11-01' } });
    const pack = screen.getByRole('button', { name: 'Sign off final packing' });
    await user.click(pack);
    expect(await screen.findByText('At most the graded 300 kg.')).toBeInTheDocument();
    expect(
      screen.getByText('Best before cannot be earlier than the pack date.'),
    ).toBeInTheDocument();
    await user.clear(screen.getByLabelText('Packed quantity (kg)'));
    await user.type(screen.getByLabelText('Packed quantity (kg)'), '300');
    fireEvent.change(screen.getByLabelText('Best before'), { target: { value: '2027-11-01' } });
    await user.click(pack);
    expect(
      await screen.findByText(/^Packed 300 kg on 2 Nov, best before 1 Nov/),
    ).toBeInTheDocument();

    // Publish → 202 → queued → built.
    await user.click(screen.getByRole('button', { name: 'Publish' }));
    expect(await screen.findByText('Building the public page (build 1)…')).toBeInTheDocument();
    const link = await screen.findByRole(
      'link',
      { name: /\/b\/FGP8T4033HM7$/ },
      { timeout: 10_000 },
    );
    expect(link).toHaveAttribute('href', `${window.location.origin}/b/${CODE}`);
    expect(mockState.batches[0]?.status).toBe('published');
    expect(await screen.findByRole('img', { name: /^QR code opening/ })).toHaveAttribute(
      'src',
      expect.stringMatching(/^data:image\/png;base64,/) as string,
    );
    const preview = screen.getByTitle(`Preview of the public page of batch ${CODE}`);
    expect(preview).toHaveAttribute('src', `/v1/public/batches/${CODE}`);
    expect(preview).toHaveAttribute('sandbox', '');
    const builds = within(screen.getByRole('table', { name: 'Page builds' }));
    expect(builds.getByRole('cell', { name: 'Built' })).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Download labels' }));
    await waitFor(() => {
      expect(click).toHaveBeenCalled();
    });
    expect(createObjectURL).toHaveBeenCalledWith(expect.any(Blob));

    // Rebuild after a correction → build 2.
    await user.click(screen.getByRole('button', { name: 'Rebuild' }));
    expect(await builds.findByRole('cell', { name: 'rebuild' })).toBeInTheDocument();
    await waitFor(
      () => {
        expect(builds.getAllByRole('cell', { name: 'Built' })).toHaveLength(2);
      },
      { timeout: 10_000 },
    );
    // An Indian mobile number (UUIDs in the page are all zeros and ones).
    expect(document.body.textContent).not.toMatch(/[6-9]\d{9}/);
    await expectNoAxeViolations(document.body);
    click.mockRestore();
  });

  it('shows the server reasons of a refused final packing as labels', async () => {
    mockState.batches.push(batch({ status: 'graded', graded: { value: '300', unit: 'kg' } }));
    server.use(
      http.post('/v1/batches/:batchId/final-packing', () =>
        HttpResponse.json(
          {
            error: {
              code: 'gate_not_met',
              message: 'gate_not_met',
              details: {
                reasons: [
                  { code: 'packed_above_graded', message: 'x', graded_kg: '280' },
                  { code: 'open_hold_flag', message: 'x', rule_code: 'yield_over_ceiling' },
                ],
              },
            },
          },
          { status: 409 },
        ),
      ),
    );
    const user = userEvent.setup();
    renderApp(`/batches/${BATCH_ID}`, true);
    await user.type(await screen.findByLabelText('Packed quantity (kg)'), '290');
    fireEvent.change(screen.getByLabelText('Pack date'), { target: { value: '2026-11-02' } });
    fireEvent.change(screen.getByLabelText('Best before'), { target: { value: '2027-11-02' } });
    await user.click(screen.getByRole('button', { name: 'Sign off final packing' }));
    const list = await screen.findByRole('list', { name: 'Unmet conditions' });
    expect(
      within(list)
        .getAllByRole('listitem')
        .map((li) => li.textContent),
    ).toEqual([
      'The packed quantity is above the graded quantity (280 kg).',
      'Open hold flag: Yield above the ceiling',
    ]);
  });

  it('a failed build lists the field paths; a field officer cannot Rebuild', async () => {
    mockState.roles = ['field_officer'];
    mockState.batches.push(batch({ status: 'published', current_build_no: 1 }));
    mockState.builds.push({
      id: 'p0000000-0000-7000-8000-000000000001',
      batch_id: BATCH_ID,
      build_no: 1,
      generation: 1,
      status: 'failed',
      trigger: 'publish',
      built_at: null,
      error: {
        code: 'public_record_invalid',
        details: [{ loc: ['compliance', 'fssai_no'], msg: 'Field required', type: 'missing' }],
      },
      html_key: null,
      json_key: null,
      qr_key: null,
    });
    renderApp(`/batches/${BATCH_ID}`, true);
    const fields = await screen.findByRole('list', { name: 'Failed fields' });
    expect(fields).toHaveTextContent('compliance › fssai_no: Field required');
    expect(screen.getByRole('button', { name: /^Rebuild/ })).toHaveAccessibleName(
      'Rebuild: Only an FPO admin can do this.',
    );
    expect(screen.queryByRole('button', { name: /^Publish/ })).toBeNull();
  });
});

describe('Non-GI batch vs GI-only holds (D-041)', () => {
  /**
   * A batch of the out-of-GI lot (plot hold `plot_outside_gi_region`) and the held lot (`yield_over_ceiling`).
   * @param extra Fields to override.
   * @returns The batch.
   */
  const heldBatch = (extra: Partial<BatchOut>) =>
    batch({
      shares: [MOCK_OUT_OF_GI_LOT_ID, MOCK_LOT_ID].map((lot_id) => ({
        lot_id,
        farmer_id: '20000000-0000-4000-8000-000000000010',
        contributed: { value: '160', unit: 'kg' },
        share_pct: '50.000',
      })),
      ...extra,
    });
  const allowed = [
    'Yield above the ceiling: allowed in a non-GI batch',
    'Plot outside the GI region: allowed in a non-GI batch',
  ];

  it('a non-GI batch notes the holds, keeps Approve enabled and publishes', async () => {
    mockState.batches.push(heldBatch({ gi_label_requested: false, gi_verified: false }));
    mockState.grades[BATCH_ID] = grade();
    renderApp(`/batches/${BATCH_ID}`, true);
    const warnings = await screen.findByRole('list', { name: 'Warnings' });
    await waitFor(() => {
      expect(
        within(warnings)
          .getAllByRole('listitem')
          .map((li) => li.textContent),
      ).toEqual(allowed);
    });
    expect(screen.getByText('Non-GI batch: no GI badge on the public page')).toBeInTheDocument();
    const approve = await screen.findByRole('button', { name: 'Approve grading' });
    expect(approve).toBeEnabled();
  });

  it('the mock server publishes a packed non-GI batch over those holds', async () => {
    mockState.batches.push(
      heldBatch({ gi_label_requested: false, gi_verified: false, status: 'packed' }),
    );
    const user = userEvent.setup();
    renderApp(`/batches/${BATCH_ID}`, true);
    await screen.findByRole('list', { name: 'Warnings' });
    await user.click(await screen.findByRole('button', { name: 'Publish' }));
    expect(await screen.findByText('Building the public page (build 1)…')).toBeInTheDocument();
    expect(mockState.batches[0]?.status).toBe('published');
  });

  it('the same holds on a GI batch grey Publish with the reasons', async () => {
    mockState.batches.push(heldBatch({ status: 'packed' }));
    renderApp(`/batches/${BATCH_ID}`, true);
    const publish = await screen.findByRole('button', { name: /^Publish/ });
    await waitFor(() => {
      expect(publish).toHaveAccessibleName(
        'Publish: Open hold flag: Yield above the ceiling Open hold flag: Plot outside the GI region',
      );
    });
    expect(publish).toBeDisabled();
    expect(screen.queryByRole('list', { name: 'Warnings' })).toBeNull();
  });

  it('the Ready lots switch uses the D-041 wording', async () => {
    renderApp('/ready-lots', true);
    expect(
      await screen.findByRole('switch', {
        name: 'Non-GI batch: lots outside the GI region or above the yield ceiling can join. The public page shows no GI badge.',
      }),
    ).toBeInTheDocument();
  });
});

describe('Batches list', () => {
  it('pages with Load more and filters by status in the URL', async () => {
    for (let i = 0; i < 55; i++) {
      mockState.batches.push(
        batch({
          id: `b1000000-0000-7000-8000-${String(i).padStart(12, '0')}`,
          code: `FGP${String(i).padStart(9, '0')}`,
          status: i % 5 === 0 ? 'published' : 'created',
          packed: i % 5 === 0 ? { value: '300', unit: 'kg' } : null,
        }),
      );
    }
    const user = userEvent.setup();
    const { container } = renderApp('/batches', true);
    const table = await screen.findByRole('table', { name: 'Batches' });
    expect(within(table).getAllByRole('row')).toHaveLength(51);
    await user.click(screen.getByRole('button', { name: 'Load more' }));
    await waitFor(() => {
      expect(within(table).getAllByRole('row')).toHaveLength(56);
    });
    expect(within(table).getByRole('link', { name: 'FGP000000054' })).toHaveAttribute(
      'href',
      '/batches/b1000000-0000-7000-8000-000000000054',
    );

    await user.selectOptions(screen.getByLabelText('Status'), 'published');
    await waitFor(() => {
      expect(
        within(screen.getByRole('table', { name: 'Batches' })).getAllByRole('row'),
      ).toHaveLength(12);
    });
    expect(screen.queryByRole('button', { name: 'Load more' })).toBeNull();
    await expectNoAxeViolations(container);
  });

  it('points to Ready lots when there is no batch', async () => {
    renderApp('/batches', true);
    expect(await screen.findByRole('link', { name: 'Ready lots' })).toHaveAttribute(
      'href',
      '/ready-lots',
    );
  });
});
