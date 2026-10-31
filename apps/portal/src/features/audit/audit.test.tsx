/**
 * Tests the audit log viewer against the MSW mock API: rows with scrubbed diffs, the search for the seeded
 * correction (actor; the reason gap is stated), actor + inclusive date range, form validation, the 403 for
 * non-admins, and axe.
 * Serves: plan §7.3 P06 acceptance "audit search for the seeded correction shows actor + reason", FR25, D-039.
 * Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { describe, expect, it } from 'vitest';
import { MOCK_CORRECTION_VERSION_ID, MOCK_OFFICER_ID } from '../../mocks/dashboardHandlers';
import { MOCK_USER_ID, mockState } from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { auditTime, diffText, istMidnight } from './AuditLogPage';

/**
 * Body rows of the audit table.
 * @returns Its rows without the header row.
 */
const rows = () =>
  within(screen.getByRole('table', { name: 'Audit log' }))
    .getAllByRole('row')
    .slice(1);

describe('Audit log', () => {
  it('lists changes newest first with [hidden] and [redacted] values as the API sent them', async () => {
    const { container } = renderApp('/audit', true);
    await screen.findByRole('table', { name: 'Audit log' });
    expect(rows()).toHaveLength(3);
    const [correction, plot, farmer] = rows() as [HTMLElement, HTMLElement, HTMLElement];
    expect(correction).toHaveTextContent('14 Mar 2026, 11:00');
    expect(within(plot).getByText('[hidden]')).toBeInTheDocument();
    expect(plot).toHaveTextContent('declared area acres: ["0.4","0.5"]');
    expect(within(farmer).getByText('[redacted]')).toBeInTheDocument();
    expect(document.body.textContent).not.toMatch(/POINT\(|\+91/);
    const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
    expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
  });

  it('finds the seeded correction by entity and shows its actor, assist and the reason gap', async () => {
    const user = userEvent.setup();
    renderApp('/audit', true);
    await screen.findByRole('table', { name: 'Audit log' });
    await user.selectOptions(screen.getByLabelText('Entity type'), 'event_versions');
    await user.type(screen.getByLabelText('Entity id'), MOCK_CORRECTION_VERSION_ID);
    await user.click(screen.getByRole('button', { name: 'Search' }));

    await waitFor(() => {
      expect(rows()).toHaveLength(1);
    });
    const row = rows()[0] as HTMLElement;
    expect(row).toHaveTextContent(MOCK_OFFICER_ID);
    expect(row).toHaveTextContent('assisted entry for farmer');
    expect(row).toHaveTextContent('event.correct');
    expect(row).toHaveTextContent('change kind: correct');
    expect(row).toHaveTextContent('Reason: not in the audit log yet');
  });

  it('searches by actor and an inclusive date range in India time', async () => {
    const user = userEvent.setup();
    renderApp('/audit', true);
    await screen.findByRole('table', { name: 'Audit log' });
    await user.type(screen.getByLabelText('Actor (user id)'), MOCK_USER_ID);
    await user.type(screen.getByLabelText('From'), '2026-02-01');
    await user.type(screen.getByLabelText('To'), '2026-02-14');
    await user.click(screen.getByRole('button', { name: 'Search' }));

    await waitFor(() => {
      expect(rows()).toHaveLength(1);
    });
    expect(rows()[0]).toHaveTextContent('plots');

    await user.clear(screen.getByLabelText('To'));
    await user.type(screen.getByLabelText('To'), '2026-01-01');
    await user.click(screen.getByRole('button', { name: 'Search' }));
    expect(await screen.findByText('The end date is before the start date.')).toBeInTheDocument();
  });

  it('refuses an actor that is not a UUID, and says when nothing matches', async () => {
    const user = userEvent.setup();
    renderApp('/audit', true);
    await screen.findByRole('table', { name: 'Audit log' });
    await user.type(screen.getByLabelText('Actor (user id)'), 'ravi');
    await user.click(screen.getByRole('button', { name: 'Search' }));
    expect(
      await screen.findByText('Enter a user id (UUID) or leave it empty.'),
    ).toBeInTheDocument();

    await user.clear(screen.getByLabelText('Actor (user id)'));
    await user.selectOptions(screen.getByLabelText('Entity type'), 'batches');
    await user.click(screen.getByRole('button', { name: 'Search' }));
    expect(await screen.findByText('No change matches the search.')).toBeInTheDocument();
  });

  it('shows the role message to a field officer (server answers 403)', async () => {
    mockState.roles = ['field_officer'];
    renderApp('/audit', true);
    expect(await screen.findByText('Your role does not allow this action.')).toBeInTheDocument();
  });

  it('istMidnight converts India dates; auditTime shows year and time; diffText keeps strings and shortens long JSON', () => {
    expect(istMidnight('2026-02-14')).toBe('2026-02-13T18:30:00.000Z');
    expect(istMidnight('2026-02-14', 1)).toBe('2026-02-14T18:30:00.000Z');
    expect(auditTime('2026-02-14T04:00:00Z')).toBe('14 Feb 2026, 09:30');
    expect(diffText('[hidden]')).toBe('[hidden]');
    expect(diffText(2)).toBe('2');
    expect(diffText('x'.repeat(200).split(''))).toHaveLength(120);
  });
});
