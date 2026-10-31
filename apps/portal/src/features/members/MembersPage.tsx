/**
 * Members screen: farmers waiting for approval (approve in one click) and the cursor-paginated roster with a
 * status filter and a search box.
 * Serves: FR8 (FPO admin approves genuine members), FR14 (the API scopes the list to the caller's FPO and
 * role), Dataflow Stage 0 (approval), plan §7.3 P01 and §13 C4 (lean lists: minimal columns, cursor pages).
 * Called by: src/AppRoutes.tsx (`/members`); `FarmerStatusChip` and `useApproveFarmer` also by
 * src/features/members/FarmerPage.tsx.
 *
 * Not offered because the B03 contract has no endpoint for it (TODO.md "B03/P01"): rejecting a registration,
 * the masked phone with an audited reveal (`FarmerOut` carries no phone), server-side village/name search and
 * `?fields=` on `GET /v1/farmers`.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import MenuItem from '@mui/material/MenuItem';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link } from 'react-router';
import { unwrap } from '../../api/client';
import { useCursorList } from '../../api/cursor';
import { errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';

type FarmerOut = components['schemas']['FarmerOut'];
type FarmerStatus = components['schemas']['FarmerStatus'];

const STATUS_CHIP: Record<
  FarmerStatus,
  { label: string; color: 'warning' | 'success' | 'default' }
> = {
  pending: { label: 'Waiting for approval', color: 'warning' },
  active: { label: 'Active', color: 'success' },
  suspended: { label: 'Suspended', color: 'default' },
};

/**
 * A coloured chip for a farmer's onboarding status.
 * @param props Component props.
 * @param props.status The farmer's status.
 * @returns The chip.
 */
export function FarmerStatusChip({ status }: { status: FarmerStatus }) {
  const chip = STATUS_CHIP[status];
  return <Chip size="small" label={chip.label} color={chip.color} />;
}

/**
 * Approve mutation for `POST /v1/farmers/{id}/approve`. On success every farmer query is refetched, so the
 * farmer moves from "Waiting for approval" to the roster as Active without a page reload.
 * @returns TanStack mutation; `mutate(farmerId)`. Errors (`farmer_not_pending`, `forbidden`) surface as
 *   `error` and are shown through `errorMessage`.
 */
export function useApproveFarmer() {
  const { api } = useAuth();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (farmerId: string) =>
      unwrap(
        api.POST('/v1/farmers/{farmer_id}/approve', { params: { path: { farmer_id: farmerId } } }),
      ),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['farmers'] }),
  });
}

/**
 * One cursor-paginated farmer list for a status (all statuses when empty).
 * @param status Status filter sent as `?status=`, or '' for every status.
 * @returns `useCursorList` result over `GET /v1/farmers`.
 */
function useFarmers(status: FarmerStatus | '') {
  const { api } = useAuth();
  return useCursorList<FarmerOut>({
    queryKey: ['farmers', { status }],
    fetchPage: ({ cursor, limit, signal }) =>
      unwrap(
        api.GET('/v1/farmers', {
          params: { query: { cursor, limit, status: status || undefined } },
          signal,
        }),
      ),
  });
}

/** Props of `FarmerTable`. */
interface FarmerTableProps {
  /** Accessible table name. */
  label: string;
  /** Rows to show. */
  farmers: FarmerOut[];
  /** Shown when there are no rows. */
  empty: string;
  /** When given, each row gets an Approve button that calls it with the farmer id. */
  onApprove?: (farmerId: string) => void;
  /** Disables the Approve buttons while a request runs. */
  approving?: boolean;
}

/**
 * Lean farmer table: code, name (link to the detail page), village/address, status.
 * @param props See `FarmerTableProps`.
 * @returns The table, or the empty text.
 */
function FarmerTable(props: FarmerTableProps) {
  const { label, farmers, empty, onApprove, approving } = props;
  if (farmers.length === 0) return <Typography color="text.secondary">{empty}</Typography>;
  return (
    <Table size="small" aria-label={label}>
      <TableHead>
        <TableRow>
          <TableCell>Code</TableCell>
          <TableCell>Name</TableCell>
          <TableCell>Village</TableCell>
          <TableCell>Status</TableCell>
          {onApprove && <TableCell>Action</TableCell>}
        </TableRow>
      </TableHead>
      <TableBody>
        {farmers.map((farmer) => (
          <TableRow key={farmer.id}>
            <TableCell>{farmer.code}</TableCell>
            <TableCell>
              <Button
                component={Link}
                to={`/members/${farmer.id}`}
                sx={{ justifyContent: 'start' }}
              >
                {farmer.name}
              </Button>
            </TableCell>
            <TableCell>{farmer.address_line}</TableCell>
            <TableCell>
              <FarmerStatusChip status={farmer.status} />
            </TableCell>
            {onApprove && (
              <TableCell>
                <Button
                  variant="contained"
                  disabled={approving}
                  onClick={() => {
                    onApprove(farmer.id);
                  }}
                  aria-label={`Approve ${farmer.name}`}
                >
                  Approve
                </Button>
              </TableCell>
            )}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

/**
 * "Load more" button for a cursor list, hidden on the last page.
 * @param props Component props.
 * @param props.list The `useCursorList` result.
 * @returns The button or nothing.
 */
function LoadMore({ list }: { list: ReturnType<typeof useFarmers> }) {
  if (!list.hasNextPage) return null;
  return (
    <Button
      onClick={() => void list.fetchNextPage()}
      disabled={list.isFetchingNextPage}
      sx={{ mt: 1 }}
    >
      Load more
    </Button>
  );
}

/**
 * The Members page.
 * @returns Pending approvals above the roster.
 */
export function MembersPage() {
  const pending = useFarmers('pending');
  const approve = useApproveFarmer();
  const [status, setStatus] = useState<FarmerStatus | ''>('');
  const [search, setSearch] = useState('');
  const roster = useFarmers(status);

  // shortcut: the search filters only the pages already loaded, because GET /v1/farmers has no `q` or
  // `village_id` parameter yet; switch to server-side search when B03 adds them (TODO.md).
  const needle = search.trim().toLowerCase();
  const rows = needle
    ? roster.items.filter((farmer) =>
        [farmer.name, farmer.code, farmer.address_line].some((value) =>
          value.toLowerCase().includes(needle),
        ),
      )
    : roster.items;

  return (
    <Stack spacing={4}>
      <Typography component="h1" variant="h4">
        Members
      </Typography>

      <section aria-labelledby="pending-heading">
        <Typography id="pending-heading" component="h2" variant="h6" gutterBottom>
          Waiting for approval
        </Typography>
        {approve.isError && (
          <Alert severity="error" sx={{ mb: 1 }}>
            {errorMessage(approve.error)}
          </Alert>
        )}
        {pending.isError && <Alert severity="error">{errorMessage(pending.error)}</Alert>}
        {pending.isSuccess && (
          <FarmerTable
            label="Waiting for approval"
            farmers={pending.items}
            empty="No farmer is waiting for approval."
            onApprove={(farmerId) => {
              approve.mutate(farmerId);
            }}
            approving={approve.isPending}
          />
        )}
        <LoadMore list={pending} />
      </section>

      <section aria-labelledby="roster-heading">
        <Typography id="roster-heading" component="h2" variant="h6" gutterBottom>
          All members
        </Typography>
        <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
          <TextField
            select
            label="Status"
            value={status}
            onChange={(event) => {
              setStatus(event.target.value as FarmerStatus | '');
            }}
            sx={{ minWidth: 200 }}
          >
            <MenuItem value="">All</MenuItem>
            {(Object.keys(STATUS_CHIP) as FarmerStatus[]).map((value) => (
              <MenuItem key={value} value={value}>
                {STATUS_CHIP[value].label}
              </MenuItem>
            ))}
          </TextField>
          <TextField
            label="Search name, code or village"
            value={search}
            onChange={(event) => {
              setSearch(event.target.value);
            }}
            helperText="Searches the members loaded below."
            sx={{ minWidth: 320 }}
          />
        </Stack>
        {roster.isError && <Alert severity="error">{errorMessage(roster.error)}</Alert>}
        {roster.isSuccess && (
          <FarmerTable label="All members" farmers={rows} empty="No member matches." />
        )}
        <LoadMore list={roster} />
      </section>
    </Stack>
  );
}
