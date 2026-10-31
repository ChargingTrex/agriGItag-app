/**
 * Ready lots screen: the FPO's received lots with tick boxes, a running total and each farmer's share %,
 * greyed lots with the reason, a non-GI toggle, the processor, and "Create batch".
 * Serves: FR9 (sale to processor merges lots into a batch with a batch ID), FR29 (out-of-GI or held lots stay
 * out of a GI batch), FR60 (share % per farmer), User Flows §"Create a batch", Dataflow Stage 7, plan §7.3 P03.
 * Called by: src/AppRoutes.tsx (`/ready-lots`); `useFarmerNames` and `GateReasons` also by BatchPage.tsx.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import Chip from '@mui/material/Chip';
import FormControlLabel from '@mui/material/FormControlLabel';
import Link from '@mui/material/Link';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Switch from '@mui/material/Switch';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useMutation, useQueries, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link as RouterLink, useNavigate } from 'react-router';
import { unwrap } from '../../api/client';
import { useCursorList } from '../../api/cursor';
import { ApiError, errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';
import { useLotHold } from '../flags/LotPage';
import { ruleText } from '../flags/flagModel';
import { formatKg, lotBlock, splitShares, toGrams, type LotOut } from './batchModel';

/** The API's largest page: a season's received lots of one FPO fit in one or two pages. */
const PAGE = 200;

/**
 * One cursor-paginated lot list for a status.
 * @param status `?status=` filter.
 * @returns `useCursorList` result over `GET /v1/lots`.
 */
function useLots(status: components['schemas']['LotStatus']) {
  const { api } = useAuth();
  return useCursorList<LotOut>({
    queryKey: ['lots', { status }],
    limit: PAGE,
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(api.GET('/v1/lots', { params: { query: { status, cursor, limit } }, signal })),
  });
}

/**
 * Farmer names for a set of farmer ids, one cached `GET /v1/farmers/{id}` each (the key FarmerPage uses).
 * Only `name` is read: no phone or ID field reaches this screen.
 * @param ids Farmer ids; duplicates are fetched once.
 * @returns Name per farmer id for the farmers loaded so far (a missing one shows its id prefix).
 */
export function useFarmerNames(ids: readonly string[]): (id: string) => string {
  const { api } = useAuth();
  // shortcut: one cached request per farmer (fine for a season's few dozen lots); use a batch read or names
  //   on `LotOut` if an FPO lists hundreds of lots at once.
  const unique = [...new Set(ids)];
  const results = useQueries({
    queries: unique.map((id) => ({
      queryKey: ['farmers', 'detail', id],
      queryFn: ({ signal }: { signal: AbortSignal }) =>
        unwrap(api.GET('/v1/farmers/{farmer_id}', { params: { path: { farmer_id: id } }, signal })),
    })),
  });
  const names = new Map(unique.map((id, i) => [id, results[i]?.data?.name]));
  return (id) => names.get(id) ?? `Farmer ${id.slice(0, 8)}`;
}

/** One unmet condition from a 409 `gate_not_met` (D-033 `details.reasons[]`). */
interface GateReason {
  /** snake_case reason code. */
  code: string;
  /** English explanation from the server. */
  message?: string;
}

/**
 * The reasons of a refused gate as a list, or the plain error message for any other failure.
 * @param props Component props.
 * @param props.error What the mutation threw.
 * @returns An error alert.
 */
export function GateReasons({ error }: { error: unknown }) {
  // DECISION D-033: a refused gate answers one 409 listing every unmet reason, so the admin fixes them all
  //   before retrying.
  //   ADV: one round trip shows the whole list; the codes are stable for tests.
  //   COMPROMISE: reason texts are the server's English `message`; Tamil reason texts wait for a shared table.
  const reasons =
    error instanceof ApiError && error.code === 'gate_not_met'
      ? ((error.details as { reasons?: GateReason[] } | undefined)?.reasons ?? [])
      : [];
  return (
    <Alert severity="error">
      {errorMessage(error)}
      {reasons.length > 0 && (
        <ul aria-label="Unmet conditions">
          {reasons.map((r, i) => (
            <li key={`${r.code}-${String(i)}`}>{r.message ?? r.code.replaceAll('_', ' ')}</li>
          ))}
        </ul>
      )}
    </Alert>
  );
}

/**
 * Secondary hint from P02's hold-flag hook: names the lot's active hold flags. Greying itself follows the
 * server's `gi_eligible`; this only explains it (or warns early when B08 has not synced the lot yet).
 * @param props Component props.
 * @param props.lotId The lot.
 * @returns A caption naming the holds, or nothing.
 */
function HoldHint({ lotId }: { lotId: string }) {
  const hold = useLotHold(lotId);
  const holds = hold.data?.holds ?? [];
  if (holds.length === 0) return null;
  return (
    <Typography variant="caption" component="p" color="error">
      Hold flag: {holds.map((f) => ruleText(f.rule_code).en).join(', ')}
    </Typography>
  );
}

/**
 * The Ready lots page.
 * @returns Lots table, running total with share preview, batch options and the Create button.
 */
export function ReadyLotsPage() {
  const { api } = useAuth();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const received = useLots('received');
  const waiting = useLots('ready_for_sale');
  const lots = [...received.items, ...waiting.items];
  const farmerName = useFarmerNames(lots.map((lot) => lot.farmer_id));
  const processors = useQuery({
    queryKey: ['processors'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/processors', { signal })),
  });
  const features = useQuery({
    queryKey: ['config', 'features'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/config/features', { signal })),
  });
  const [ticked, setTicked] = useState<string[]>([]);
  const [nonGi, setNonGi] = useState(false);
  const [processorId, setProcessorId] = useState('');
  // DECISION D-005: the batch id is a client-generated UUID sent as `client_id`, made once per form.
  //   ADV: a double click or a resend after a lost answer returns the same batch (200), never a second one.
  //   COMPROMISE: after a refused create the same id is reused, which is fine because nothing was stored.
  const [clientId] = useState(() => crypto.randomUUID());

  // Tick order is the order sent to the server, so a tie for the rounding residual lands on the same lot.
  const selected = ticked.flatMap((id) => {
    const lot = lots.find((l) => l.id === id);
    return lot?.packed && !lotBlock(lot, nonGi) ? [[id, toGrams(lot.packed.value)] as const] : [];
  });
  const shares = splitShares(selected);
  const totalGrams = selected.reduce((sum, [, grams]) => sum + grams, 0);
  const thresholdKg = features.data?.second_signoff_threshold_kg;
  const needsSignoff = thresholdKg !== undefined && totalGrams > toGrams(thresholdKg);

  const create = useMutation({
    mutationFn: () =>
      unwrap(
        api.POST('/v1/batches', {
          body: {
            client_id: clientId,
            lot_ids: selected.map(([id]) => id),
            processor_id: processorId,
            gi_label_requested: !nonGi,
          },
        }),
      ),
    onSuccess: (batch) => {
      void queryClient.invalidateQueries({ queryKey: ['lots'] });
      void navigate(`/batches/${batch.id}`);
    },
    // A refusal may mean a lot changed state (batched by another admin): reload the list.
    onError: () => queryClient.invalidateQueries({ queryKey: ['lots'] }),
  });

  const createBlock =
    selected.length === 0
      ? 'Tick at least one lot.'
      : !processorId
        ? 'Choose the processor.'
        : null;

  /**
   * Ticks or unticks a lot.
   * @param id Lot id.
   */
  const toggle = (id: string) => {
    setTicked((ids) => (ids.includes(id) ? ids.filter((x) => x !== id) : [...ids, id]));
  };

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Ready lots
      </Typography>
      {(received.isError || waiting.isError) && (
        <Alert severity="error">{errorMessage(received.error ?? waiting.error)}</Alert>
      )}
      {received.isSuccess && waiting.isSuccess && lots.length === 0 && (
        <Typography color="text.secondary">No lot has been received yet.</Typography>
      )}
      {lots.length > 0 && (
        <Table size="small" aria-label="Ready lots">
          <TableHead>
            <TableRow>
              <TableCell padding="checkbox">Tick</TableCell>
              <TableCell>Farmer</TableCell>
              <TableCell>Lot</TableCell>
              <TableCell align="right">Packed</TableCell>
              <TableCell>GI</TableCell>
              <TableCell align="right">Share</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {lots.map((lot) => {
              const block = lotBlock(lot, nonGi);
              const label = block ? `Lot ${lot.code}: ${block}` : `Tick lot ${lot.code}`;
              return (
                <TableRow key={lot.id} sx={block ? { '& td': { color: 'text.disabled' } } : {}}>
                  <TableCell padding="checkbox">
                    {/* A disabled input fires no hover events, so the tooltip sits on a wrapper. */}
                    <Tooltip title={block ?? ''} describeChild>
                      <span>
                        <Checkbox
                          checked={!block && ticked.includes(lot.id)}
                          disabled={block !== null}
                          onChange={() => {
                            toggle(lot.id);
                          }}
                          slotProps={{ input: { 'aria-label': label } }}
                        />
                      </span>
                    </Tooltip>
                  </TableCell>
                  <TableCell>{farmerName(lot.farmer_id)}</TableCell>
                  <TableCell>{lot.code}</TableCell>
                  <TableCell align="right">
                    {lot.packed ? formatKg(toGrams(lot.packed.value)) : '—'}
                  </TableCell>
                  <TableCell>
                    <Chip
                      size="small"
                      label={lot.gi_eligible ? 'GI eligible' : 'Not GI eligible'}
                      color={lot.gi_eligible ? 'success' : 'default'}
                    />
                    <HoldHint lotId={lot.id} />
                  </TableCell>
                  <TableCell align="right">
                    {shares.has(lot.id) ? `${shares.get(lot.id) ?? ''} %` : ''}
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      )}
      {(received.hasNextPage || waiting.hasNextPage) && (
        <Button
          sx={{ alignSelf: 'start' }}
          onClick={() => {
            for (const list of [received, waiting]) if (list.hasNextPage) void list.fetchNextPage();
          }}
        >
          Load more
        </Button>
      )}

      <Paper
        variant="outlined"
        sx={{ p: 2 }}
        component="section"
        aria-labelledby="new-batch-heading"
      >
        <Stack spacing={2}>
          <Typography id="new-batch-heading" component="h2" variant="h6">
            New batch
          </Typography>
          <Typography aria-live="polite">
            {selected.length} {selected.length === 1 ? 'lot' : 'lots'} ticked, total{' '}
            <strong>{formatKg(totalGrams)}</strong>
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Shares are a preview from packed weight; the batch keeps the shares of the weight
            received at intake.
          </Typography>
          {needsSignoff && (
            <Alert severity="info">
              Above {formatKg(toGrams(thresholdKg))}: a second FPO admin must sign off this batch
              before it can be published.
            </Alert>
          )}
          <FormControlLabel
            control={
              <Switch
                checked={nonGi}
                onChange={(event) => {
                  setNonGi(event.target.checked);
                }}
              />
            }
            label="Non-GI batch (allows lots outside the GI region or on hold; no GI label)"
          />
          <TextField
            select
            label="Processor"
            value={processorId}
            onChange={(event) => {
              setProcessorId(event.target.value);
            }}
            sx={{ maxWidth: 400 }}
            helperText={
              processors.isSuccess && processors.data.length === 0 ? (
                <Link component={RouterLink} to="/processors">
                  Register a processor first
                </Link>
              ) : (
                'The processor that received these lots at intake.'
              )
            }
          >
            {(processors.data ?? []).map((p) => (
              <MenuItem key={p.id} value={p.id}>
                {p.name}
              </MenuItem>
            ))}
          </TextField>
          {create.isError && <GateReasons error={create.error} />}
          <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
            <Button
              variant="contained"
              disabled={createBlock !== null || create.isPending}
              onClick={() => {
                create.mutate();
              }}
            >
              {nonGi ? 'Create non-GI batch' : 'Create batch'}
            </Button>
            {createBlock && <Typography color="text.secondary">{createBlock}</Typography>}
          </Stack>
        </Stack>
      </Paper>
    </Stack>
  );
}
