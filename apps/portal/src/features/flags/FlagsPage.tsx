/**
 * Flags list: rule findings of the FPO with filters (status, severity, assigned role on the server; rule code
 * and subject in the browser), severity glyphs, en/ta rule labels, "14 Feb" dates and cursor paging.
 * Serves: FR70 (flagged records reviewed by the field officer or FPO admin), FR56, FR68, Dataflow "Review &
 * flags", plan §7.3 P02 and §13 C4 (cursor pages). Called by: src/AppRoutes.tsx (`/flags`); `SeverityChip`,
 * `SubjectLink` and `FlagsTable` also by FlagPage.tsx and LotPage.tsx. Farmer, plot and lot pages link here
 * with `?subject=<ids>`.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Link from '@mui/material/Link';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { Link as RouterLink, useSearchParams } from 'react-router';
import { unwrap } from '../../api/client';
import { useCursorList } from '../../api/cursor';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import {
  dayMonth,
  ROLE_LABEL,
  RULES,
  ruleText,
  SEVERITY,
  STATUS_LABEL,
  type FlagOut,
  type FlagStatus,
  type Role,
  type Severity,
} from './flagModel';

/**
 * Severity as glyph + colour + word, so it reads without colour vision.
 * @param props Component props.
 * @param props.severity The flag's severity.
 * @returns A small chip.
 */
export function SeverityChip({ severity }: { severity: Severity }) {
  const s = SEVERITY[severity];
  return (
    <Chip
      size="small"
      color={s.color}
      icon={<span aria-hidden="true">{s.glyph}</span>}
      label={s.label}
    />
  );
}

/**
 * Names the flagged record and links to its page where the portal has one (plots, lots).
 * @param props Component props.
 * @param props.flag The flag.
 * @returns A link or plain text.
 */
export function SubjectLink({ flag }: { flag: Pick<FlagOut, 'subject_type' | 'subject_id'> }) {
  const short = flag.subject_id.slice(0, 8);
  const to =
    flag.subject_type === 'plot'
      ? `/members/plots/${flag.subject_id}`
      : flag.subject_type === 'lot'
        ? `/lots/${flag.subject_id}`
        : null;
  const text = `${flag.subject_type} ${short}`;
  return to ? (
    <Link component={RouterLink} to={to}>
      {text}
    </Link>
  ) : (
    <span>{text}</span>
  );
}

/**
 * The flags table shared by the list and the lot page.
 * @param props Component props.
 * @param props.flags Rows to show.
 * @param props.label Accessible name of the table.
 * @returns The table, or a line saying there is nothing to show.
 */
export function FlagsTable({ flags, label }: { flags: readonly FlagOut[]; label: string }) {
  if (flags.length === 0) return <Typography color="text.secondary">No flags to show.</Typography>;
  return (
    <Table size="small" aria-label={label}>
      <TableHead>
        <TableRow>
          <TableCell>Severity</TableCell>
          <TableCell>Rule</TableCell>
          <TableCell>Subject</TableCell>
          <TableCell>Raised</TableCell>
          <TableCell>Assigned to</TableCell>
          <TableCell>Status</TableCell>
        </TableRow>
      </TableHead>
      <TableBody>
        {flags.map((flag) => {
          const rule = ruleText(flag.rule_code);
          return (
            <TableRow key={flag.id}>
              <TableCell>
                <SeverityChip severity={flag.severity} />
              </TableCell>
              <TableCell>
                <Link component={RouterLink} to={`/flags/${flag.id}`}>
                  {rule.en}
                </Link>
                {rule.ta && (
                  <Typography variant="body2" lang="ta" color="text.secondary">
                    {rule.ta}
                  </Typography>
                )}
              </TableCell>
              <TableCell>
                <SubjectLink flag={flag} />
              </TableCell>
              <TableCell>{dayMonth(flag.raised_at)}</TableCell>
              <TableCell>
                {(flag.assigned_role && ROLE_LABEL[flag.assigned_role]) ?? 'Nobody'}
              </TableCell>
              <TableCell>{STATUS_LABEL[flag.status]}</TableCell>
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}

/**
 * A native select bound to one URL search parameter.
 * @param props Component props.
 * @param props.label Field label.
 * @param props.value Current value ('' = any).
 * @param props.options Value → text; '' is offered first as `anyText`.
 * @param props.anyText Text of the '' option.
 * @param props.onChange Called with the chosen value.
 * @returns The select.
 */
function FilterSelect(props: {
  label: string;
  value: string;
  options: Readonly<Record<string, string>>;
  anyText: string;
  onChange: (value: string) => void;
}) {
  return (
    <TextField
      select
      label={props.label}
      value={props.value}
      onChange={(event) => {
        props.onChange(event.target.value);
      }}
      slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
      sx={{ minWidth: 180 }}
    >
      <option value="">{props.anyText}</option>
      {Object.entries(props.options).map(([value, text]) => (
        <option key={value} value={value}>
          {text}
        </option>
      ))}
    </TextField>
  );
}

const RULE_OPTIONS = Object.fromEntries(Object.entries(RULES).map(([code, t]) => [code, t.en]));

/**
 * The Flags page. Filters live in the URL so links from farmer, plot and lot pages open a filtered list.
 * @returns The filters, the table and "Load more".
 */
export function FlagsPage() {
  const { api } = useAuth();
  const [params, setParams] = useSearchParams();
  // A missing `status` means the review queue (open); an explicit empty value means every status.
  const status = (params.get('status') ?? 'open') as FlagStatus | '';
  const severity = (params.get('severity') ?? '') as Severity | '';
  const assignee = (params.get('assignee') ?? '') as Role | '';
  const rule = params.get('rule') ?? '';
  const subjects = params.get('subject')?.split(',').filter(Boolean) ?? [];

  const list = useCursorList<FlagOut>({
    queryKey: ['flags', 'list', { status, severity, assignee }],
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(
        api.GET('/v1/flags', {
          params: {
            query: {
              status: status || undefined,
              severity: severity || undefined,
              assignee: assignee || undefined,
              cursor,
              limit,
            },
          },
          signal,
        }),
      ),
  });
  // shortcut: GET /v1/flags has no rule_code or subject_id filter (B08), so these filter the loaded pages
  // only; "Load more" fetches further pages. Move both to the server once B08 adds the parameters.
  const rows = list.items.filter(
    (flag) =>
      (!rule || flag.rule_code === rule) &&
      (subjects.length === 0 || subjects.includes(flag.subject_id)),
  );

  /**
   * Writes one filter into the URL (empty values are kept for `status`, meaning "all").
   * @param key Search parameter name.
   * @param value New value.
   */
  function setFilter(key: string, value: string): void {
    const next = new URLSearchParams(params);
    if (value || key === 'status') next.set(key, value);
    else next.delete(key);
    setParams(next);
  }

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Flags
      </Typography>
      <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap' }}>
        <FilterSelect
          label="Status"
          value={status}
          options={STATUS_LABEL}
          anyText="All statuses"
          onChange={(v) => {
            setFilter('status', v);
          }}
        />
        <FilterSelect
          label="Severity"
          value={severity}
          options={Object.fromEntries(Object.entries(SEVERITY).map(([k, s]) => [k, s.label]))}
          anyText="All severities"
          onChange={(v) => {
            setFilter('severity', v);
          }}
        />
        <FilterSelect
          label="Rule"
          value={rule}
          options={RULE_OPTIONS}
          anyText="All rules"
          onChange={(v) => {
            setFilter('rule', v);
          }}
        />
        <FilterSelect
          label="Assigned to"
          value={assignee}
          options={ROLE_LABEL}
          anyText="Anyone"
          onChange={(v) => {
            setFilter('assignee', v);
          }}
        />
      </Stack>
      {subjects.length > 0 && (
        <Alert
          severity="info"
          action={
            <Button
              onClick={() => {
                setFilter('subject', '');
              }}
            >
              Show all
            </Button>
          }
        >
          Showing flags of one farmer or lot only (among the flags loaded below).
        </Alert>
      )}
      {list.isError && <Alert severity="error">{errorMessage(list.error)}</Alert>}
      {list.isSuccess && <FlagsTable flags={rows} label="Flags" />}
      {list.hasNextPage && (
        <Button
          sx={{ alignSelf: 'start' }}
          disabled={list.isFetchingNextPage}
          onClick={() => void list.fetchNextPage()}
        >
          Load more
        </Button>
      )}
    </Stack>
  );
}
