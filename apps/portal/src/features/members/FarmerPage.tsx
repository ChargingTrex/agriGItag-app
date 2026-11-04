/**
 * Farmer detail: profile, masked mobile number with an audited "Reveal" for FPO admins, onboarding status
 * (approve when pending), GI authorised-user status, the farmer's plots with their GI location status, and a
 * link to the open flags on those plots; for FPO admins, the farmer's app devices with a Revoke (P12).
 * Serves: FR8 (approval), FR62 (GI authorised-user number), FR70 (flags of the farmer's plots), P01 acceptance
 * "phone masked except audited reveal" (B14 `phone_masked`, `GET /v1/farmers/{id}/phone`; P10), Dataflow
 * Stage 0, plan §7.3 P01 (farmer detail) and P02 (link to open flags), gap analysis "Multiple farm lands per
 * farmer" (B14 `GET /v1/farmers/{id}/plots`), B23 lost-phone sign-out (`GET /v1/users/{id}/devices`,
 * `POST /v1/devices/{id}/revoke`; the server writes the `device.revoke` audit row). Called by: src/AppRoutes.tsx (`/members/:farmerId`).
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
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
 * The user's app devices, newest first, each signed-in one with a Revoke that asks for an optional reason.
 * @param props Component props.
 * @param props.userId The farmer's app login (`FarmerOut.user_id`).
 * @returns The section; list and revoke errors show as alerts.
 */
function DevicesSection({ userId }: { userId: string }) {
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const [target, setTarget] = useState<string | null>(null);
  const [reason, setReason] = useState('');
  const queryKey = ['devices', userId];
  const devices = useQuery({
    queryKey,
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/users/{user_id}/devices', { params: { path: { user_id: userId } }, signal }),
      ),
  });
  const revoke = useMutation({
    mutationFn: (deviceId: string) =>
      unwrap(
        api.POST('/v1/devices/{device_id}/revoke', {
          params: { path: { device_id: deviceId } },
          body: { reason: reason.trim() || null },
        }),
      ),
    onSuccess: () => {
      setTarget(null);
      setReason('');
      return queryClient.invalidateQueries({ queryKey });
    },
  });

  return (
    <section aria-labelledby="devices-heading">
      <Typography id="devices-heading" component="h2" variant="h6" gutterBottom>
        Devices
      </Typography>
      {devices.isError && <Alert severity="error">{errorMessage(devices.error)}</Alert>}
      {devices.isSuccess && devices.data.length === 0 && (
        <Typography color="text.secondary">No device has signed in.</Typography>
      )}
      {devices.isSuccess && (
        <Stack spacing={1} sx={{ alignItems: 'start' }}>
          {devices.data.map((device) => (
            <Stack key={device.id} direction="row" spacing={2} sx={{ alignItems: 'center' }}>
              <Typography>
                {device.platform} {device.app_version ?? ''}, signed in{' '}
                {device.signed_in_at ? shortDate(device.signed_in_at) : 'never'}:{' '}
                {device.revoked_at ? `signed out ${shortDate(device.revoked_at)}` : 'active'}
              </Typography>
              {!device.revoked_at && (
                <Button
                  onClick={() => {
                    revoke.reset();
                    setTarget(device.id);
                  }}
                >
                  Revoke
                </Button>
              )}
            </Stack>
          ))}
        </Stack>
      )}
      <Dialog
        open={target !== null}
        onClose={() => {
          setTarget(null);
        }}
      >
        <DialogTitle>Sign this device out?</DialogTitle>
        <DialogContent>
          <TextField
            label="Reason (optional)"
            value={reason}
            onChange={(event) => {
              setReason(event.target.value);
            }}
            fullWidth
            sx={{ mt: 1 }}
          />
          {revoke.isError && <Alert severity="error">{errorMessage(revoke.error)}</Alert>}
        </DialogContent>
        <DialogActions>
          <Button
            onClick={() => {
              setTarget(null);
            }}
          >
            Cancel
          </Button>
          <Button
            variant="contained"
            disabled={revoke.isPending}
            onClick={() => {
              if (target) revoke.mutate(target);
            }}
          >
            Sign out device
          </Button>
        </DialogActions>
      </Dialog>
    </section>
  );
}

/**
 * The farmer detail page for the `:farmerId` route parameter.
 * @returns The page, a progress bar while loading, or the error message.
 */
export function FarmerPage() {
  const { farmerId = '' } = useParams();
  const { api, session } = useAuth();
  const approve = useApproveFarmer();
  // Same role as the server's check (B14: FPO admin only); the server writes the audit row on every call.
  // It also gates the Devices section: B23 lets only an FPO admin list and revoke another member's devices.
  const canReveal = session?.roles.includes('fpo_admin') === true;
  // The number lives only in this mutation's state: `gcTime: 0` drops it from the mutation cache as soon as
  // the page unmounts, and the effect below clears it (and any refusal) when the route moves to another
  // farmer, so seeing it again always takes a new, audited call.
  const reveal = useMutation({
    mutationFn: () =>
      unwrap(
        api.GET('/v1/farmers/{farmer_id}/phone', { params: { path: { farmer_id: farmerId } } }),
      ),
    gcTime: 0,
  });
  const { reset } = reveal;
  useEffect(() => {
    reset();
  }, [farmerId, reset]);
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
  // Guards the render between a route change and the reset effect (the component stays mounted).
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

      {canReveal && f.user_id && <DevicesSection userId={f.user_id} />}

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
