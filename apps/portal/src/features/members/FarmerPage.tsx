/**
 * Farmer detail: profile, masked mobile number with an audited "Reveal" for FPO admins, onboarding status
 * (approve when pending), GI authorised-user status, the farmer's plots with their GI location status, and a
 * link to the open flags on those plots.
 * Serves: FR8 (approval), FR62 (GI authorised-user number), FR70 (flags of the farmer's plots), P01 acceptance
 * "phone masked except audited reveal" (B14 `phone_masked`, `GET /v1/farmers/{id}/phone`; P10), Dataflow
 * Stage 0, plan §7.3 P01 (farmer detail) and P02 (link to open flags), gap analysis "Multiple farm lands per
 * farmer" (B14 `GET /v1/farmers/{id}/plots`). Called by: src/AppRoutes.tsx (`/members/:farmerId`).
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { FarmerStatusChip, useApproveFarmer } from './MembersPage';
import { LOCATION_CHIP } from './PlotPage';

/**
 * Formats an ISO timestamp as a short date, e.g. "14 Feb 2026".
 * @param iso ISO 8601 timestamp.
 * @returns The date in en-IN form.
 */
export const shortDate = (iso: string) =>
  new Date(iso).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });

/**
 * The farmer detail page for the `:farmerId` route parameter.
 * @returns The page, a progress bar while loading, or the error message.
 */
export function FarmerPage() {
  const { farmerId = '' } = useParams();
  const { api, session } = useAuth();
  const approve = useApproveFarmer();
  // Same role as the server's check (B14: FPO admin only); the server writes the audit row on every call.
  const canReveal = session?.roles.includes('fpo_admin') === true;
  // Held only in this mutation, never in the query cache, so the number is gone once the page is left.
  const reveal = useMutation({
    mutationFn: () =>
      unwrap(
        api.GET('/v1/farmers/{farmer_id}/phone', { params: { path: { farmer_id: farmerId } } }),
      ),
  });
  const farmer = useQuery({
    queryKey: ['farmers', 'detail', farmerId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/farmers/{farmer_id}', { params: { path: { farmer_id: farmerId } }, signal }),
      ),
  });
  // A farmer has a handful of plots (FR2), so the first page of 50 is the whole list.
  const plots = useQuery({
    queryKey: ['plots', 'farmer', farmerId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/farmers/{farmer_id}/plots', {
          params: { path: { farmer_id: farmerId } },
          signal,
        }),
      ),
  });

  if (farmer.isPending) return <LinearProgress aria-label="Loading farmer" />;
  if (farmer.isError) return <Alert severity="error">{errorMessage(farmer.error)}</Alert>;
  const f = farmer.data;
  // The page component stays mounted when the route moves to another farmer.
  const revealed = reveal.data?.farmer_id === f.id ? reveal.data.phone : null;

  return (
    <Stack spacing={3}>
      <Button component={Link} to="/members" sx={{ alignSelf: 'start' }}>
        Back to members
      </Button>
      <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
        <Typography component="h1" variant="h4">
          {f.name}
        </Typography>
        <FarmerStatusChip status={f.status} />
      </Stack>
      {f.name_local && <Typography lang="ta">{f.name_local}</Typography>}

      <Paper sx={{ p: 2 }}>
        <Stack spacing={1}>
          <Typography>Farmer code: {f.code}</Typography>
          <Typography>Address: {f.address_line || 'Not given'}</Typography>
          {f.phone_masked && (
            <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
              <Typography>Mobile: {revealed ?? f.phone_masked}</Typography>
              {canReveal && !revealed && (
                <Button
                  disabled={reveal.isPending}
                  onClick={() => {
                    reveal.mutate();
                  }}
                >
                  Reveal number
                </Button>
              )}
            </Stack>
          )}
          {reveal.isError && <Alert severity="error">{errorMessage(reveal.error)}</Alert>}
          <Typography>
            GI status:{' '}
            {f.gi_authorised_user_no
              ? `GI authorised user no. ${f.gi_authorised_user_no}`
              : 'Not registered as a GI authorised user'}
          </Typography>
          {f.no_smartphone && (
            <Typography>No smartphone: the field officer enters data (assist mode).</Typography>
          )}
          {f.approved_at && <Typography>Approved on {shortDate(f.approved_at)}</Typography>}
        </Stack>
      </Paper>

      {f.status === 'pending' && (
        <Stack spacing={1} sx={{ alignItems: 'start' }}>
          {approve.isError && <Alert severity="error">{errorMessage(approve.error)}</Alert>}
          <Button
            variant="contained"
            size="large"
            disabled={approve.isPending}
            onClick={() => {
              approve.mutate(f.id);
            }}
          >
            Approve as member
          </Button>
        </Stack>
      )}

      <section aria-labelledby="plots-heading">
        <Typography id="plots-heading" component="h2" variant="h6" gutterBottom>
          Plots
        </Typography>
        {plots.isError && <Alert severity="error">{errorMessage(plots.error)}</Alert>}
        {plots.isSuccess && (
          <Stack spacing={1} sx={{ alignItems: 'start' }}>
            {plots.data.items.map((plot) => (
              <Stack key={plot.id} direction="row" spacing={2} sx={{ alignItems: 'center' }}>
                <Button component={Link} to={`/members/plots/${plot.id}`}>
                  Plot {plot.code}
                </Button>
                <Chip size="small" {...LOCATION_CHIP[plot.location_status]} />
              </Stack>
            ))}
            {plots.data.items.length > 0 && (
              <Button
                component={Link}
                to={`/flags?subject=${plots.data.items.map((plot) => plot.id).join(',')}`}
              >
                Open flags on these plots
              </Button>
            )}
          </Stack>
        )}
        <Alert severity="info" sx={{ mt: 1 }}>
          "Add another plot" is done in the mobile app by the farmer or field officer, because the
          pin is taken on the field.
        </Alert>
      </section>
    </Stack>
  );
}
