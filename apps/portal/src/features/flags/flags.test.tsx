/**
 * Tests the flags review screens against the MSW mock API: list filters and paging, details per rule family,
 * the resolve form (required fields, role gate, errors), the held lot becoming GI eligible after review, plot
 * review through the correct endpoint, farmer/lot links, and axe on every new page.
 * Serves: plan §7.3 P02 acceptance "review held lot → cleared → tickable in P03" and "required fields block
 * submit", FR56, FR68, FR70. Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import {
  MOCK_ACTIVE_FARMER_ID,
  MOCK_HOLD_FLAG_ID,
  MOCK_LOT_ID,
  MOCK_PIN_FLAG_ID,
  MOCK_PLOT_ID,
  MOCK_PRACTICE_FLAG_ID,
  MOCK_QTY_FLAG_ID,
  MOCK_REVIEW_PLOT_ID,
  MOCK_EVENT_FLAG_ID,
  mockState,
} from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import { activeHolds, dayMonth, resolveBlock, ruleText, type FlagOut } from './flagModel';

vi.mock('../members/PlotMap', () => ({
  /**
   * Stand-in for the MapLibre map (jsdom has no WebGL).
   * @param props Map props.
   * @param props.pin Plot pin.
   * @param props.pin.lat Latitude.
   * @param props.pin.lon Longitude.
   * @returns A text summary.
   */
  default: ({ pin }: { pin: { lat: number; lon: number } }) => (
    <p>
      map at {pin.lat},{pin.lon}
    </p>
  ),
}));

/**
 * Asserts that axe finds no violations in the rendered page (colour contrast needs layout, absent in jsdom).
 * @param container The RTL container.
 */
async function expectNoAxeViolations(container: HTMLElement): Promise<void> {
  const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
  expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
}

/**
 * Body rows of the table with the given accessible name.
 * @param name The table's aria-label.
 * @returns Its rows without the header row.
 */
const bodyRows = (name: string) =>
  within(screen.getByRole('table', { name })).getAllByRole('row').slice(1);

describe('Flags list', () => {
  it('lists open flags with glyph, en/ta label, "14 Feb" date and assignee, and passes axe', async () => {
    const { container } = renderApp('/flags', true);
    await screen.findByRole('table', { name: 'Flags' });
    // Five seed flags are open or escalated; the default status filter is "open" (4 of them).
    expect(bodyRows('Flags')).toHaveLength(4);
    const hold = bodyRows('Flags').find((row) => within(row).queryByText('Hold'));
    expect(hold).toBeDefined();
    const cells = within(hold as HTMLElement);
    expect(cells.getByText('■')).toHaveAttribute('aria-hidden', 'true');
    expect(cells.getByRole('link', { name: 'Yield above the ceiling' })).toHaveAttribute(
      'href',
      `/flags/${MOCK_HOLD_FLAG_ID}`,
    );
    expect(cells.getByText('மகசூல் உச்சவரம்பை மீறியது')).toHaveAttribute('lang', 'ta');
    expect(cells.getByText('14 Feb')).toBeInTheDocument();
    expect(cells.getByText('FPO admin')).toBeInTheDocument();
    expect(cells.getByRole('link', { name: /^lot / })).toHaveAttribute(
      'href',
      `/lots/${MOCK_LOT_ID}`,
    );
    await expectNoAxeViolations(container);
  });

  it('filters by status and severity on the server, by rule and subject in the browser', async () => {
    const user = userEvent.setup();
    renderApp(`/flags?subject=${MOCK_LOT_ID}`, true);
    await screen.findByRole('table', { name: 'Flags' });
    expect(screen.getByText(/Showing flags of one farmer or lot only/)).toBeInTheDocument();
    expect(bodyRows('Flags')).toHaveLength(2);

    await user.selectOptions(screen.getByLabelText('Status'), '');
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(3);
    });
    await user.click(screen.getByRole('button', { name: 'Show all' }));
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(6);
    });
    expect(
      within(screen.getByRole('table', { name: 'Flags' })).getByText('Cleared'),
    ).toBeInTheDocument();

    await user.selectOptions(screen.getByLabelText('Severity'), 'hold');
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(1);
    });
    await user.selectOptions(screen.getByLabelText('Severity'), '');
    await user.selectOptions(screen.getByLabelText('Rule'), 'quantity_mismatch');
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(1);
    });
    expect(screen.getByRole('link', { name: 'Quantities do not add up' })).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Rule'), '');
    await user.selectOptions(screen.getByLabelText('Assigned to'), 'field_officer');
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(4);
    });
  });

  it('pages with the cursor', async () => {
    const user = userEvent.setup();
    mockState.flags = Array.from({ length: 60 }, (_, n) => ({
      ...(mockState.flags[0] as FlagOut),
      id: `f1000000-0000-7000-8000-${String(n).padStart(12, '0')}`,
    }));
    renderApp('/flags', true);
    await screen.findByRole('table', { name: 'Flags' });
    expect(bodyRows('Flags')).toHaveLength(50);
    await user.click(screen.getByRole('button', { name: 'Load more' }));
    await waitFor(() => {
      expect(bodyRows('Flags')).toHaveLength(60);
    });
    expect(screen.queryByRole('button', { name: 'Load more' })).not.toBeInTheDocument();
  });

  it('shows the API error message when the list fails', async () => {
    server.use(
      http.get('/v1/flags', () =>
        HttpResponse.json({ error: { code: 'forbidden', message: 'x' } }, { status: 403 }),
      ),
    );
    renderApp('/flags', true);
    expect(await screen.findByText('Your role does not allow this action.')).toBeInTheDocument();
  });
});

describe('Flag detail and resolve', () => {
  it('review held lot → cleared → GI eligible (tickable in P03), with evidence thumbnails and axe clean', async () => {
    const user = userEvent.setup();
    const { container } = renderApp(`/flags/${MOCK_HOLD_FLAG_ID}`, true);
    await screen.findByRole('heading', { name: 'Yield above the ceiling' });
    expect(screen.getByText('1350 kg/acre')).toBeInTheDocument();
    expect(screen.getByText('1000 kg/acre')).toBeInTheDocument();
    expect(
      await screen.findByText(/On hold: not eligible for GI-labelled batches/),
    ).toBeInTheDocument();
    const photo = await screen.findByRole('img', { name: 'Evidence photo: harvest, 12 Feb' });
    expect(photo.getAttribute('src')).toMatch(/^data:image\/svg/);
    await expectNoAxeViolations(container);
    // The FPO admin is not offered "escalate to the FPO admin".
    expect(
      within(screen.getByLabelText(/Outcome/)).queryByRole('option', { name: /Escalate/ }),
    ).toBeNull();

    await user.selectOptions(screen.getByLabelText(/Outcome/), 'looks_fine');
    await user.selectOptions(screen.getByLabelText(/Reason/), 'land_record_checked');
    await user.type(screen.getByLabelText(/Note/), 'Patta shows 1.4 acre');
    await user.click(screen.getByRole('button', { name: 'Save review' }));

    expect(await screen.findByText(/Cleared on .*land record checked/)).toBeInTheDocument();
    expect(await screen.findByText('No hold flag on this lot.')).toBeInTheDocument();
    expect(mockState.flags.find((f) => f.id === MOCK_HOLD_FLAG_ID)?.status).toBe('cleared');
  });

  it('fails closed: a cut-off hold list shows "GI state unknown", not eligible', async () => {
    server.use(
      http.get('/v1/flags', () =>
        HttpResponse.json({ items: [], next_cursor: 'x', has_more: true }),
      ),
    );
    renderApp(`/lots/${MOCK_LOT_ID}`, true);
    expect(await screen.findByText(/GI state unknown/)).toBeInTheDocument();
    expect(screen.queryByText('No hold flag on this lot.')).not.toBeInTheDocument();
  });

  it('required fields block submit with inline messages and send nothing', async () => {
    const user = userEvent.setup();
    const posted = vi.fn();
    server.events.on('request:start', ({ request }) => {
      if (request.method === 'POST' && request.url.includes('/resolve')) posted();
    });
    try {
      renderApp(`/flags/${MOCK_QTY_FLAG_ID}`, true);
      await user.click(await screen.findByRole('button', { name: 'Save review' }));
      expect(await screen.findByText('Choose an outcome.')).toBeInTheDocument();
      expect(screen.getByText('Choose a reason.')).toBeInTheDocument();
      expect(posted).not.toHaveBeenCalled();
    } finally {
      server.events.removeAllListeners();
    }
  });

  it('a field officer sees a hold flag with the button disabled and the reason', async () => {
    mockState.roles = ['field_officer'];
    renderApp(`/flags/${MOCK_HOLD_FLAG_ID}`, true);
    expect(
      await screen.findByText('Only an FPO admin can resolve a hold or an escalated flag.'),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save review' })).toBeDisabled();
  });

  it('a field officer escalates a warn flag to the FPO admin', async () => {
    const user = userEvent.setup();
    mockState.roles = ['field_officer'];
    renderApp(`/flags/${MOCK_QTY_FLAG_ID}`, true);
    await screen.findByRole('heading', { name: 'Quantities do not add up' });
    expect(
      screen.getByText('harvested 300 kg → packed 272.6 kg → received 400 kg'),
    ).toBeInTheDocument();
    expect(screen.getByText('packed → received: 46.7 %')).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText(/Outcome/), 'escalated');
    await user.selectOptions(screen.getByLabelText(/Reason/), 'field_visit');
    await user.click(screen.getByRole('button', { name: 'Save review' }));
    expect(
      await screen.findByText('Only an FPO admin can resolve a hold or an escalated flag.'),
    ).toBeInTheDocument();
    expect(screen.getByText('Escalated')).toBeInTheDocument();
  });

  it('shows the error code message when the API refuses the resolution', async () => {
    const user = userEvent.setup();
    server.use(
      http.post('/v1/flags/:flagId/resolve', () =>
        HttpResponse.json({ error: { code: 'flag_not_open', message: 'x' } }, { status: 409 }),
      ),
    );
    renderApp(`/flags/${MOCK_QTY_FLAG_ID}`, true);
    await user.selectOptions(await screen.findByLabelText(/Outcome/), 'fixed');
    await user.selectOptions(screen.getByLabelText(/Reason/), 'data_corrected');
    await user.click(screen.getByRole('button', { name: 'Save review' }));
    expect(await screen.findByText('This flag is already resolved.')).toBeInTheDocument();
  });

  it('renders practice-tag and location details', async () => {
    renderApp(`/flags/${MOCK_PRACTICE_FLAG_ID}`, true);
    await screen.findByRole('heading', { name: 'Practice tag contradicts inputs' });
    expect(screen.getByText('organic')).toBeInTheDocument();
    expect(screen.getByText('chemical_fertilizer')).toBeInTheDocument();
  });

  it('renders an event flag with its raw details and no photos', async () => {
    renderApp(`/flags/${MOCK_EVENT_FLAG_ID}`, true);
    await screen.findByRole('heading', { name: 'Entry recorded away from the plot' });
    expect(screen.getByText('pin radius m:')).toBeInTheDocument();
    expect(screen.getByText('200')).toBeInTheDocument();
    expect(screen.getByText(/timeline in the mobile app/)).toBeInTheDocument();
  });

  it('a plot flag links to the plot review', async () => {
    renderApp(`/flags/${MOCK_PIN_FLAG_ID}`, true);
    expect(await screen.findByRole('link', { name: 'Review the plot on the map' })).toHaveAttribute(
      'href',
      `/members/plots/${MOCK_REVIEW_PLOT_ID}`,
    );
    expect(screen.getByText('The rule sent no further details.')).toBeInTheDocument();
  });
});

describe('Lot, farmer and plot review', () => {
  it('lot page: hold state, the lot flags, link to open flags; axe clean', async () => {
    const { container } = renderApp(`/lots/${MOCK_LOT_ID}`, true);
    expect(await screen.findByText(/On hold/)).toBeInTheDocument();
    await screen.findByRole('table', { name: 'Flags on this lot' });
    expect(bodyRows('Flags on this lot')).toHaveLength(3);
    expect(screen.getByRole('link', { name: 'Open flags of this lot' })).toHaveAttribute(
      'href',
      `/flags?subject=${MOCK_LOT_ID}`,
    );
    await screen.findByRole('img', { name: /Evidence photo/ });
    await expectNoAxeViolations(container);
  });

  it('farmer page lists the plots and links to their open flags', async () => {
    renderApp(`/members/${MOCK_ACTIVE_FARMER_ID}`, true);
    expect(await screen.findByRole('link', { name: 'Plot VSV-0010-P2' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Open flags on these plots' })).toHaveAttribute(
      'href',
      `/flags?subject=${MOCK_PLOT_ID},${MOCK_REVIEW_PLOT_ID}`,
    );
  });

  it('an FPO admin approves a map-pin plot: reason required, revision bumps, its flag closes; axe clean', async () => {
    const user = userEvent.setup();
    const { container } = renderApp(`/members/plots/${MOCK_REVIEW_PLOT_ID}`, true);
    await screen.findByText('Revision 1, not reviewed yet');
    expect(await screen.findByText('map at 9.6012,78.0101')).toBeInTheDocument();
    await expectNoAxeViolations(container);

    await user.click(screen.getByRole('button', { name: 'Save review' }));
    expect(await screen.findByText('Choose how you checked.')).toBeInTheDocument();
    expect(screen.getByText('Choose a reason.')).toBeInTheDocument();

    await user.selectOptions(screen.getByLabelText(/Outcome/), 'accepted');
    await user.selectOptions(screen.getByLabelText(/How you checked/), 'land_record');
    await user.selectOptions(screen.getByLabelText(/Reason/), 'land_record_checked');
    await user.type(screen.getByLabelText('Latitude'), '9.6');
    await user.click(screen.getByRole('button', { name: 'Save review' }));
    expect(
      await screen.findByText('Enter both latitude and longitude, or neither.'),
    ).toBeInTheDocument();
    await user.type(screen.getByLabelText('Longitude'), '78.01');
    await user.click(screen.getByRole('button', { name: 'Save review' }));

    expect(await screen.findByText('Review saved.')).toBeInTheDocument();
    expect(await screen.findByText(/Revision 2, last reviewed on/)).toBeInTheDocument();
    expect(screen.getByText('Inside GI region')).toBeInTheDocument();
    expect(mockState.flags.find((f) => f.id === MOCK_PIN_FLAG_ID)?.status).toBe('fixed');
  });

  it('a field officer cannot review a plot', async () => {
    mockState.roles = ['field_officer'];
    renderApp(`/members/plots/${MOCK_REVIEW_PLOT_ID}`, true);
    expect(
      await screen.findByText('Only an FPO admin can review or correct a plot.'),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save review' })).toBeDisabled();
  });
});

describe('flag model', () => {
  const flag = { severity: 'warn', status: 'open' } as const;

  it('resolveBlock mirrors the API role rule', () => {
    expect(resolveBlock({ ...flag, severity: 'hold' }, ['fpo_admin'])).toBeNull();
    expect(resolveBlock(flag, ['field_officer'])).toBeNull();
    expect(resolveBlock({ ...flag, severity: 'hold' }, ['field_officer'])).toMatch(/FPO admin/);
    expect(resolveBlock({ ...flag, status: 'escalated' }, ['field_officer'])).toMatch(/FPO admin/);
    expect(resolveBlock(flag, ['viewer'])).toMatch(/role/);
  });

  it('activeHolds counts only open or escalated holds on that lot', () => {
    const base = mockState.flags.find((f) => f.id === MOCK_HOLD_FLAG_ID) as FlagOut;
    expect(activeHolds([base], MOCK_LOT_ID)).toHaveLength(1);
    expect(activeHolds([{ ...base, status: 'escalated' }], MOCK_LOT_ID)).toHaveLength(1);
    expect(activeHolds([{ ...base, status: 'cleared' }], MOCK_LOT_ID)).toHaveLength(0);
    expect(activeHolds([{ ...base, severity: 'warn' }], MOCK_LOT_ID)).toHaveLength(0);
    expect(activeHolds([base], 'another-lot')).toHaveLength(0);
  });

  it('ruleText falls back to a readable code; dayMonth prints "14 Feb"', () => {
    expect(ruleText('new_rule_code')).toEqual({ en: 'new rule code', ta: null, family: 'other' });
    expect(dayMonth('2026-02-14T03:00:00Z')).toBe('14 Feb');
  });
});
