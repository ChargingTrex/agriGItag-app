/**
 * Farmer detail: profile, onboarding status (approve when pending), GI authorised-user status, and a note on
 * plots (added from the mobile app; listed here once the API can list a farmer's plots).
 * Serves: FR8 (approval), FR62 (GI authorised-user number), Dataflow Stage 0, plan §7.3 P01 (farmer detail),
 * gap analysis "Multiple farm lands per farmer". Called by: src/AppRoutes.tsx (`/members/:farmerId`).
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { FarmerStatusChip, useApproveFarmer } from './MembersPage';

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
  const { api } = useAuth();
  const approve = useApproveFarmer();
  const farmer = useQuery({
    queryKey: ['farmers', 'detail', farmerId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/farmers/{farmer_id}', { params: { path: { farmer_id: farmerId } }, signal }),
      ),
  });

  if (farmer.isPending) return <LinearProgress aria-label="Loading farmer" />;
  if (farmer.isError) return <Alert severity="error">{errorMessage(farmer.error)}</Alert>;
  const f = farmer.data;

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
        {/* TODO(B03/P01): list the farmer's plots once the API offers a per-farmer plot list. */}
        <Alert severity="info">
          Plots open from their flags or links for now; the per-farmer plot list arrives with the
          registry update. "Add another plot" is done in the mobile app by the farmer or field
          officer, because the pin is taken on the field.
        </Alert>
      </section>
    </Stack>
  );
}
