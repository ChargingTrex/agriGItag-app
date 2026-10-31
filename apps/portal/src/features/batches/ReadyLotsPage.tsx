/**
 * Ready lots screen: the FPO's received lots with tick boxes, a running total and each farmer's share %,
 * greyed lots with the reason, a non-GI toggle, the processor, and "Create batch".
 * Serves: FR9 (sale to processor merges lots into a batch with a batch ID), FR29 (out-of-GI or held lots stay
 * out of a GI batch), FR60 (share % per farmer), User Flows §"Create a batch", Dataflow Stage 7, plan §7.3 P03.
 * Called by: src/AppRoutes.tsx (`/ready-lots`); `useFarmerNames`, `GateReasons` and `GatedButton` also by
 * BatchPage.tsx and PublishSection.tsx.
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
import { useHoldFlags, useLotHold } from '../flags/LotPage';
import { ruleText } from '../flags/flagModel';
import {
  formatKg,
  gateReasonText,
  lotBlock,
  splitShares,
  toGrams,
  type GateReason,
  type LotOut,
} from './batchModel';

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
  //   COMPROMISE: known codes get the portal's labels (`gateReasonText`), others the server's English
  //   `message`; Tamil reason texts wait for a shared table.
  // A resend under the same `client_id` with another processor: the first create went through.
  if (error instanceof ApiError && error.code === 'client_id_conflict') {
    return (
      <Alert severity="error">This batch was already created; reload the page and try again.</Alert>
    );
  }
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
            <li key={`${r.code}-${String(i)}`}>{gateReasonText(r)}</li>
          ))}
        </ul>
      )}
    </Alert>
  );
}

/**
 * A button that, while greyed, says why: the reasons sit next to it and are part of its accessible name, so
 * they reach keyboard and screen-reader users, not only on hover (plan §7.3 P04 "grey-button reasons").
 * @param props Component props.
 * @param props.label Visible button text.
 * @param props.reasons Why it is unavailable; empty when it may be pressed.
 * @param props.busy True while its request runs (greyed without a reason).
 * @param props.onClick Called on press.
 * @returns The button with its reasons.
 */
export function GatedButton(props: {
  label: string;
  reasons: readonly string[];
  busy?: boolean;
  onClick: () => void;
}) {
  const { label, reasons, busy = false, onClick } = props;
  const blocked = reasons.length > 0;
  return (
    <Stack direction="row" spacing={2} useFlexGap sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
      <Button
        variant="contained"
        disabled={blocked || busy}
        aria-label={blocked ? `${label}: ${reasons.join('; ')}` : undefined}
        onClick={onClick}
      >
        {label}
      </Button>
      {blocked && (
        <Stack component="ul" sx={{ m: 0, pl: 2 }}>
          {reasons.map((r, i) => (
            // Two lots can carry the same hold, so the text alone is not a unique key.
            <Typography key={`${String(i)}-${r}`} component="li" color="text.secondary">
              {r}
            </Typography>
          ))}
        </Stack>
      )}
    </Stack>
  );
}

/**
 * Secondary hint from P02's hold-flag hook: names the lot's active hold flags. Greying itself follows the
 * server's `gi_eligible` and the plot holds; this only explains it (or warns early when B08 has not synced yet).
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
  const { api, session } = useAuth();
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
  // B08 raises `plot_outside_gi_region` (and other plot holds) on the plot and leaves the lot `gi_eligible`, so
  // plot holds come from the hold flags the hint already loads (no extra request).
  const holdFlags = useHoldFlags();
  const plotHolds = new Map<string, string[]>();
  for (const flag of holdFlags.data?.flags ?? []) {
    if (flag.subject_type === 'plot') {
      plotHolds.set(flag.subject_id, [...(plotHolds.get(flag.subject_id) ?? []), flag.rule_code]);
    }
  }
  /**
   * Why a lot cannot be ticked now.
   * @param lot The lot.
   * @returns The reason, or null.
   */
  const blockOf = (lot: LotOut) => lotBlock(lot, nonGi, plotHolds.get(lot.plot_id));

  // Tick order is the order sent to the server, so a tie for the rounding residual lands on the same lot.
  const selected = ticked.flatMap((id) => {
    const lot = lots.find((l) => l.id === id);
    return lot && !blockOf(lot) ? [[id, lot.packed ? toGrams(lot.packed.value) : 0] as const] : [];
  });
  // A lot without a packing event is still batched (from intake kg) but leaves no basis for a preview.
  const previewable = selected.every(([, grams]) => grams > 0);
  const shares = previewable ? splitShares(selected) : new Map<string, string>();
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

  // UI mirror only; the server re-checks the role (403).
  const createBlock = !session?.roles.includes('fpo_admin')
    ? 'Only an FPO admin can create a batch.'
    : selected.length === 0
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
      {holdFlags.data?.complete === false && (
        <Alert severity="warning">
          Not every hold flag was loaded; the server re-checks GI when you create the batch.
        </Alert>
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
              const block = blockOf(lot);
              const label = block ? `Lot ${lot.code}: ${block}` : `Tick lot ${lot.code}`;
              return (
                // text.secondary, not text.disabled: greyed rows stay readable (4.5:1, axe colour-contrast, P07).
                <TableRow key={lot.id} sx={block ? { '& td': { color: 'text.secondary' } } : {}}>
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
                  <TableCell>
                    {lot.code}
                    {/* Visible too: the tooltip alone is out of reach for sighted keyboard users. */}
                    {block && (
                      <Typography variant="caption" component="p">
                        {block}
                      </Typography>
                    )}
                  </TableCell>
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
                    {shares.has(lot.id)
                      ? `${shares.get(lot.id) ?? ''} %`
                      : selected.some(([id]) => id === lot.id)
                        ? '—'
                        : ''}
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
            {previewable
              ? 'Shares are a preview from packed weight; the batch keeps the shares of the weight received at intake.'
              : 'A ticked lot has no packed weight: shares are computed from the weight received at intake when you create the batch.'}
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
            label="Non-GI batch: lots outside the GI region or above the yield ceiling can join. The public page shows no GI badge."
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
          <GatedButton
            label={nonGi ? 'Create non-GI batch' : 'Create batch'}
            reasons={createBlock ? [createBlock] : []}
            busy={create.isPending}
            onClick={() => {
              create.mutate();
            }}
          />
        </Stack>
      </Paper>
    </Stack>
  );
}
