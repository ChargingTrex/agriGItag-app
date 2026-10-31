/**
 * FPO dashboard: filter bar (crop → district → block → village), completeness and public scans, stage-progress
 * tiles, Land Area Analytics, Finished Goods, Sync health and the per-farmer table with column show/hide.
 * Serves: FR13 (lot completeness, farmer participation), FR20 (completeness %, scans), plan §7.3 P06 and §13 F1
 * (Sync health tile), §13 C4 (cursor pages and `?fields=` on the farmer table), D-037 (stage tile meaning; which
 * sections ignore the filters). Called by: src/AppRoutes.tsx (index route).
 *
 * Only areas and counts are shown: the B11 payload carries no phone, address or location (CLAUDE.md §6).
 */
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormGroup from '@mui/material/FormGroup';
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
import { green } from '@mui/material/colors';
import { useQuery } from '@tanstack/react-query';
import { useState, type ReactNode } from 'react';
import { unwrap } from '../../api/client';
import { fieldsParam, useCursorList } from '../../api/cursor';
import { errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';
import { dayMonth } from '../flags/flagModel';
import { FarmerStatusChip } from '../members/MembersPage';

type Schemas = components['schemas'];
type FarmerRow = Schemas['FarmerRow'];
type Quantity = Schemas['Quantity-Output'];
type AreaStats = Schemas['AreaStats'];

/** Tile titles of the stages B11 returns (plan §7.3 P06 names). */
const STAGE_LABEL: Readonly<Record<string, string>> = {
  land_preparation: 'Land prep',
  nursery: 'Nursery',
  sowing: 'Sowing',
  input_application: 'Inputs',
  harvest: 'Harvest',
  drying: 'Drying',
  packing: 'Packing',
};

/** Farmer table columns the user may show or hide, in display order. */
const COLUMNS = [
  ['code', 'Code'],
  ['name', 'Name'],
  ['village', 'Village'],
  ['block', 'Block'],
  ['status', 'Status'],
  ['plots', 'Plots'],
  ['declared_area', 'Declared area'],
  ['walked_area', 'Walked area'],
  ['lots', 'Lots'],
  ['lots_complete', 'Complete lots'],
] as const satisfies readonly (readonly [keyof FarmerRow, string])[];
type Column = (typeof COLUMNS)[number][0];
const ALL_COLUMNS: Column[] = COLUMNS.map(([key]) => key);

/** The filter bar's state; '' means "all". */
interface Filters {
  crop_id: string;
  district: string;
  block: string;
  village_id: string;
}
const NO_FILTERS: Filters = { crop_id: '', district: '', block: '', village_id: '' };

/**
 * Prints a quantity with its unit (FR58).
 * @param q The API quantity, or null.
 * @param empty Text for null.
 * @returns e.g. `0.500 acre`, or `empty`.
 */
export const qty = (q: Quantity | null | undefined, empty = 'not recorded') =>
  q ? `${q.value} ${q.unit}` : empty;

/**
 * The localStorage key of the column choice. Per FPO, so a super-admin switching tenants keeps each choice.
 * @param fpoId The session's FPO.
 * @returns The key.
 */
export const columnsKey = (fpoId: string) => `agritrace.dashboard.columns.${fpoId}`;

/**
 * Reads the stored column choice; anything unreadable or unknown falls back to every column.
 * @param fpoId The session's FPO.
 * @returns Known columns in display order (never empty).
 */
export function readColumns(fpoId: string): Column[] {
  try {
    const stored: unknown = JSON.parse(localStorage.getItem(columnsKey(fpoId)) ?? 'null');
    if (Array.isArray(stored)) {
      const known = ALL_COLUMNS.filter((c) => stored.includes(c));
      if (known.length > 0) return known;
    }
  } catch {
    // Corrupt JSON or storage disabled: show every column.
  }
  return ALL_COLUMNS;
}

/**
 * Query parameters for both dashboard endpoints.
 * @param f The filter bar state.
 * @returns The filters with "all" left out.
 */
const toQuery = (f: Filters) => ({
  crop_id: f.crop_id || undefined,
  district: f.district || undefined,
  block: f.block || undefined,
  village_id: f.village_id || undefined,
});

/**
 * Distinct, sorted, non-empty values.
 * @param values Values with repeats or nulls.
 * @returns The distinct values.
 */
const distinct = (values: (string | null)[]) =>
  [...new Set(values.filter((v): v is string => Boolean(v)))].sort();

/**
 * Crop → district → block → village selects. Picking a place clears the narrower places below it.
 * @param props Component props.
 * @param props.filters Current filters.
 * @param props.onChange Called with the new filters.
 * @returns The filter bar.
 */
function FilterBar({ filters, onChange }: { filters: Filters; onChange: (f: Filters) => void }) {
  const { api } = useAuth();
  const crops = useQuery({
    queryKey: ['crops'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/crops', { signal })),
  });
  // shortcut: the whole villages master is read page by page (a district's LGD import is ~600 rows, 3 pages) to
  //   build the district and block lists; add a places endpoint when the master holds many districts.
  const villages = useQuery({
    queryKey: ['villages', 'all'],
    queryFn: async ({ signal }) => {
      const all: Schemas['VillageOut'][] = [];
      let cursor: string | undefined;
      do {
        const page = await unwrap(
          api.GET('/v1/villages', { params: { query: { limit: 200, cursor } }, signal }),
        );
        all.push(...page.items);
        cursor = page.has_more ? (page.next_cursor ?? undefined) : undefined;
      } while (cursor);
      return all;
    },
  });
  const all = villages.data ?? [];
  const inDistrict = all.filter((v) => !filters.district || v.district === filters.district);
  const inBlock = inDistrict.filter((v) => !filters.block || v.block === filters.block);

  /**
   * One native select (keyboard and screen-reader friendly, and testable with `selectOptions`).
   * @param label Field label.
   * @param value Current value.
   * @param allText Text of the "all" option.
   * @param options `[value, text]` pairs.
   * @param pick Called with the chosen value.
   * @returns The select.
   */
  const select = (
    label: string,
    value: string,
    allText: string,
    options: [string, string][],
    pick: (value: string) => void,
  ) => (
    <TextField
      select
      label={label}
      value={value}
      onChange={(event) => {
        pick(event.target.value);
      }}
      slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
      sx={{ minWidth: 180 }}
    >
      <option value="">{allText}</option>
      {options.map(([v, text]) => (
        <option key={v} value={v}>
          {text}
        </option>
      ))}
    </TextField>
  );

  return (
    <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap' }}>
      {select(
        'Crop',
        filters.crop_id,
        'All crops',
        (crops.data ?? []).map((c) => [c.id, c.name_en]),
        (crop_id) => {
          onChange({ ...filters, crop_id });
        },
      )}
      {select(
        'District',
        filters.district,
        'All districts',
        distinct(all.map((v) => v.district)).map((d) => [d, d]),
        (district) => {
          onChange({ ...NO_FILTERS, crop_id: filters.crop_id, district });
        },
      )}
      {select(
        'Block',
        filters.block,
        'All blocks',
        distinct(inDistrict.map((v) => v.block)).map((b) => [b, b]),
        (block) => {
          onChange({ ...filters, block, village_id: '' });
        },
      )}
      {select(
        'Village',
        filters.village_id,
        'All villages',
        inBlock.map((v) => [v.id, v.name_en]),
        (village_id) => {
          onChange({ ...filters, village_id });
        },
      )}
      {villages.isError && <Alert severity="warning">{errorMessage(villages.error)}</Alert>}
    </Stack>
  );
}

/**
 * A titled section.
 * @param props Component props.
 * @param props.id Heading id (labels the section).
 * @param props.title Heading text.
 * @param props.children Section body.
 * @returns The section.
 */
function Section({ id, title, children }: { id: string; title: string; children: ReactNode }) {
  return (
    <section aria-labelledby={id}>
      <Typography id={id} component="h2" variant="h6" gutterBottom>
        {title}
      </Typography>
      {children}
    </section>
  );
}

/** Segment colours: one green ramp for progress (green 300 is ΔE 24 from done), grey for not started. */
const SEGMENTS = [
  ['done', 'Done', 'primary.main'],
  ['in_progress', 'In progress', green[300]],
  ['not_started', 'Not started', 'grey.300'],
] as const;

/**
 * One stage tile: a stacked bar (done, in progress, not started) and the three counts in text, so the colour
 * is never the only carrier.
 * @param props Component props.
 * @param props.tile The stage's lot counts.
 * @returns The tile.
 */
function StageTile({ tile }: { tile: Schemas['StageTile'] }) {
  const label = STAGE_LABEL[tile.stage] ?? tile.stage.replaceAll('_', ' ');
  return (
    <Paper variant="outlined" sx={{ p: 2, minWidth: 180, flex: '1 1 180px' }}>
      <Typography component="h3" variant="subtitle1">
        {label}
      </Typography>
      <Box sx={{ display: 'flex', gap: '2px', height: 8, my: 1, bgcolor: 'grey.100' }} aria-hidden>
        {SEGMENTS.map(([key, text, color]) =>
          tile[key] > 0 ? (
            <Box
              key={key}
              title={`${text}: ${String(tile[key])}`}
              sx={{ flexGrow: tile[key], bgcolor: color, borderRadius: '4px' }}
            />
          ) : null,
        )}
      </Box>
      <Typography variant="body2">
        {tile.done} done · {tile.in_progress} in progress · {tile.not_started} not started
      </Typography>
    </Paper>
  );
}

/**
 * Land area table for blocks or villages; every area carries its unit.
 * @param props Component props.
 * @param props.label Accessible table name and first column header.
 * @param props.rows `[name, stats]` pairs.
 * @returns The table, or a line when there are no plots.
 */
function AreaTable({ label, rows }: { label: string; rows: [string, AreaStats][] }) {
  if (rows.length === 0) return <Typography color="text.secondary">No plots match.</Typography>;
  return (
    <Table size="small" aria-label={`Area by ${label.toLowerCase()}`}>
      <TableHead>
        <TableRow>
          <TableCell>{label}</TableCell>
          <TableCell>Plots (walked)</TableCell>
          <TableCell>Declared</TableCell>
          <TableCell>Walked</TableCell>
          <TableCell>Declared, walked plots</TableCell>
          <TableCell>GI-confirmed</TableCell>
          <TableCell>GI-confirmed share</TableCell>
        </TableRow>
      </TableHead>
      <TableBody>
        {rows.map(([name, s]) => (
          <TableRow key={name}>
            <TableCell>{name}</TableCell>
            <TableCell>
              {s.plots} ({s.walked_plots})
            </TableCell>
            <TableCell>{qty(s.declared_area)}</TableCell>
            <TableCell>{qty(s.walked_area)}</TableCell>
            <TableCell>{qty(s.walked_declared_area)}</TableCell>
            <TableCell>{qty(s.gi_confirmed_area)}</TableCell>
            <TableCell>{qty(s.gi_confirmed_share, '—')}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

/**
 * The sections built from `GET /v1/dashboard/fpo/{id}`.
 * @param props Component props.
 * @param props.data The dashboard body.
 * @returns Summary, tiles, land area, finished goods and sync health.
 */
function DashboardSections({ data }: { data: Schemas['Dashboard'] }) {
  const { completeness, land_area: land, finished_goods: goods, scans } = data;
  return (
    <>
      <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap' }}>
        <Paper variant="outlined" sx={{ p: 2 }}>
          <Typography variant="overline">Lot completeness</Typography>
          <Typography variant="h5" component="p">
            {qty(completeness.complete, 'no lots')}
          </Typography>
          <Typography variant="body2">
            {completeness.complete_lots} of {completeness.lots} lots have every mandatory entry
          </Typography>
        </Paper>
        <Paper variant="outlined" sx={{ p: 2 }}>
          <Typography variant="overline">Public page scans (whole FPO)</Typography>
          <Typography variant="h5" component="p">
            {scans.total}
          </Typography>
          <Typography variant="body2">{scans.last_7_days} in the last 7 days</Typography>
        </Paper>
      </Stack>

      <Section id="stages-heading" title="Stage progress (lots)">
        <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap', mb: 1 }}>
          {SEGMENTS.map(([key, text, color]) => (
            <Stack key={key} direction="row" spacing={1} sx={{ alignItems: 'center' }}>
              <Box sx={{ width: 12, height: 12, bgcolor: color, borderRadius: '2px' }} />
              <Typography variant="body2">{text}</Typography>
            </Stack>
          ))}
        </Stack>
        <Stack direction="row" spacing={2} useFlexGap sx={{ flexWrap: 'wrap' }}>
          {data.stages.map((tile) => (
            <StageTile key={tile.stage} tile={tile} />
          ))}
        </Stack>
      </Section>

      <Section id="land-heading" title="Land area analytics">
        <Typography gutterBottom>
          {land.total.plots} plots: {qty(land.total.declared_area)} declared,{' '}
          {qty(land.total.walked_area)} walked ({land.total.walked_plots} plots), GI-confirmed share{' '}
          {qty(land.total.gi_confirmed_share, '—')}.
        </Typography>
        <Stack spacing={2}>
          <AreaTable label="Block" rows={land.by_block.map((r) => [r.block ?? 'No block', r])} />
          <AreaTable
            label="Village"
            rows={land.by_village.map((r) => [
              `${r.village ?? 'No village'}${r.block ? ` (${r.block})` : ''}`,
              r,
            ])}
          />
        </Stack>
      </Section>

      <Section id="goods-heading" title="Finished goods (whole FPO)">
        <Typography gutterBottom>
          {goods.batches} packed or published batches, {qty(goods.packed)} in final packs.
        </Typography>
        {goods.items.length > 0 && (
          <Table size="small" aria-label="Finished goods">
            <TableHead>
              <TableRow>
                <TableCell>Batch</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Pack date</TableCell>
                <TableCell>Packed</TableCell>
                <TableCell>Remaining</TableCell>
                <TableCell>Labels printed</TableCell>
                <TableCell>Scans</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {goods.items.map((b) => (
                <TableRow key={b.batch_id}>
                  <TableCell>{b.code}</TableCell>
                  <TableCell>{b.status}</TableCell>
                  <TableCell>{b.pack_date ? dayMonth(b.pack_date) : 'not recorded'}</TableCell>
                  <TableCell>{qty(b.packed)}</TableCell>
                  <TableCell>{qty(b.remaining)}</TableCell>
                  {/* B11 has no label-print count yet (TODO.md "B11 skipped"). */}
                  <TableCell>not recorded</TableCell>
                  <TableCell>{b.scans}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Section>

      <Section id="sync-heading" title="Sync health (last 7 days, whole FPO)">
        {data.sync_health.length === 0 ? (
          <Typography color="text.secondary">No phone sent entries in the last 7 days.</Typography>
        ) : (
          <Table size="small" aria-label="Sync health">
            <TableHead>
              <TableRow>
                <TableCell>Network</TableCell>
                <TableCell>Entries</TableCell>
                <TableCell>Save → ack p50 / p95</TableCell>
                <TableCell>Photo upload p50 / p95</TableCell>
                <TableCell>Failure rate</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.sync_health.map((r) => (
                <TableRow key={r.network_type ?? 'unknown'}>
                  <TableCell>{r.network_type ?? 'Unknown'}</TableCell>
                  <TableCell>{r.entries}</TableCell>
                  <TableCell>
                    {qty(r.save_to_ack_p50, '—')} / {qty(r.save_to_ack_p95, '—')}
                  </TableCell>
                  <TableCell>
                    {qty(r.photo_upload_p50, '—')} / {qty(r.photo_upload_p95, '—')}
                  </TableCell>
                  <TableCell>{qty(r.failure_rate)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Section>
    </>
  );
}

/**
 * Text or chip for one farmer-table cell; fields left out by `?fields=` show a dash.
 * @param row The (possibly partial) row.
 * @param column The column.
 * @returns The cell content.
 */
function cell(row: Partial<FarmerRow>, column: Column): ReactNode {
  const value = row[column];
  if (column === 'status' && row.status) return <FarmerStatusChip status={row.status} />;
  if (value === null || value === undefined) return '—';
  return typeof value === 'object' ? qty(value) : String(value);
}

/**
 * Per-farmer table with column show/hide (stored per FPO in localStorage) and cursor "Load more". Only the
 * shown columns are requested, through `?fields=`.
 * @param props Component props.
 * @param props.fpoId The session's FPO.
 * @param props.filters Current filters.
 * @returns The section.
 */
function FarmerTable({ fpoId, filters }: { fpoId: string; filters: Filters }) {
  const { api } = useAuth();
  const [columns, setColumns] = useState<Column[]>(() => readColumns(fpoId));
  const fields = fieldsParam<FarmerRow>(['id', ...columns]);
  const list = useCursorList<FarmerRow>({
    queryKey: ['dashboard', 'farmers', fpoId, filters, fields],
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(
        api.GET('/v1/dashboard/fpo/{fpo_id}/farmers', {
          params: {
            path: { fpo_id: fpoId },
            query: { ...toQuery(filters), cursor, limit, fields },
          },
          signal,
        }),
      ),
  });

  /**
   * Shows or hides a column and stores the choice.
   * @param column The column.
   * @param shown Whether it is now shown.
   */
  const toggle = (column: Column, shown: boolean) => {
    const next = ALL_COLUMNS.filter((c) => (c === column ? shown : columns.includes(c)));
    // Storage may be full or disabled; the choice then lasts until reload.
    try {
      localStorage.setItem(columnsKey(fpoId), JSON.stringify(next));
    } catch {
      /* keep the in-memory choice */
    }
    setColumns(next);
  };

  return (
    <Section id="farmers-heading" title="Farmers">
      <FormGroup row aria-label="Columns shown" sx={{ mb: 1 }}>
        {COLUMNS.map(([key, label]) => {
          const shown = columns.includes(key);
          return (
            <FormControlLabel
              key={key}
              label={label}
              control={
                <Checkbox
                  checked={shown}
                  // The last shown column stays, so the table never has no columns.
                  disabled={shown && columns.length === 1}
                  onChange={(event) => {
                    toggle(key, event.target.checked);
                  }}
                />
              }
            />
          );
        })}
      </FormGroup>
      {list.isError && <Alert severity="error">{errorMessage(list.error)}</Alert>}
      {list.isPending && <LinearProgress aria-label="Loading farmers" />}
      {list.isSuccess && list.items.length === 0 && (
        <Typography color="text.secondary">No farmer matches the filters.</Typography>
      )}
      {list.items.length > 0 && (
        <Table size="small" aria-label="Farmers">
          <TableHead>
            <TableRow>
              {COLUMNS.filter(([key]) => columns.includes(key)).map(([key, label]) => (
                <TableCell key={key}>{label}</TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {list.items.map((row) => (
              <TableRow key={row.id}>
                {columns.map((c) => (
                  <TableCell key={c}>{cell(row, c)}</TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
      {list.hasNextPage && (
        <Button
          onClick={() => void list.fetchNextPage()}
          disabled={list.isFetchingNextPage}
          sx={{ mt: 1 }}
        >
          Load more
        </Button>
      )}
    </Section>
  );
}

/**
 * The dashboard page.
 * @returns Filters, dashboard sections and the farmer table.
 */
export function DashboardPage() {
  const { api, session } = useAuth();
  const fpoId = session?.fpo_id ?? '';
  const [filters, setFilters] = useState<Filters>(NO_FILTERS);
  const dashboard = useQuery({
    queryKey: ['dashboard', fpoId, filters],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/dashboard/fpo/{fpo_id}', {
          params: { path: { fpo_id: fpoId }, query: toQuery(filters) },
          signal,
        }),
      ),
  });

  return (
    <Stack spacing={4}>
      <Typography component="h1" variant="h4">
        Dashboard
      </Typography>
      <FilterBar filters={filters} onChange={setFilters} />
      <Typography variant="body2" color="text.secondary">
        Crop and place filters narrow completeness, stage progress and the farmer table; land area
        follows the place filters only; finished goods, scans and sync health are for the whole FPO.
      </Typography>
      {dashboard.isPending && <LinearProgress aria-label="Loading dashboard" />}
      {dashboard.isError && <Alert severity="error">{errorMessage(dashboard.error)}</Alert>}
      {dashboard.isSuccess && <DashboardSections data={dashboard.data} />}
      <FarmerTable key={fpoId} fpoId={fpoId} filters={filters} />
    </Stack>
  );
}
