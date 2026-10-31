/**
 * Plot detail: GI location status, how the location was set, declared vs walked area, review outcome, and
 * the map (lazy chunk) with the pin and the GI region outline.
 * Serves: FR28 (GI region check), FR66/FR70 (area gap and flagged plot review), Dataflow Stage 0 (flagged
 * plot review), plan §7.3 P01 (plot detail map), §13 D3, P02 (review form and the plot's open flags).
 * Called by: src/AppRoutes.tsx (`/members/plots/:plotId`); flags and the farmer's plot list link here;
 * `LOCATION_CHIP` also by FarmerPage.tsx.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useQuery } from '@tanstack/react-query';
import { lazy, Suspense } from 'react';
import { Link, useParams } from 'react-router';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';
import { PlotReview } from '../flags/PlotReview';

type LocationStatus = components['schemas']['LocationStatus'];
type Quantity = components['schemas']['Quantity-Output'];

// The map and maplibre-gl (~300 KB gz) load only when a plot page opens, keeping the initial bundle small.
const PlotMap = lazy(() => import('./PlotMap'));

export const LOCATION_CHIP: Record<
  LocationStatus,
  { label: string; color: 'success' | 'warning' | 'error' | 'info' }
> = {
  confirmed: { label: 'Inside GI region', color: 'success' },
  near_edge: { label: 'Near the GI region edge', color: 'warning' },
  outside: { label: 'Outside GI region', color: 'error' },
  needs_review: { label: 'Needs review', color: 'info' },
};

/**
 * Formats a quantity with its unit (FR58).
 * @param quantity The API quantity.
 * @returns E.g. "2.50 acre".
 */
const qty = (quantity: Quantity) => `${quantity.value} ${quantity.unit}`;

/**
 * The plot page for the `:plotId` route parameter.
 * @returns The page, a progress bar while loading, or the error message.
 */
export function PlotPage() {
  const { plotId = '' } = useParams();
  const { api } = useAuth();
  const plot = useQuery({
    queryKey: ['plots', plotId],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/plots/{plot_id}', { params: { path: { plot_id: plotId } }, signal })),
  });
  const crops = useQuery({
    queryKey: ['crops'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/crops', { signal })),
    staleTime: Infinity,
  });
  // shortcut: a plot does not name its crop, so the outline is the first GI crop's region (the pilot has one
  // GI crop); use the plot's crop once plots carry it.
  const giTagId = crops.data?.find((crop) => crop.gi_tag_id)?.gi_tag_id ?? null;
  const region = useQuery({
    queryKey: ['gi-region', giTagId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/gi-tags/{gi_tag_id}/region', {
          params: { path: { gi_tag_id: giTagId ?? '' } },
          signal,
        }),
      ),
    enabled: giTagId !== null,
    staleTime: Infinity,
  });

  if (plot.isPending) return <LinearProgress aria-label="Loading plot" />;
  if (plot.isError) return <Alert severity="error">{errorMessage(plot.error)}</Alert>;
  const p = plot.data;
  const chip = LOCATION_CHIP[p.location_status];
  // Wait for the outline (or for knowing there is none) so the map is created once, not twice.
  const regionReady = giTagId ? !region.isPending : !crops.isPending;

  return (
    <Stack spacing={3}>
      <Button component={Link} to={`/members/${p.farmer_id}`} sx={{ alignSelf: 'start' }}>
        Back to farmer
      </Button>
      <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
        <Typography component="h1" variant="h4">
          Plot {p.code}
        </Typography>
        <Chip label={chip.label} color={chip.color} />
      </Stack>

      <Paper sx={{ p: 2 }}>
        <Stack spacing={1}>
          <Typography>Location set by: {p.location_method_label ?? 'Unknown'}</Typography>
          <Typography>Declared area: {qty(p.declared_area)}</Typography>
          <Typography>
            Walked area: {p.walked_area ? qty(p.walked_area) : 'Boundary not walked'}
          </Typography>
          {p.area_gap_pct !== null && (
            <Typography color={p.area_gap_exceeds ? 'error' : 'text.primary'}>
              Difference: {p.area_gap_pct} %
              {p.area_gap_exceeds && ' (more than 20 %: check the declared size)'}
            </Typography>
          )}
          {p.review_outcome && (
            <Typography>
              Review: {p.review_outcome} ({p.review_method ?? 'method not given'})
            </Typography>
          )}
        </Stack>
      </Paper>

      {region.isError && <Alert severity="warning">{errorMessage(region.error)}</Alert>}
      {regionReady ? (
        <Suspense fallback={<LinearProgress aria-label="Loading map" />}>
          <PlotMap pin={p.pin} region={region.data?.geometry ?? null} />
        </Suspense>
      ) : (
        <LinearProgress aria-label="Loading map" />
      )}
      <PlotReview plot={p} />
      <Button component={Link} to={`/flags?subject=${p.id}`} sx={{ alignSelf: 'start' }}>
        Open flags on this plot
      </Button>
    </Stack>
  );
}
