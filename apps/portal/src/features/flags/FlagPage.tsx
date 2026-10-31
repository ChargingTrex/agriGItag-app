/**
 * Flag detail: the rule's `details` laid out per rule family (location, yield, quantity chain, practice tags),
 * evidence photos and GI state for lot flags, and the resolve form (outcome, coded reason, note).
 * Serves: FR70 (review outcome, method, reason), FR68 (hold cleared only by the FPO admin), FR56 (practice-tag
 * contradiction), FR61 (evidence photos), Dataflow "Review & flags", plan §7.3 P02 ("required fields block
 * submit"). Called by: src/AppRoutes.tsx (`/flags/:flagId`); rows of `FlagsTable` link here.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import LinearProgress from '@mui/material/LinearProgress';
import Link from '@mui/material/Link';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { Link as RouterLink, useParams } from 'react-router';
import { z } from 'zod';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import {
  dayMonth,
  isActive,
  REASON_CODES,
  resolveBlock,
  RESOLUTIONS,
  ROLE_LABEL,
  ruleText,
  STATUS_LABEL,
  type FlagOut,
} from './flagModel';
import { SeverityChip, SubjectLink } from './FlagsPage';
import { EvidencePhotos, LotHoldState } from './LotPage';

type Details = Record<string, unknown>;

/**
 * Turns a details value into text: lists joined, objects as `key value` pairs.
 * @param value Any JSON value from `details`.
 * @returns Display text.
 */
function text(value: unknown): string {
  if (Array.isArray(value)) return value.map(text).join(', ') || 'none';
  if (value === null || value === undefined) return '—';
  if (typeof value === 'object') {
    return Object.entries(value)
      .map(([k, v]) => `${k.replaceAll('_', ' ')} ${text(v)}`)
      .join(', ');
  }
  return typeof value === 'string' ? value : JSON.stringify(value);
}

/**
 * Rows of label/value pairs.
 * @param props Component props.
 * @param props.rows `[label, value]` pairs; rows whose value is undefined are dropped.
 * @returns A description list.
 */
function Facts({ rows }: { rows: [string, unknown][] }) {
  return (
    <Stack component="dl" spacing={0.5} sx={{ m: 0 }}>
      {rows
        .filter(([, value]) => value !== undefined)
        .map(([label, value]) => (
          <Stack key={label} direction="row" spacing={1}>
            <Typography component="dt" sx={{ fontWeight: 600 }}>
              {label}:
            </Typography>
            <Typography component="dd" sx={{ m: 0 }}>
              {text(value)}
            </Typography>
          </Stack>
        ))}
    </Stack>
  );
}

/**
 * The rule inputs behind a flag, laid out for its family.
 * @param props Component props.
 * @param props.flag The flag.
 * @returns The facts; unknown keys are listed as they come.
 */
function DetailsView({ flag }: { flag: FlagOut }) {
  const d: Details = flag.details ?? {};
  const family = ruleText(flag.rule_code).family;
  if (family === 'yield' && d['harvested_kg'] !== undefined) {
    const kg = Number(d['harvested_kg']);
    const acres = Number(d['declared_acres']);
    return (
      <Facts
        rows={[
          ['Harvested', `${text(d['harvested_kg'])} kg`],
          ['Declared area', `${text(d['declared_acres'])} acre`],
          ['Yield', acres > 0 ? `${(kg / acres).toFixed(0)} kg/acre` : 'area unknown'],
          ['Ceiling', `${text(d['ceiling_kg_per_acre'])} kg/acre`],
          ['Warning above', `${text(d['warn_margin_pct'])} % over the ceiling`],
          ['Hold above', `${text(d['hold_margin_pct'])} % over the ceiling`],
        ]}
      />
    );
  }
  if (family === 'quantity' && Array.isArray(d['problems'])) {
    const unit = text(d['unit'] ?? 'kg');
    const chain = ['harvested', 'packed', 'received', 'used']
      .filter((step) => d[step] !== undefined)
      .map((step) => `${step} ${text(d[step])} ${unit}`)
      .join(' → ');
    const problems = (d['problems'] as Details[]).map(
      (p) => `${text(p['from'])} → ${text(p['to'])}: ${text(p['variance_pct'])} %`,
    );
    return (
      <Facts
        rows={[
          ['Quantity chain', chain],
          ['Out of tolerance', problems],
        ]}
      />
    );
  }
  if (family === 'practice') {
    return (
      <Facts
        rows={[
          ['Declared practice', d['declared']],
          ['Practice from inputs', d['derived']],
          ['Inputs used', d['input_categories']],
        ]}
      />
    );
  }
  // Location rules and the rest: the API sends radii, buffers, accuracies, taluks with their units in the key.
  const rows = Object.entries(d).map(([k, v]): [string, unknown] => [k.replaceAll('_', ' '), v]);
  return rows.length > 0 ? (
    <Facts rows={rows} />
  ) : (
    <Typography color="text.secondary">The rule sent no further details.</Typography>
  );
}

const resolveForm = z.object({
  resolution: z.enum(['looks_fine', 'fixed', 'escalated'], { error: 'Choose an outcome.' }),
  reason_code: z.string().min(1, 'Choose a reason.'),
  note: z.string().trim().max(1000, 'Keep the note under 1000 characters.'),
});

/**
 * Resolve form: outcome, coded reason (required, else the API answers 422 `reason_required`) and a note. On
 * success every `flags` and `lots` query is refetched, so the list, the lot's GI state and P03's ready lots
 * update without a reload.
 * @param props Component props.
 * @param props.flag The flag to resolve.
 * @param props.blocked Why the user may not resolve it, or null.
 * @returns The form; disabled with the reason when `blocked`.
 */
function ResolveForm({ flag, blocked }: { flag: FlagOut; blocked: string | null }) {
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const form = useForm({
    resolver: zodResolver(resolveForm),
    defaultValues: { reason_code: '', note: '' },
  });
  const resolve = useMutation({
    mutationFn: (values: z.infer<typeof resolveForm>) =>
      unwrap(
        api.POST('/v1/flags/{flag_id}/resolve', {
          params: { path: { flag_id: flag.id } },
          body: { ...values, note: values.note || null },
        }),
      ),
    onSuccess: () =>
      Promise.all([
        queryClient.invalidateQueries({ queryKey: ['flags'] }),
        queryClient.invalidateQueries({ queryKey: ['lots'] }),
      ]),
  });
  const { errors } = form.formState;
  const disabled = blocked !== null || resolve.isPending;

  return (
    <Paper
      component="form"
      noValidate
      aria-labelledby="resolve-heading"
      sx={{ p: 3, maxWidth: 560 }}
      onSubmit={(event) =>
        void form.handleSubmit((values) => {
          resolve.mutate(values);
        })(event)
      }
    >
      <Stack spacing={2}>
        <Typography id="resolve-heading" component="h2" variant="h6">
          Resolve this flag
        </Typography>
        {blocked && <Alert severity="info">{blocked}</Alert>}
        {resolve.isError && <Alert severity="error">{errorMessage(resolve.error)}</Alert>}
        <TextField
          {...form.register('resolution')}
          select
          label="Outcome"
          required
          disabled={disabled}
          error={Boolean(errors.resolution)}
          helperText={errors.resolution?.message}
          slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
        >
          <option value="">Choose an outcome</option>
          {Object.entries(RESOLUTIONS).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </TextField>
        <TextField
          {...form.register('reason_code')}
          select
          label="Reason"
          required
          disabled={disabled}
          error={Boolean(errors.reason_code)}
          helperText={errors.reason_code?.message}
          slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
        >
          <option value="">Choose a reason</option>
          {Object.entries(REASON_CODES).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </TextField>
        <TextField
          {...form.register('note')}
          label="Note (method, evidence, what changed)"
          multiline
          minRows={2}
          disabled={disabled}
          error={Boolean(errors.note)}
          helperText={errors.note?.message}
        />
        <Button
          type="submit"
          variant="contained"
          size="large"
          disabled={disabled}
          sx={{ alignSelf: 'start' }}
        >
          Save review
        </Button>
      </Stack>
    </Paper>
  );
}

/**
 * The flag page for the `:flagId` route parameter.
 * @returns The flag, its details, evidence and the resolve form (or the recorded resolution).
 */
export function FlagPage() {
  const { flagId = '' } = useParams();
  const { api, session } = useAuth();
  const flag = useQuery({
    queryKey: ['flags', 'detail', flagId],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/flags/{flag_id}', { params: { path: { flag_id: flagId } }, signal })),
  });

  if (flag.isPending) return <LinearProgress aria-label="Loading flag" />;
  if (flag.isError) return <Alert severity="error">{errorMessage(flag.error)}</Alert>;
  const f = flag.data;
  const rule = ruleText(f.rule_code);
  const lotId = f.subject_type === 'lot' ? f.subject_id : null;

  return (
    <Stack spacing={3}>
      <Button component={RouterLink} to="/flags" sx={{ alignSelf: 'start' }}>
        Back to flags
      </Button>
      <Stack direction="row" spacing={2} sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
        <Typography component="h1" variant="h4">
          {rule.en}
        </Typography>
        <SeverityChip severity={f.severity} />
        <Chip size="small" variant="outlined" label={STATUS_LABEL[f.status]} />
      </Stack>
      {rule.ta && <Typography lang="ta">{rule.ta}</Typography>}

      <Paper sx={{ p: 2 }}>
        <Stack spacing={1}>
          <Typography>
            On: <SubjectLink flag={f} />
          </Typography>
          <Typography>Raised on {dayMonth(f.raised_at)}</Typography>
          <Typography>
            Assigned to: {(f.assigned_role && ROLE_LABEL[f.assigned_role]) ?? 'Nobody'}
          </Typography>
          {f.subject_type === 'plot' && (
            <Link component={RouterLink} to={`/members/plots/${f.subject_id}`}>
              Review the plot on the map
            </Link>
          )}
        </Stack>
      </Paper>

      <section aria-labelledby="details-heading">
        <Typography id="details-heading" component="h2" variant="h6" gutterBottom>
          What the rule found
        </Typography>
        <DetailsView flag={f} />
      </section>

      {lotId && (
        <section aria-labelledby="lot-heading">
          <Typography id="lot-heading" component="h2" variant="h6" gutterBottom>
            Lot and evidence
          </Typography>
          <Stack spacing={2}>
            <LotHoldState lotId={lotId} />
            <EvidencePhotos lotId={lotId} />
          </Stack>
        </section>
      )}
      {f.subject_type === 'event' && (
        // The flag names only the event id; its lot (and so its photos) is not in FlagOut yet (TODO.md P02).
        <Typography color="text.secondary">
          Evidence photos of this entry are on the farmer&apos;s timeline in the mobile app.
        </Typography>
      )}

      {isActive(f) ? (
        <ResolveForm flag={f} blocked={resolveBlock(f, session?.roles ?? [])} />
      ) : (
        <Alert severity="success">
          {STATUS_LABEL[f.status]}
          {f.resolved_at && ` on ${dayMonth(f.resolved_at)}`}
          {f.resolution_reason_code && `: ${f.resolution_reason_code.replaceAll('_', ' ')}`}
          {f.resolution_note && ` (${f.resolution_note})`}
        </Alert>
      )}
    </Stack>
  );
}
