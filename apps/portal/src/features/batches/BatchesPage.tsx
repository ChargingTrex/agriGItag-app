/**
 * Batches list: the FPO's batches with a status filter (kept in the URL) and cursor paging; each code opens
 * the batch detail.
 * Serves: FR9 (batches with their batch ID), FR15 (which batches are published), plan §7.3 P04 and §13 C4
 * (cursor pages). Called by: src/AppRoutes.tsx (`/batches`).
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
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
import { BATCH_STATUS, formatKg, toGrams, type BatchOut, type BatchStatus } from './batchModel';

/**
 * A quantity cell.
 * @param q A kg quantity or nothing.
 * @returns "320 kg" or a dash.
 */
const kg = (q: BatchOut['packed']) => (q ? formatKg(toGrams(q.value)) : '—');

/**
 * The Batches page.
 * @returns The status filter, the table and "Load more".
 */
export function BatchesPage() {
  const { api } = useAuth();
  const [params, setParams] = useSearchParams();
  const status = (params.get('status') ?? '') as BatchStatus | '';
  const list = useCursorList<BatchOut>({
    queryKey: ['batches', 'list', { status }],
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(
        api.GET('/v1/batches', {
          params: { query: { status: status || undefined, cursor, limit } },
          signal,
        }),
      ),
  });

  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Batches
      </Typography>
      <TextField
        select
        label="Status"
        value={status}
        onChange={(event) => {
          setParams(event.target.value ? { status: event.target.value } : {});
        }}
        slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
        sx={{ maxWidth: 220 }}
      >
        <option value="">All statuses</option>
        {Object.entries(BATCH_STATUS).map(([value, text]) => (
          <option key={value} value={value}>
            {text}
          </option>
        ))}
      </TextField>
      {list.isError && <Alert severity="error">{errorMessage(list.error)}</Alert>}
      {list.isSuccess && list.items.length === 0 && status && (
        <Typography color="text.secondary">
          No {BATCH_STATUS[status].toLowerCase()} batch.
        </Typography>
      )}
      {list.isSuccess && list.items.length === 0 && !status && (
        <Typography color="text.secondary">
          No batch yet. Create one from{' '}
          <Link component={RouterLink} to="/ready-lots">
            Ready lots
          </Link>
          .
        </Typography>
      )}
      {list.items.length > 0 && (
        <Table size="small" aria-label="Batches">
          <TableHead>
            <TableRow>
              <TableCell>Batch ID</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>GI</TableCell>
              <TableCell align="right">Received</TableCell>
              <TableCell align="right">Packed</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {list.items.map((b) => (
              <TableRow key={b.id}>
                <TableCell>
                  <Link component={RouterLink} to={`/batches/${b.id}`}>
                    {b.code}
                  </Link>
                </TableCell>
                <TableCell>{BATCH_STATUS[b.status]}</TableCell>
                <TableCell>
                  {b.gi_label_requested ? (b.gi_verified ? 'Verified' : 'Not verified') : 'Non-GI'}
                </TableCell>
                <TableCell align="right">{kg(b.total_received)}</TableCell>
                <TableCell align="right">{kg(b.packed)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
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
