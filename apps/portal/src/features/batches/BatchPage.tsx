/**
 * The batch just created (and the page a second admin opens to sign it off): batch ID and code, QR / public
 * link placeholder, GI state, each farmer's final share, and the second sign-off state.
 * Serves: User Flows §"Create a batch" step 4 (batch ID and QR), FR9, FR29 (GI verified or the reasons it is
 * not), FR60 (shares), Dataflow §4 gate 2 (second sign-off above `second_signoff_threshold_kg`), plan §7.3 P03.
 * P04 extends this page into the batch detail (grading, approve, publish, preview).
 * Called by: src/AppRoutes.tsx (`/batches/:batchId`); ReadyLotsPage.tsx navigates here after Create.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useParams } from 'react-router';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { formatKg, giReasonText, signoffBlock, toGrams, type BatchOut } from './batchModel';
import { GateReasons, useFarmerNames } from './ReadyLotsPage';

/**
 * The second sign-off line: done, waiting with a Sign-off button for another admin, or nothing when the batch
 * is under the threshold.
 * @param props Component props.
 * @param props.batch The batch.
 * @returns The sign-off section or null.
 */
function SecondSignoff({ batch }: { batch: BatchOut }) {
  const { api, session } = useAuth();
  const queryClient = useQueryClient();
  const me = useQuery({
    queryKey: ['me'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/me', { signal })),
  });
  const signoff = useMutation({
    mutationFn: () =>
      unwrap(
        api.POST('/v1/batches/{batch_id}/second-signoff', {
          params: { path: { batch_id: batch.id } },
        }),
      ),
    onSuccess: (updated) => {
      queryClient.setQueryData(['batches', batch.id], updated);
    },
  });
  if (!batch.second_signoff_required) return null;
  if (batch.second_signoff_by) {
    return <Alert severity="success">Second sign-off recorded.</Alert>;
  }
  const block = signoffBlock(batch, me.data?.user.id, session?.roles ?? []);
  return (
    <Stack spacing={1}>
      <Alert severity="warning">
        Waiting for a second admin: this batch is above the sign-off weight, so another FPO admin
        must sign it off before it can be published.
      </Alert>
      {signoff.isError && <GateReasons error={signoff.error} />}
      <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
        <Button
          variant="contained"
          disabled={block !== null || signoff.isPending}
          onClick={() => {
            signoff.mutate();
          }}
        >
          Sign off
        </Button>
        {block && <Typography color="text.secondary">{block}</Typography>}
      </Stack>
    </Stack>
  );
}

/**
 * The batch page for the `:batchId` route parameter.
 * @returns Batch ID, QR placeholder, GI state, sign-off state and shares; a progress bar or the error.
 */
export function BatchPage() {
  const { batchId = '' } = useParams();
  const { api } = useAuth();
  const batch = useQuery({
    queryKey: ['batches', batchId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/batches/{batch_id}', { params: { path: { batch_id: batchId } }, signal }),
      ),
  });
  const farmerName = useFarmerNames(batch.data?.shares.map((s) => s.farmer_id) ?? []);
  if (batch.isPending) return <LinearProgress aria-label="Loading batch" />;
  if (batch.isError) return <Alert severity="error">{errorMessage(batch.error)}</Alert>;
  const b = batch.data;

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Batch {b.code}
      </Typography>
      <Stack direction="row" spacing={1}>
        {b.gi_label_requested ? (
          <Chip
            label={b.gi_verified ? 'GI verified' : 'GI not verified'}
            color={b.gi_verified ? 'success' : 'warning'}
          />
        ) : (
          <Chip label="Non-GI batch" />
        )}
        {b.total_received && (
          <Chip variant="outlined" label={`Total ${formatKg(toGrams(b.total_received.value))}`} />
        )}
      </Stack>
      {b.gi_label_requested && !b.gi_verified && (
        <Alert severity="warning">
          This batch cannot carry the GI label:
          <ul aria-label="GI reasons">
            {b.gi_block_reasons.map((r, i) => (
              <li key={`${r.reason}-${String(i)}`}>{giReasonText(r)}</li>
            ))}
          </ul>
        </Alert>
      )}
      <SecondSignoff batch={b} />

      <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="qr-heading">
        <Typography id="qr-heading" component="h2" variant="h6" gutterBottom>
          Batch ID and QR
        </Typography>
        {/* TODO(B10): show `GET /v1/batches/{id}/qr.png` here once the publishing WP adds it to the contract. */}
        <Typography>
          Batch ID: <strong>{b.code}</strong>
          {b.superlot_code ? ` (super lot ${b.superlot_code})` : ''}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Reference {b.id}. The QR code opens the public page at /b/{b.code}; it is generated when
          the batch is published.
        </Typography>
      </Paper>

      <section aria-labelledby="shares-heading">
        <Typography id="shares-heading" component="h2" variant="h6" gutterBottom>
          Farmer shares
        </Typography>
        <Table size="small" aria-label="Farmer shares">
          <TableHead>
            <TableRow>
              <TableCell>Farmer</TableCell>
              <TableCell align="right">Received</TableCell>
              <TableCell align="right">Share</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {b.shares.map((s) => (
              <TableRow key={s.lot_id}>
                <TableCell>{farmerName(s.farmer_id)}</TableCell>
                <TableCell align="right">{formatKg(toGrams(s.contributed.value))}</TableCell>
                <TableCell align="right">{s.share_pct} %</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </section>
    </Stack>
  );
}
