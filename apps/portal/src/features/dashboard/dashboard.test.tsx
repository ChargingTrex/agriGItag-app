/**
 * Tests the dashboard against the MSW mock API: stage tiles match the seed, the dependent place filters narrow
 * tiles and farmer table, the column choice persists across a reload and is sent as `?fields=`, Load more,
 * errors, no phone numbers, and axe.
 * Serves: plan §7.3 P06 acceptance ("tiles match seed counts per stage", "changing village filter updates tiles
 * and table", "column toggle persists"), FR13, FR20, §13 F1. Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it } from 'vitest';
import { MOCK_FPO_ID } from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import { columnsKey, qty, readColumns } from './DashboardPage';

const ALL_DONE = '3 done · 0 in progress · 0 not started';

afterEach(() => {
  localStorage.clear();
  server.events.removeAllListeners();
});

/**
 * Body rows of the table with the given accessible name.
 * @param name The table's aria-label.
 * @returns Its rows without the header row.
 */
const bodyRows = (name: string) =>
  within(screen.getByRole('table', { name })).getAllByRole('row').slice(1);

/**
 * Records the `fields` parameter of every farmer-table request.
 * @returns The list, filled as requests start.
 */
function farmerFields(): (string | null)[] {
  const seen: (string | null)[] = [];
  server.events.on('request:start', ({ request }) => {
    const url = new URL(request.url);
    if (url.pathname.endsWith('/farmers') && url.pathname.includes('/dashboard/')) {
      seen.push(url.searchParams.get('fields'));
    }
  });
  return seen;
}

describe('Dashboard', () => {
  it('shows the seed: 3 lots done in all 7 stage tiles, land area, finished goods, sync health', async () => {
    const { container } = renderApp('/', true);
    await screen.findByRole('heading', { name: 'Stage progress (lots)' });
    for (const stage of [
      'Land prep',
      'Nursery',
      'Sowing',
      'Inputs',
      'Harvest',
      'Drying',
      'Packing',
    ]) {
      expect(screen.getByRole('heading', { name: stage, level: 3 })).toBeInTheDocument();
    }
    expect(screen.getAllByText(ALL_DONE)).toHaveLength(7);
    expect(screen.getByText('3 of 3 lots have every mandatory entry')).toBeInTheDocument();
    expect(screen.getByText('100.0 %')).toBeInTheDocument();

    // 57 farmers, one 0.5-acre plot each; 28 even-numbered ones walked.
    expect(
      screen.getByText(/57 plots: 28\.500 acre declared, 12\.600 acre walked \(28 plots\)/),
    ).toBeVisible();
    expect(bodyRows('Area by block')).toHaveLength(3);
    expect(bodyRows('Area by village')[0]).toHaveTextContent('Aruppukottai (Aruppukottai)');

    const goods = within(bodyRows('Finished goods')[0] as HTMLElement);
    expect(goods.getByText('FGP8T4033HM7')).toBeInTheDocument();
    expect(goods.getByText('30 Jul')).toBeInTheDocument();
    expect(goods.getAllByText('20.000 kg')).toHaveLength(2);
    expect(goods.getByText('not recorded')).toBeInTheDocument();

    const twoG = within(bodyRows('Sync health')[0] as HTMLElement);
    expect(twoG.getByText('6000 ms / 14000 ms')).toBeInTheDocument();
    expect(twoG.getByText('33.3 %')).toBeInTheDocument();
    expect(
      within(bodyRows('Sync health')[1] as HTMLElement).getByText('— / —'),
    ).toBeInTheDocument();

    await screen.findByRole('table', { name: 'Farmers' });
    // No phone number anywhere (CLAUDE.md §6).
    expect(document.body.textContent).not.toMatch(/\+91|\b\d{10}\b/);
    const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
    expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
  });

  it('narrows tiles and farmer table by block and village; block limits the village choices', async () => {
    const user = userEvent.setup();
    renderApp('/', true);
    await screen.findByRole('table', { name: 'Farmers' });
    await screen.findByRole('option', { name: 'Virudhunagar' });

    await user.selectOptions(screen.getByRole('combobox', { name: 'District' }), 'Virudhunagar');
    await user.selectOptions(screen.getByRole('combobox', { name: 'Block' }), 'Sattur');
    const villages = within(screen.getByRole('combobox', { name: 'Village' })).getAllByRole(
      'option',
    );
    expect(villages.map((o) => o.textContent)).toEqual([
      'All villages',
      'Elayirampannai',
      'Sattur',
    ]);

    await user.selectOptions(screen.getByRole('combobox', { name: 'Block' }), 'Aruppukottai');
    await user.selectOptions(screen.getByRole('combobox', { name: 'Village' }), 'Aruppukottai');
    // Farmers 1 and 4 (of the reference lots) live in Aruppukottai.
    expect(await screen.findAllByText('2 done · 0 in progress · 0 not started')).toHaveLength(7);
    await waitFor(() => {
      expect(bodyRows('Farmers')).toHaveLength(19);
    });
    for (const row of bodyRows('Farmers')) expect(row).toHaveTextContent('Aruppukottai');

    await user.selectOptions(screen.getByRole('combobox', { name: 'Block' }), 'Sattur');
    expect(screen.getByRole('combobox', { name: 'Village' })).toHaveValue('');
    expect(await screen.findAllByText('0 done · 0 in progress · 0 not started')).toHaveLength(7);
  });

  it('keeps a hidden column hidden after a reload and asks only for shown fields', async () => {
    const user = userEvent.setup();
    const fields = farmerFields();
    const first = renderApp('/', true);
    const table = await screen.findByRole('table', { name: 'Farmers' });
    expect(within(table).getByRole('columnheader', { name: 'Walked area' })).toBeInTheDocument();

    await user.click(screen.getByRole('checkbox', { name: 'Walked area' }));
    await waitFor(() => {
      expect(screen.queryByRole('columnheader', { name: 'Walked area' })).not.toBeInTheDocument();
    });
    expect(fields.at(-1)).toBe(
      'id,code,name,village,block,status,plots,declared_area,lots,lots_complete',
    );
    expect(JSON.parse(localStorage.getItem(columnsKey(MOCK_FPO_ID)) ?? '[]')).not.toContain(
      'walked_area',
    );

    first.unmount();
    renderApp('/', true);
    await screen.findByRole('table', { name: 'Farmers' });
    expect(screen.getByRole('checkbox', { name: 'Walked area' })).not.toBeChecked();
    expect(screen.queryByRole('columnheader', { name: 'Walked area' })).not.toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: 'Declared area' })).toBeInTheDocument();
  });

  it('pages the farmer table with Load more and keeps the last column', async () => {
    const user = userEvent.setup();
    localStorage.setItem(columnsKey(MOCK_FPO_ID), JSON.stringify(['code']));
    renderApp('/', true);
    await screen.findByRole('table', { name: 'Farmers' });
    expect(bodyRows('Farmers')).toHaveLength(50);
    expect(screen.getByRole('checkbox', { name: 'Code' })).toBeDisabled();

    await user.click(screen.getByRole('button', { name: 'Load more' }));
    await waitFor(() => {
      expect(bodyRows('Farmers')).toHaveLength(57);
    });
    expect(screen.queryByRole('button', { name: 'Load more' })).not.toBeInTheDocument();
  });

  it('shows the API message when the dashboard fails, and an empty farmer table', async () => {
    server.use(
      http.get('/v1/dashboard/fpo/:fpoId', () =>
        HttpResponse.json({ error: { code: 'forbidden', message: 'x' } }, { status: 403 }),
      ),
      http.get('/v1/dashboard/fpo/:fpoId/farmers', () =>
        HttpResponse.json({ items: [], next_cursor: null, has_more: false }),
      ),
    );
    renderApp('/', true);
    expect(await screen.findByText('Your role does not allow this action.')).toBeInTheDocument();
    expect(await screen.findByText('No farmer matches the filters.')).toBeInTheDocument();
  });

  it('readColumns ignores unknown or corrupt stored values; qty prints units or a fallback', () => {
    localStorage.setItem(columnsKey('x'), '{not json');
    expect(readColumns('x')).toHaveLength(10);
    localStorage.setItem(columnsKey('x'), JSON.stringify(['phone', 'lots']));
    expect(readColumns('x')).toEqual(['lots']);
    localStorage.setItem(columnsKey('x'), JSON.stringify(['phone']));
    expect(readColumns('x')).toHaveLength(10);
    expect(qty({ value: '0.500', unit: 'acre' })).toBe('0.500 acre');
    expect(qty(null)).toBe('not recorded');
  });
});
