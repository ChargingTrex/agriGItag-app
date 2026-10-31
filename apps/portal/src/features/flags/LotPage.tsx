/**
 * Lot review page: whether flags keep the lot out of GI-labelled batches, the lot's flags, and the evidence
 * photos of its timeline. `useLotHold` and `LotHoldState` are the hook and line P03 (Ready lots) reuses to
 * grey a held lot.
 * Serves: FR68/FR70 (a hold keeps the lot out of GI batches until an FPO admin clears it), FR61 (evidence
 * photos), Dataflow "Review & flags", plan §7.3 P02 acceptance "review held lot → cleared → tickable in P03".
 * Called by: src/AppRoutes.tsx (`/lots/:lotId`); `useLotHold`, `LotHoldState` and `EvidencePhotos` also by
 * FlagPage.tsx (and P03 later). Flags of lots link here through `SubjectLink`.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import LinearProgress from '@mui/material/LinearProgress';
import Link from '@mui/material/Link';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useQuery } from '@tanstack/react-query';
import { Link as RouterLink, useParams } from 'react-router';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { activeHolds, dayMonth, ruleText } from './flagModel';
import { FlagsTable } from './FlagsPage';

/** Enough flags of one FPO for the pilot in one request (the API maximum). */
const ONE_PAGE = 200;

/**
 * The lot's active hold flags. Every flag query key starts with `flags`, so resolving any flag refreshes it.
 * @param lotId The lot.
 * @returns TanStack query whose `data` is the list of active holds (empty: flags do not block the lot).
 */
export function useLotHold(lotId: string) {
  const { api } = useAuth();
  // shortcut: the contract has no lot read with `gi_eligible` and no `subject_id` flag filter, so the hold is
  // derived from the first 200 hold flags of the FPO; read `lots.gi_eligible` once B09 exposes the lot.
  return useQuery({
    queryKey: ['flags', 'holds'],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/flags', { params: { query: { severity: 'hold', limit: ONE_PAGE } }, signal }),
      ),
    select: (page) => activeHolds(page.items, lotId),
  });
}

/**
 * One line saying whether the lot can be ticked for a GI-labelled batch.
 * @param props Component props.
 * @param props.lotId The lot.
 * @returns An error alert naming the holds, a success alert, or a progress bar.
 */
export function LotHoldState({ lotId }: { lotId: string }) {
  const holds = useLotHold(lotId);
  if (holds.isPending) return <LinearProgress aria-label="Loading GI state" />;
  if (holds.isError) return <Alert severity="error">{errorMessage(holds.error)}</Alert>;
  if (holds.data.length === 0) {
    return (
      <Alert severity="success">
        GI eligible: no hold flag, so this lot can be ticked for a GI-labelled batch.
      </Alert>
    );
  }
  return (
    <Alert severity="error">
      On hold: not eligible for GI-labelled batches until an FPO admin clears{' '}
      {holds.data.map((flag) => ruleText(flag.rule_code).en).join(', ')}.
    </Alert>
  );
}

/**
 * Thumbnails of the lot's evidence photos, each opening its medium variant. Only the presigned
 * `thumb_url`/`medium_url` WebP links are used; the original JPEG (exact EXIF GPS) is never listed.
 * @param props Component props.
 * @param props.lotId The lot.
 * @returns The photo strip, a note when there are none, or the error.
 */
export function EvidencePhotos({ lotId }: { lotId: string }) {
  const { api } = useAuth();
  const events = useQuery({
    queryKey: ['lots', lotId, 'events'],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/lots/{lot_id}/events', { params: { path: { lot_id: lotId } }, signal })),
  });
  if (events.isPending) return <LinearProgress aria-label="Loading photos" />;
  if (events.isError) return <Alert severity="warning">{errorMessage(events.error)}</Alert>;
  const photos = events.data.items.flatMap((event) =>
    event.photos.flatMap((photo) => {
      const v = photo.variants as { thumb_url?: string; medium_url?: string } | null | undefined;
      return v?.thumb_url
        ? [{ id: photo.id, event, thumb: v.thumb_url, medium: v.medium_url }]
        : [];
    }),
  );
  if (photos.length === 0) {
    return <Typography color="text.secondary">No evidence photos on this lot yet.</Typography>;
  }
  return (
    <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: 'wrap' }}>
      {photos.map((p) => {
        const alt = `Evidence photo: ${p.event.event_type.replaceAll('_', ' ')}, ${dayMonth(p.event.occurred_on)}`;
        return (
          <a key={p.id} href={p.medium ?? p.thumb} target="_blank" rel="noreferrer">
            <img src={p.thumb} alt={alt} width={96} height={96} style={{ objectFit: 'cover' }} />
          </a>
        );
      })}
    </Stack>
  );
}

/**
 * The lot page for the `:lotId` route parameter.
 * @returns GI state, the lot's flags and its evidence photos.
 */
export function LotPage() {
  const { lotId = '' } = useParams();
  const { api } = useAuth();
  // shortcut: the first 200 flags of the FPO filtered here (no `subject_id` filter in B08); use it once added.
  const flags = useQuery({
    queryKey: ['flags', 'all'],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/flags', { params: { query: { limit: ONE_PAGE } }, signal })),
    select: (page) => page.items.filter((flag) => flag.subject_id === lotId),
  });

  return (
    <Stack spacing={3}>
      <Button component={RouterLink} to="/flags" sx={{ alignSelf: 'start' }}>
        Back to flags
      </Button>
      <Typography component="h1" variant="h4">
        Lot {lotId.slice(0, 8)}
      </Typography>
      <LotHoldState lotId={lotId} />
      <section aria-labelledby="lot-flags-heading">
        <Typography id="lot-flags-heading" component="h2" variant="h6" gutterBottom>
          Flags on this lot
        </Typography>
        {flags.isError && <Alert severity="error">{errorMessage(flags.error)}</Alert>}
        {flags.isSuccess && <FlagsTable flags={flags.data} label="Flags on this lot" />}
        <Link component={RouterLink} to={`/flags?subject=${lotId}`}>
          Open flags of this lot
        </Link>
      </section>
      <section aria-labelledby="lot-photos-heading">
        <Typography id="lot-photos-heading" component="h2" variant="h6" gutterBottom>
          Evidence photos
        </Typography>
        <EvidencePhotos lotId={lotId} />
      </section>
    </Stack>
  );
}
