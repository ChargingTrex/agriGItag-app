/**
 * Batch detail: batch ID and code, status, processor, received kg, GI state with reasons, each farmer's share,
 * the second sign-off, grading (readings with source and instrument, computed grade with the standard's
 * edition, declared grade, Approve), final packing (packed kg ≤ graded kg) and the public page (Publish,
 * builds, QR, preview: PublishSection.tsx), then labels and exports (features/exports/BatchExports.tsx, P05). Every
 * greyed button says why, from the server's gate answer or a dry read of the stored batch and grade computation.
 * Serves: User Flows §"Create a batch" step 4 and §"Approve and publish", FR9, FR29 (GI verified or the reasons
 * it is not), FR48/FR49 (declared above computed blocks approval), FR60 (shares), FR62 (packing, labels), FR15
 * (publish), FR58/FR21 (CSV exports with units), Dataflow §4 gate 2 (second sign-off above
 * `second_signoff_threshold_kg`) and Stages 8–10, plan §7.3 P03, P04 (declared Special/computed Standard → Approve disabled with reason; missing reading →
 * disabled; happy path → published + URL) and P05 (labels, CSV exports).
 * Called by: src/AppRoutes.tsx (`/batches/:batchId`); ReadyLotsPage.tsx navigates here after Create;
 * BatchesPage.tsx links here.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Chip from '@mui/material/Chip';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQueries, useQuery, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { useParams } from 'react-router';
import { z } from 'zod';
import { unwrap } from '../../api/client';
import { ApiError, errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { useHoldFlags } from '../flags/LotPage';
import { dayMonth, ruleText } from '../flags/flagModel';
import {
  approveReasons,
  BATCH_STATUS,
  formatKg,
  gateReasonText,
  giReasonText,
  batchHolds,
  packReasons,
  signoffBlock,
  toGrams,
  type BatchOut,
  type GateReason,
} from './batchModel';
import { BatchExports } from '../exports/BatchExports';
import { PublishSection } from './PublishSection';
import { GatedButton, GateReasons, useFarmerNames } from './ReadyLotsPage';

/** The API's largest page: a batch has a handful of readings, an FPO a handful of instruments. */
const PAGE = 200;

const SOURCE_LABEL = { lab: 'Lab', instrument: 'Instrument', visual: 'Visual' } as const;

/** Kilograms as the API takes them: up to 3 decimals (numeric(…, 3)). */
const KG = /^\d+(\.\d{1,3})?$/;
const kgField = z
  .string()
  .trim()
  .regex(KG, 'Enter kilograms, e.g. 300 or 272.5.')
  .refine((v) => toGrams(v) > 0, 'Enter more than 0 kg.');

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
      <GatedButton
        label="Sign off"
        reasons={block ? [block] : []}
        busy={signoff.isPending}
        onClick={() => {
          signoff.mutate();
        }}
      />
    </Stack>
  );
}

/**
 * "Standard ref, edition, clause" of the profile version a grade was computed on.
 * @param cropId The batch's crop.
 * @param versionId `GradeOut.profile_version_id`; the query waits until it is known.
 * @returns TanStack query whose data is the text, or null when the version is no longer the published one.
 */
function useStandard(cropId: string, versionId: string | undefined) {
  const { api } = useAuth();
  return useQuery({
    queryKey: ['standards', cropId, versionId],
    enabled: versionId !== undefined,
    queryFn: async ({ signal }) => {
      // shortcut: GradeOut names only the version id, so this reads the crop's published versions; a grade
      //   computed on a since-retired version shows no edition. Upgrade if the API adds the edition to GradeOut.
      const profiles = await unwrap(
        api.GET('/v1/standards-profiles', { params: { query: { crop_id: cropId } }, signal }),
      );
      for (const p of profiles.items) {
        if (p.published_version_no === null) continue;
        const v = await unwrap(
          api.GET('/v1/standards-profiles/{profile_id}/versions/{version_no}', {
            params: { path: { profile_id: p.id, version_no: p.published_version_no } },
            signal,
          }),
        );
        if (v.id === versionId) return `${p.standard_ref}, edition ${v.edition}, ${v.clause_ref}`;
      }
      return null;
    },
  });
}

/**
 * Grading: the batch's readings, its latest grade computation and the Approve form (graded kg).
 * @param props Component props.
 * @param props.batch The batch.
 * @param props.isAdmin Whether the session has the `fpo_admin` role (preview; the server answers 403).
 * @param props.holds Hold reasons of the batch and its lots.
 * @returns The grading section.
 */
function GradingSection(props: { batch: BatchOut; isAdmin: boolean; holds: GateReason[] }) {
  const { batch, isAdmin, holds } = props;
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const path = { batch_id: batch.id };
  const grade = useQuery({
    queryKey: ['batches', batch.id, 'grade'],
    queryFn: async ({ signal }) => {
      try {
        return await unwrap(api.GET('/v1/batches/{batch_id}/grade', { params: { path }, signal }));
      } catch (error) {
        // 404 = never graded; the Approve preview then says so.
        if (error instanceof ApiError && error.status === 404) return null;
        throw error;
      }
    },
  });
  const readings = useQuery({
    queryKey: ['batches', batch.id, 'readings'],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/batches/{batch_id}/readings', {
          params: { path, query: { limit: PAGE } },
          signal,
        }),
      ),
  });
  const instruments = useQuery({
    queryKey: ['instruments'],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/instruments', { params: { query: { limit: PAGE } }, signal })),
  });
  const standard = useStandard(batch.crop_id, grade.data?.profile_version_id);
  const form = useForm({
    resolver: zodResolver(z.object({ graded: kgField })),
    defaultValues: { graded: '' },
  });
  const approve = useMutation({
    mutationFn: (graded: string) =>
      unwrap(
        api.POST('/v1/batches/{batch_id}/grading/approve', {
          params: { path },
          body: { graded: { value: graded, unit: 'kg' } },
        }),
      ),
    onSuccess: (updated) => {
      queryClient.setQueryData(['batches', batch.id], updated);
    },
  });
  const instrumentName = new Map(
    (instruments.data?.items ?? []).map((i) => [i.id, `${i.make_model} (${i.serial_no})`]),
  );
  const g = grade.data;
  const capped = g
    ? Object.values(g.per_parameter).filter((p) => p.capped_by_source && p.source)
    : [];

  return (
    <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="grading-heading">
      <Stack spacing={2}>
        <Typography id="grading-heading" component="h2" variant="h6">
          Grading
        </Typography>
        {readings.isError && <Alert severity="error">{errorMessage(readings.error)}</Alert>}
        {readings.isSuccess && readings.data.items.length === 0 && (
          <Typography color="text.secondary">No quality reading recorded on this batch.</Typography>
        )}
        {readings.isSuccess && readings.data.items.length > 0 && (
          <Table size="small" aria-label="Quality readings">
            <TableHead>
              <TableRow>
                <TableCell>Parameter</TableCell>
                <TableCell align="right">Value</TableCell>
                <TableCell>Source</TableCell>
                <TableCell>Instrument or lab</TableCell>
                <TableCell>Measured</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {readings.data.items.map((r) => (
                <TableRow key={r.id}>
                  <TableCell>{r.parameter_code.replaceAll('_', ' ')}</TableCell>
                  <TableCell align="right">
                    {r.measurement.value} {r.measurement.unit}
                  </TableCell>
                  <TableCell>{SOURCE_LABEL[r.source]}</TableCell>
                  <TableCell>
                    {r.source === 'lab'
                      ? `${r.lab_name ?? 'Lab'}${r.lab_nabl_no ? `, NABL ${r.lab_nabl_no}` : ''}`
                      : r.instrument_id
                        ? (instrumentName.get(r.instrument_id) ?? 'Instrument')
                        : '—'}
                  </TableCell>
                  <TableCell>{dayMonth(r.measured_at)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {grade.isPending && <LinearProgress aria-label="Loading grade" />}
        {grade.isError && <Alert severity="error">{errorMessage(grade.error)}</Alert>}
        {g && (
          <Stack spacing={0.5}>
            <Typography>
              Computed grade:{' '}
              <strong>{g.computed_grade ?? 'not computed (reading missing)'}</strong>
              {g.lab_certified ? ' (lab certified)' : ''}
            </Typography>
            <Typography>
              Declared grade: <strong>{g.declared_grade ?? '—'}</strong>
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Standard: {standard.data ?? 'profile version ' + g.profile_version_id.slice(0, 8)}.
              Computed {dayMonth(g.computed_at)}.
            </Typography>
            {capped.map((p) => (
              <Typography key={p.parameter} variant="body2" color="text.secondary">
                {p.parameter.replaceAll('_', ' ')}: capped at {p.grade ?? '—'} because the reading
                is {p.source ? SOURCE_LABEL[p.source].toLowerCase() : ''}.
              </Typography>
            ))}
          </Stack>
        )}
        {batch.status === 'created' ? (
          grade.isSuccess && (
            <Stack spacing={1}>
              <TextField
                {...form.register('graded')}
                label="Graded quantity (kg)"
                inputMode="decimal"
                sx={{ maxWidth: 240 }}
                error={Boolean(form.formState.errors.graded)}
                helperText={
                  form.formState.errors.graded?.message ?? 'Becomes the ceiling for final packing.'
                }
              />
              {approve.isError && <GateReasons error={approve.error} />}
              <GatedButton
                label="Approve grading"
                reasons={approveReasons(grade.data, isAdmin, holds).map(gateReasonText)}
                busy={approve.isPending}
                onClick={() =>
                  void form.handleSubmit((values) => {
                    approve.mutate(values.graded);
                  })()
                }
              />
            </Stack>
          )
        ) : (
          <Alert severity="success">
            Grading approved: grade {batch.computed_grade ?? '—'}
            {batch.graded ? `, ${formatKg(toGrams(batch.graded.value))} graded` : ''}.
          </Alert>
        )}
      </Stack>
    </Paper>
  );
}

/**
 * Final packing: packed kg (at most the graded kg), pack date and best-before date, or what was signed off.
 * @param props Component props.
 * @param props.batch The batch.
 * @param props.isAdmin Whether the session has the `fpo_admin` role (preview; the server answers 403).
 * @param props.holds Hold reasons of the batch and its lots.
 * @returns The final packing section.
 */
function PackingSection(props: { batch: BatchOut; isAdmin: boolean; holds: GateReason[] }) {
  const { batch, isAdmin, holds } = props;
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const gradedGrams = batch.graded ? toGrams(batch.graded.value) : 0;
  const date = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Choose a date.');
  // The server re-checks both limits (409 `packed_above_graded`, 422 best before earlier than pack date).
  const schema = z
    .object({
      packed: kgField.refine(
        (v) => toGrams(v) <= gradedGrams,
        `At most the graded ${formatKg(gradedGrams)}.`,
      ),
      pack_date: date,
      best_before_date: date,
    })
    .refine((v) => v.best_before_date >= v.pack_date, {
      path: ['best_before_date'],
      message: 'Best before cannot be earlier than the pack date.',
    });
  const form = useForm({
    resolver: zodResolver(schema),
    defaultValues: { packed: '', pack_date: '', best_before_date: '' },
  });
  const pack = useMutation({
    mutationFn: (values: z.infer<typeof schema>) =>
      unwrap(
        api.POST('/v1/batches/{batch_id}/final-packing', {
          params: { path: { batch_id: batch.id } },
          body: {
            packed: { value: values.packed, unit: 'kg' },
            pack_date: values.pack_date,
            best_before_date: values.best_before_date,
          },
        }),
      ),
    onSuccess: (updated) => {
      queryClient.setQueryData(['batches', batch.id], updated);
    },
  });
  const { errors } = form.formState;
  const done = batch.status === 'packed' || batch.status === 'published';

  return (
    <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="packing-heading">
      <Stack spacing={2}>
        <Typography id="packing-heading" component="h2" variant="h6">
          Final packing
        </Typography>
        {done ? (
          <Alert severity="success">
            Packed {batch.packed ? formatKg(toGrams(batch.packed.value)) : '—'}
            {batch.pack_date ? ` on ${dayMonth(batch.pack_date)}` : ''}
            {batch.best_before_date ? `, best before ${dayMonth(batch.best_before_date)}` : ''}.
          </Alert>
        ) : (
          <>
            <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap' }}>
              <TextField
                {...form.register('packed')}
                label="Packed quantity (kg)"
                inputMode="decimal"
                error={Boolean(errors.packed)}
                helperText={
                  errors.packed?.message ??
                  (gradedGrams ? `At most ${formatKg(gradedGrams)} graded.` : ' ')
                }
              />
              <TextField
                {...form.register('pack_date')}
                type="date"
                label="Pack date"
                slotProps={{ inputLabel: { shrink: true } }}
                error={Boolean(errors.pack_date)}
                helperText={errors.pack_date?.message ?? ' '}
              />
              <TextField
                {...form.register('best_before_date')}
                type="date"
                label="Best before"
                slotProps={{ inputLabel: { shrink: true } }}
                error={Boolean(errors.best_before_date)}
                helperText={errors.best_before_date?.message ?? ' '}
              />
            </Stack>
            {pack.isError && <GateReasons error={pack.error} />}
            <GatedButton
              label="Sign off final packing"
              reasons={packReasons(batch, isAdmin, holds).map(gateReasonText)}
              busy={pack.isPending}
              onClick={() =>
                void form.handleSubmit((values) => {
                  pack.mutate(values);
                })()
              }
            />
          </>
        )}
      </Stack>
    </Paper>
  );
}

/**
 * The batch page for the `:batchId` route parameter.
 * @returns Header, GI state, sign-off, batch ID, shares, grading, packing, the public page, labels and exports; a
 *   progress bar or the error.
 */
export function BatchPage() {
  const { batchId = '' } = useParams();
  const { api, session } = useAuth();
  const batch = useQuery({
    queryKey: ['batches', batchId],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/batches/{batch_id}', { params: { path: { batch_id: batchId } }, signal }),
      ),
  });
  const processors = useQuery({
    queryKey: ['processors'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/processors', { signal })),
  });
  const holdFlags = useHoldFlags();
  // shortcut: one cached lot read per share for its plot id (plot holds block too); fine for a batch of a few
  //   dozen lots, add plot ids to ShareOut if batches grow to hundreds.
  const lots = useQueries({
    queries: (batch.data?.shares ?? []).map((s) => ({
      queryKey: ['lots', s.lot_id],
      queryFn: ({ signal }: { signal: AbortSignal }) =>
        unwrap(api.GET('/v1/lots/{lot_id}', { params: { path: { lot_id: s.lot_id } }, signal })),
    })),
  });
  const farmerName = useFarmerNames(batch.data?.shares.map((s) => s.farmer_id) ?? []);
  if (batch.isPending) return <LinearProgress aria-label="Loading batch" />;
  if (batch.isError) return <Alert severity="error">{errorMessage(batch.error)}</Alert>;
  const b = batch.data;
  // UI preview only; every write below is re-checked by the server (403 role, 409 gate reasons).
  const isAdmin = session?.roles.includes('fpo_admin') ?? false;
  const mine = new Set([
    b.id,
    ...b.shares.map((s) => s.lot_id),
    ...lots.flatMap((q) => (q.data ? [q.data.plot_id] : [])),
  ]);
  const { blocking, allowed } = batchHolds(
    (holdFlags.data?.flags ?? []).filter((f) => mine.has(f.subject_id)),
    b.gi_label_requested,
  );
  // Fail closed while the holds are unknown (an empty list does not prove the batch is free, as in P02).
  const holds =
    holdFlags.isPending || lots.some((q) => q.isPending)
      ? [...blocking, { code: 'checking_holds' }]
      : blocking;
  const processor = processors.data?.find((p) => p.id === b.processor_id);

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Batch {b.code}
      </Typography>
      <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: 'wrap' }}>
        <Chip color="primary" label={BATCH_STATUS[b.status]} />
        {b.gi_label_requested ? (
          <Chip
            label={b.gi_verified ? 'GI verified' : 'GI not verified'}
            color={b.gi_verified ? 'success' : 'warning'}
          />
        ) : (
          <Chip label="Non-GI batch: no GI badge on the public page" />
        )}
        {b.total_received && (
          <Chip variant="outlined" label={`Total ${formatKg(toGrams(b.total_received.value))}`} />
        )}
        {processor && <Chip variant="outlined" label={`Processor ${processor.name}`} />}
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
      {holdFlags.data?.complete === false && (
        // Not a greyed reason: with more than 200 open holds it would never clear; the server re-checks.
        <Alert severity="info">
          Not every hold flag was loaded; the server re-checks the holds when you approve, pack or
          publish.
        </Alert>
      )}
      {allowed.length > 0 && (
        <Alert severity="warning">
          Open hold flags, noted:
          <ul aria-label="Warnings">
            {allowed.map((code, i) => (
              <li key={`${code}-${String(i)}`}>{ruleText(code).en}: allowed in a non-GI batch</li>
            ))}
          </ul>
        </Alert>
      )}
      <SecondSignoff batch={b} />

      <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="qr-heading">
        <Typography id="qr-heading" component="h2" variant="h6" gutterBottom>
          Batch ID and QR
        </Typography>
        <Typography>
          Batch ID: <strong>{b.code}</strong>
          {b.superlot_code ? ` (super lot ${b.superlot_code})` : ''}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Reference {b.id}. The QR code opens the public page at /b/{b.code}; it appears under
          Public page once the batch is published.
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

      <GradingSection batch={b} isAdmin={isAdmin} holds={holds} />
      <PackingSection batch={b} isAdmin={isAdmin} holds={holds} />
      <PublishSection batch={b} isAdmin={isAdmin} holds={holds} />
      <BatchExports
        batch={b}
        lots={lots.flatMap((q) => (q.data ? [q.data] : []))}
        lotsLoading={lots.some((q) => q.isPending)}
        farmerName={farmerName}
      />
    </Stack>
  );
}
