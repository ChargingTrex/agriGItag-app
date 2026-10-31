/**
 * Tests the FPO settings page against the MSW mock API: FSSAI and GI numbers, the name opt-out state, the
 * read-only feature flags and fields ("edited in git"), errors, and axe.
 * Serves: plan §7.3 P06 (Settings; "opt-out reflected in preview" is asserted on the setting until the update
 * route exists, TODO.md), FR62, D-017. Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';

describe('Settings', () => {
  it('shows the FPO numbers, the opt-out and read-only flags and fields', async () => {
    const { container } = renderApp('/settings', true);
    expect(await screen.findByText('FSSAI licence no.: DEMO-FSSAI-0001')).toBeInTheDocument();
    expect(screen.getByText('GI authorised-user no.: DEMO-GI-AU-883')).toBeInTheDocument();
    const optOut = screen.getByRole('switch', {
      name: 'Hide farmer names on public pages (opt-out)',
    });
    expect(optOut).toBeChecked();
    expect(optOut).toBeDisabled();
    expect(screen.getByText(/Public pages show “Farmer 1”/)).toBeInTheDocument();

    const flags = await screen.findByRole('table', { name: 'Feature flags' });
    expect(within(flags).getByText('second signoff threshold kg')).toBeInTheDocument();
    expect(within(flags).getByText('5000')).toBeInTheDocument();
    expect(within(flags).getAllByText('Off').length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Edited in git/)).toHaveLength(2);

    const fields = await screen.findByRole('table', { name: 'Fields captured' });
    expect(within(fields).getByText('Mobile number')).toBeInTheDocument();
    expect(within(fields).getAllByRole('row')).toHaveLength(4);
    // No editable control on the page: no update route exists yet.
    expect(screen.queryByRole('button', { name: /save/i })).not.toBeInTheDocument();

    const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
    expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
  });

  it('shows names allowed and missing numbers as "Not recorded"', async () => {
    server.use(
      http.get('/v1/fpos/:fpoId', ({ params }) =>
        HttpResponse.json({
          id: params['fpoId'],
          code: 'X',
          name: 'X FPO',
          kind: 'fpo',
          address: null,
          address_line: '',
          fssai_no: null,
          gi_authorised_user_no: null,
          public_show_farmer_names: true,
          bbox: null,
        }),
      ),
    );
    renderApp('/settings', true);
    expect(await screen.findByText('FSSAI licence no.: Not recorded')).toBeInTheDocument();
    expect(screen.getByRole('switch')).not.toBeChecked();
    expect(screen.getByText(/only when that farmer consented/)).toBeInTheDocument();
  });

  it('shows the API message for each failed section', async () => {
    /**
     * A 403 envelope (not retried, so the test does not wait for back-off).
     * @returns The mock response.
     */
    const boom = () =>
      HttpResponse.json({ error: { code: 'forbidden', message: 'x' } }, { status: 403 });
    server.use(
      http.get('/v1/fpos/:fpoId', boom),
      http.get('/v1/config/features', boom),
      http.get('/v1/config/fields', boom),
    );
    renderApp('/settings', true);
    await waitFor(() => {
      expect(screen.getAllByText('Your role does not allow this action.')).toHaveLength(3);
    });
  });
});
