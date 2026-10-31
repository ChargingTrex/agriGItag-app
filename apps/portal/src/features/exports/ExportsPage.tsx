/**
 * Labels and exports page (`/exports`): the dashboard farmer table as CSV (the columns shown on the dashboard, every
 * quantity with its unit, never a phone, survey number or coordinate) and the way to each batch's labels, audit CSV
 * and lots CSV (they live on the batch page).
 * Serves: FR21 (CSV export), FR58 (unit on every quantity), FR13 (farmer table), plan §7.3 P05, CLAUDE.md §6.
 * Called by: src/AppRoutes.tsx (`/exports`, sidebar "Labels & exports").
 */
import Alert from '@mui/material/Alert';
import Link from '@mui/material/Link';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useMutation } from '@tanstack/react-query';
import { Link as RouterLink } from 'react-router';
import { unwrap } from '../../api/client';
import { fieldsParam, type CursorPage } from '../../api/cursor';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { GatedButton } from '../batches/ReadyLotsPage';
import {
  FARMER_COLUMNS,
  farmersCsvRows,
  saveCsv,
  type FarmerColumn,
  type FarmerRow,
} from './exportModel';

/** The API's largest page. */
const PAGE = 200;

/**
 * The farmer columns shown on the dashboard: P06 keeps the choice per FPO in localStorage under this key.
 * @param fpoId The session's FPO.
 * @returns The stored known columns in display order, else every column.
 */
export function visibleColumns(fpoId: string): FarmerColumn[] {
  // shortcut: repeats P06's `columnsKey` text because features/dashboard is not merged yet; import P06's
  //   `readColumns` once both are on main.
  try {
    const stored: unknown = JSON.parse(
      localStorage.getItem(`agritrace.dashboard.columns.${fpoId}`) ?? 'null',
    );
    const known = FARMER_COLUMNS.filter((c) => Array.isArray(stored) && stored.includes(c));
    if (known.length > 0) return known;
  } catch {
    // Corrupt JSON or storage disabled: every column, as the dashboard shows then.
  }
  return [...FARMER_COLUMNS];
}

/**
 * The Labels and exports page.
 * @returns The farmers CSV download and the pointer to the batch exports.
 */
export function ExportsPage() {
  const { api, session } = useAuth();
  const fpoId = session?.fpo_id ?? '';
  const farmers = useMutation({
    mutationFn: async () => {
      const columns = visibleColumns(fpoId);
      const fields = fieldsParam<FarmerRow>(columns);
      const fpo = await unwrap(
        api.GET('/v1/fpos/{fpo_id}', { params: { path: { fpo_id: fpoId } } }),
      );
      const rows: Partial<FarmerRow>[] = [];
      let cursor: string | null = null;
      // The whole table, page by page, without the dashboard's place filters.
      do {
        const page: CursorPage<Partial<FarmerRow>> = await unwrap(
          api.GET('/v1/dashboard/fpo/{fpo_id}/farmers', {
            params: { path: { fpo_id: fpoId }, query: { cursor, limit: PAGE, fields } },
          }),
        );
        rows.push(...page.items);
        cursor = page.has_more ? (page.next_cursor ?? null) : null;
      } while (cursor);
      // en-CA formats the local date as YYYY-MM-DD.
      const date = new Date().toLocaleDateString('en-CA');
      saveCsv(farmersCsvRows(rows, columns), `farmers-${fpo.code}-${date}.csv`);
    },
  });

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Labels and exports
      </Typography>
      <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="farmers-heading">
        <Stack spacing={2}>
          <Typography id="farmers-heading" component="h2" variant="h6">
            Farmers
          </Typography>
          <Typography>
            The dashboard&rsquo;s farmer table with the columns you show there, for every farmer of
            the FPO. Areas carry their unit in the next column. No phone number, survey number or
            location is exported.
          </Typography>
          <GatedButton
            label="Download farmers CSV"
            reasons={[]}
            busy={farmers.isPending}
            onClick={() => {
              farmers.mutate();
            }}
          />
          {farmers.isError && <Alert severity="error">{errorMessage(farmers.error)}</Alert>}
        </Stack>
      </Paper>
      <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="batch-exports">
        <Typography id="batch-exports" component="h2" variant="h6" gutterBottom>
          Batches
        </Typography>
        <Typography>
          Pack labels, the audit trail CSV and the lots and shares CSV are on each batch&rsquo;s
          page under &ldquo;Labels and exports&rdquo;. Open a batch from{' '}
          <Link component={RouterLink} to="/batches">
            Batches
          </Link>
          .
        </Typography>
      </Paper>
    </Stack>
  );
}
