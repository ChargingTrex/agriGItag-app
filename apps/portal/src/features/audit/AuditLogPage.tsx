/**
 * Audit log viewer: search by actor, entity type/id and date range; rows show time, actor (and the farmer an
 * assisted entry was for), action, entity and the diff keys as the API scrubbed them (`[hidden]`, `[redacted]`).
 * Serves: FR25 (audit trail with edit history), FR21 (audit review; export is per batch in P04), Dataflow Stage
 * 11, plan §7.3 P06 (Audit Log viewer), D-039 (FPO scope, scrubbed diffs). Called by: src/AppRoutes.tsx
 * (`/audit`).
 *
 * FPO admin only: the API answers 403 to other roles and the page shows that message (server authority).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
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
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { unwrap } from '../../api/client';
import { useCursorList } from '../../api/cursor';
import { errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';

type AuditRow = components['schemas']['AuditRow'];

/** Audited tables an admin usually searches (any other `entity_type` simply matches nothing). */
const ENTITY_TYPES = {
  farmers: 'Farmers',
  plots: 'Plots',
  lots: 'Lots',
  event_versions: 'Farm entries (versions)',
  batches: 'Batches',
  processors: 'Processors',
  fpos: 'FPO settings',
} as const;

/**
 * Blank or a UUID; the API answers 422 to anything else.
 * @param message Error text for a value that is neither.
 * @returns The zod schema.
 */
const optionalUuid = (message: string) => z.union([z.literal(''), z.uuid(message)]);

const searchForm = z
  .object({
    actor_user_id: optionalUuid('Enter a user id (UUID) or leave it empty.'),
    entity_type: z.string(),
    entity_id: optionalUuid('Enter a record id (UUID) or leave it empty.'),
    from: z.string(),
    to: z.string(),
  })
  .refine((v) => !v.from || !v.to || v.from <= v.to, {
    path: ['to'],
    message: 'The end date is before the start date.',
  });
type Search = z.infer<typeof searchForm>;
const EMPTY: Search = { actor_user_id: '', entity_type: '', entity_id: '', from: '', to: '' };

/**
 * Midnight in India of a calendar date, as an ISO timestamp for `from`/`to`.
 * @param date A `yyyy-mm-dd` date from a date input.
 * @param addDays Days to add (1 turns the inclusive end date into the API's exclusive `to`).
 * @returns The UTC ISO timestamp.
 */
export const istMidnight = (date: string, addDays = 0) =>
  new Date(Date.parse(`${date}T00:00:00+05:30`) + addDays * 86_400_000).toISOString();

/**
 * When an audit row was written, with year and time in India, e.g. "14 Feb 2026, 09:30".
 * @param iso ISO 8601 timestamp.
 * @returns The en-IN date and 24-hour time.
 */
export const auditTime = (iso: string) =>
  new Date(iso).toLocaleString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone: 'Asia/Kolkata',
  });

/**
 * One diff value as text: strings as stored (so `[hidden]` reads `[hidden]`), anything else as JSON, cut short.
 * @param value A JSON value from `diff`.
 * @returns Display text.
 */
export function diffText(value: unknown): string {
  if (typeof value === 'string') return value;
  const json = JSON.stringify(value);
  return json.length > 120 ? `${json.slice(0, 119)}…` : json;
}

/**
 * The diff as a description list, one key per line.
 * @param props Component props.
 * @param props.diff The row's scrubbed diff.
 * @returns The list.
 */
function DiffList({ diff }: { diff: AuditRow['diff'] }) {
  const entries = Object.entries(diff);
  if (entries.length === 0) return <>—</>;
  return (
    <>
      <Box component="dl" sx={{ m: 0 }}>
        {entries.map(([key, value]) => (
          <div key={key}>
            <Box component="dt" sx={{ display: 'inline', fontWeight: 500 }}>
              {key.replaceAll('_', ' ')}:
            </Box>{' '}
            <Box component="dd" sx={{ display: 'inline', m: 0, wordBreak: 'break-word' }}>
              {diffText(value)}
            </Box>
          </div>
        ))}
      </Box>
      {diff['change_kind'] === 'correct' && !('reason_code' in diff || 'reason_text' in diff) && (
        <Typography variant="body2" color="text.secondary">
          Reason: not in the audit log yet; see the entry history on the lot.
        </Typography>
      )}
    </>
  );
}

/**
 * The search form. Submitting replaces the active search.
 * @param props Component props.
 * @param props.onSearch Called with the validated search.
 * @returns The form.
 */
function SearchForm({ onSearch }: { onSearch: (search: Search) => void }) {
  const form = useForm({ resolver: zodResolver(searchForm), defaultValues: EMPTY });
  const { errors } = form.formState;
  const date = { inputLabel: { shrink: true } };
  return (
    <Paper
      component="form"
      noValidate
      aria-label="Search the audit log"
      sx={{ p: 2 }}
      onSubmit={(event) => void form.handleSubmit(onSearch)(event)}
    >
      <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap', alignItems: 'start' }}>
        <TextField
          {...form.register('actor_user_id')}
          label="Actor (user id)"
          error={Boolean(errors.actor_user_id)}
          helperText={errors.actor_user_id?.message}
          sx={{ minWidth: 320 }}
        />
        <TextField
          {...form.register('entity_type')}
          select
          label="Entity type"
          slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
          sx={{ minWidth: 200 }}
        >
          <option value="">Any</option>
          {Object.entries(ENTITY_TYPES).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </TextField>
        <TextField
          {...form.register('entity_id')}
          label="Entity id"
          error={Boolean(errors.entity_id)}
          helperText={errors.entity_id?.message}
          sx={{ minWidth: 320 }}
        />
        <TextField {...form.register('from')} type="date" label="From" slotProps={date} />
        <TextField
          {...form.register('to')}
          type="date"
          label="To"
          error={Boolean(errors.to)}
          helperText={errors.to?.message}
          slotProps={date}
        />
        <Button type="submit" variant="contained" size="large">
          Search
        </Button>
      </Stack>
    </Paper>
  );
}

/**
 * The audit log page.
 * @returns Search form and the cursor-paginated results.
 */
export function AuditLogPage() {
  const { api } = useAuth();
  const [search, setSearch] = useState<Search>(EMPTY);
  const list = useCursorList<AuditRow>({
    queryKey: ['audit-log', search],
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(
        api.GET('/v1/audit-log', {
          params: {
            query: {
              actor_user_id: search.actor_user_id || undefined,
              entity_type: search.entity_type || undefined,
              entity_id: search.entity_id || undefined,
              from: search.from ? istMidnight(search.from) : undefined,
              to: search.to ? istMidnight(search.to, 1) : undefined,
              cursor,
              limit,
            },
          },
          signal,
        }),
      ),
  });

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Audit log
      </Typography>
      <SearchForm onSearch={setSearch} />
      {list.isPending && <LinearProgress aria-label="Loading audit log" />}
      {list.isError && <Alert severity="error">{errorMessage(list.error)}</Alert>}
      {list.isSuccess && list.items.length === 0 && (
        <Typography color="text.secondary">No change matches the search.</Typography>
      )}
      {list.items.length > 0 && (
        <Table size="small" aria-label="Audit log">
          <TableHead>
            <TableRow>
              <TableCell>When</TableCell>
              {/* shortcut: actors show as user ids; AuditRow has no actor name and no users endpoint
                  exists (TODO.md B11 → P06). */}
              <TableCell>Actor</TableCell>
              <TableCell>Action</TableCell>
              <TableCell>Entity</TableCell>
              <TableCell>Changes</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {list.items.map((row) => (
              <TableRow key={row.id} sx={{ verticalAlign: 'top' }}>
                <TableCell>
                  <time dateTime={row.at}>{auditTime(row.at)}</time>
                </TableCell>
                <TableCell>
                  {row.actor_user_id ?? 'System'}
                  {row.on_behalf_of_farmer_id && (
                    <Typography variant="body2" color="text.secondary">
                      assisted entry for farmer {row.on_behalf_of_farmer_id}
                    </Typography>
                  )}
                </TableCell>
                <TableCell>{row.action}</TableCell>
                <TableCell>
                  {row.entity_type}
                  <Typography variant="body2" color="text.secondary">
                    {row.entity_id ?? '—'}
                  </Typography>
                </TableCell>
                <TableCell>
                  <DiffList diff={row.diff} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
      {list.hasNextPage && (
        <Button
          onClick={() => void list.fetchNextPage()}
          disabled={list.isFetchingNextPage}
          sx={{ alignSelf: 'start' }}
        >
          Load more
        </Button>
      )}
    </Stack>
  );
}
