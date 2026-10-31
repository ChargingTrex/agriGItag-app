/**
 * Tests the Members feature against the MSW mock API: approve without reload, roster cursor paging and
 * search, farmer detail, plot detail (map mocked: jsdom has no WebGL), processors create, and `bbox`.
 * Serves: plan §7.3 P01 acceptance "approve → active without reload", FR8, FR28, FR70, gap analysis
 * "Processor management". Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import {
  MOCK_ACTIVE_FARMER_ID,
  MOCK_FARMER_COUNT,
  MOCK_PENDING_FARMER_ID,
  MOCK_PLOT_ID,
} from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import { bbox } from './geo';

vi.mock('./PlotMap', () => ({
  /**
   * Stand-in for the MapLibre map.
   * @param props Map props.
   * @param props.pin Plot pin.
   * @param props.pin.lat Latitude.
   * @param props.pin.lon Longitude.
   * @param props.region GI outline or null.
   * @returns A text summary of the props.
   */
  default: ({ pin, region }: { pin: { lat: number; lon: number }; region: unknown }) => (
    <p>
      map at {pin.lat},{pin.lon} {region ? 'with GI outline' : 'without outline'}
    </p>
  ),
}));

/**
 * Body rows of the table with the given accessible name.
 * @param name The table's aria-label.
 * @returns Its rows without the header row.
 */
const bodyRows = (name: string) =>
  within(screen.getByRole('table', { name })).getAllByRole('row').slice(1);

describe('Members page', () => {
  it('approves a pending farmer: the row leaves the pending list and shows Active, without reload', async () => {
    const user = userEvent.setup();
    renderApp('/members', true);

    const pending = await screen.findByRole('table', { name: 'Waiting for approval' });
    expect(within(pending).getAllByRole('row')).toHaveLength(3);
    await user.click(screen.getByRole('button', { name: 'Approve Muthu Kumar' }));

    await waitFor(() => {
      expect(bodyRows('Waiting for approval')).toHaveLength(1);
    });
    const muthu = bodyRows('All members').find((row) => within(row).queryByText('Muthu Kumar'));
    expect(muthu && within(muthu).getByText('Active')).toBeInTheDocument();
  });

  it('shows the API error code message when approval fails', async () => {
    server.use(
      http.post('/v1/farmers/:farmerId/approve', () =>
        HttpResponse.json(
          { error: { code: 'farmer_not_pending', message: 'x', details: null } },
          { status: 409 },
        ),
      ),
    );
    const user = userEvent.setup();
    renderApp('/members', true);

    await user.click(await screen.findByRole('button', { name: 'Approve Muthu Kumar' }));

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'This farmer is not waiting for approval.',
    );
  });

  it('pages the roster with the cursor and searches the loaded rows', async () => {
    const user = userEvent.setup();
    renderApp('/members', true);

    await screen.findByRole('table', { name: 'All members' });
    expect(bodyRows('All members')).toHaveLength(50);
    await user.click(screen.getAllByRole('button', { name: 'Load more' })[0] as HTMLElement);
    await waitFor(() => {
      expect(bodyRows('All members')).toHaveLength(MOCK_FARMER_COUNT);
    });
    expect(screen.queryByRole('button', { name: 'Load more' })).not.toBeInTheDocument();

    await user.type(screen.getByLabelText('Search name, code or village'), 'VSV-0057');
    expect(bodyRows('All members')).toHaveLength(1);
  });

  it('filters the roster by status on the server', async () => {
    const user = userEvent.setup();
    renderApp('/members', true);

    await screen.findByRole('table', { name: 'All members' });
    await user.click(screen.getByLabelText('Status'));
    await user.click(await screen.findByRole('option', { name: 'Suspended' }));

    await waitFor(() => {
      expect(bodyRows('All members')).toHaveLength(1);
    });
  });
});

describe('Farmer and plot detail', () => {
  it('shows a pending farmer with approve, GI status and the mobile-only plot note', async () => {
    const user = userEvent.setup();
    renderApp(`/members/${MOCK_PENDING_FARMER_ID}`, true);

    expect(await screen.findByRole('heading', { name: 'Muthu Kumar' })).toBeInTheDocument();
    expect(
      screen.getByText('GI status: Not registered as a GI authorised user'),
    ).toBeInTheDocument();
    expect(screen.getByText(/"Add another plot" is done in the mobile app/)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Approve as member' }));
    expect(await screen.findByText('Active')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Approve as member' })).not.toBeInTheDocument();
  });

  it('shows the GI number of an active farmer', async () => {
    renderApp(`/members/${MOCK_ACTIVE_FARMER_ID}`, true);
    expect(
      await screen.findByText('GI status: GI authorised user no. GI-AU-883-0010'),
    ).toBeInTheDocument();
  });

  it('shows the plot location status, declared vs walked area and the map with the GI outline', async () => {
    renderApp(`/members/plots/${MOCK_PLOT_ID}`, true);

    expect(await screen.findByText('Near the GI region edge')).toBeInTheDocument();
    expect(screen.getByText('Declared area: 2.50 acre')).toBeInTheDocument();
    expect(screen.getByText('Walked area: 3.20 acre')).toBeInTheDocument();
    expect(screen.getByText(/more than 20 %/)).toBeInTheDocument();
    expect(await screen.findByText('map at 9.5121,77.9606 with GI outline')).toBeInTheDocument();
  });
});

describe('Processors page', () => {
  it('registers a processor and lists it', async () => {
    const user = userEvent.setup();
    renderApp('/processors', true);

    expect(await screen.findByText('No processor registered yet.')).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Register processor' }));
    expect(await screen.findByText('Enter the registered name.')).toBeInTheDocument();

    await user.type(screen.getByLabelText(/Registered name/), 'Sattur Spices Pvt Ltd');
    await user.type(screen.getByLabelText('FSSAI licence no.'), '12419999000123');
    await user.click(screen.getByRole('button', { name: 'Register processor' }));

    const row = await screen.findByRole('row', { name: /Sattur Spices Pvt Ltd/ });
    expect(row).toHaveTextContent('Company');
    expect(row).toHaveTextContent('12419999000123');
  });
});

describe('bbox', () => {
  it('spans every ring of a MultiPolygon and adds the padding', () => {
    const geometry = {
      type: 'MultiPolygon',
      coordinates: [
        [
          [
            [77.7, 9.3],
            [78.0, 9.5],
            [77.7, 9.3],
          ],
        ],
        [
          [
            [78.3, 9.8],
            [78.1, 9.4],
            [78.3, 9.8],
          ],
        ],
      ],
    };
    expect(bbox(geometry)).toEqual([77.7, 9.3, 78.3, 9.8]);
    expect(bbox(geometry, 0.5)).toEqual([77.2, 8.8, 78.8, 10.3]);
    expect(bbox({ type: 'Polygon', coordinates: [] })).toBeNull();
  });
});
