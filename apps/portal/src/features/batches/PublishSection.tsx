/**
 * The batch's public page: Publish (greyed with every unmet reason), the build progress (polls the builds list
 * until `built` or `failed`), then the public URL `/b/<code>`, the QR image, "Download labels" and a sandboxed
 * preview; below it the builds history with Rebuild for admins.
 * Serves: FR15 (publish and rebuild the public page), FR12 (QR to the public URL), FR62 (pack labels), FR63
 * (consumer page preview), D-007 (page built by a worker), plan §7.3 P04 (happy path → published + URL).
 * Called by: BatchPage.tsx.
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import LinearProgress from '@mui/material/LinearProgress';
import Link from '@mui/material/Link';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';
import { dayMonth } from '../flags/flagModel';
import {
  gateReasonText,
  publishReasons,
  type BatchOut,
  type BuildOut,
  type GateReason,
} from './batchModel';
import { GatedButton, GateReasons } from './ReadyLotsPage';

/** How often the builds list is re-read while a build is queued (a build takes seconds). */
const BUILD_POLL_MS = 2000;
/** How long after Publish or Rebuild the page keeps polling a queued build before it suggests Rebuild. */
const BUILD_WAIT_MS = 120_000;

const BUILD_STATUS: Readonly<Record<string, string>> = {
  queued: 'Building',
  built: 'Built',
  failed: 'Failed',
  superseded: 'Superseded',
};

/**
 * The public page URL and the preview source of a batch.
 * @param code Batch code.
 * @returns `url`: `{public origin}/b/<code>`; `preview`: the API's dev proxy in development, else the URL.
 */
export function pageUrls(code: string): { url: string; preview: string } {
  // DECISION D-050: the public origin comes from `VITE_PUBLIC_BASE_URL` (same origin when unset); the dev
  //   preview reads the API's dev proxy because `/b/<code>` needs the CDN rewrite.
  //   ADV: no contract change; the preview works locally without a CDN; one build-time setting per environment.
  //   COMPROMISE: the setting must match the API's `PUBLIC_BASE_URL` (the QR encodes the API's value).
  const url = `${import.meta.env.VITE_PUBLIC_BASE_URL ?? window.location.origin}/b/${code}`;
  return { url, preview: import.meta.env.DEV ? `/v1/public/batches/${code}` : url };
}

/**
 * A blob as a `data:` URL, so the image needs no object URL to revoke.
 * @param blob A small image (the QR PNG is a few KB; the spread below is fine far beyond that).
 * @returns The data URL.
 * @throws {TypeError} When the blob cannot be read (passed through from `arrayBuffer`).
 */
async function dataUrl(blob: Blob): Promise<string> {
  const bytes = new Uint8Array(await blob.arrayBuffer());
  return `data:${blob.type || 'image/png'};base64,${btoa(String.fromCharCode(...bytes))}`;
}

/**
 * The live page of the batch: URL, QR, labels download and the preview.
 * @param props Component props.
 * @param props.batch The published batch.
 * @param props.build The newest `built` build (its number reloads the preview).
 * @returns The live page block.
 */
function LivePage({ batch, build }: { batch: BatchOut; build: BuildOut }) {
  const { api } = useAuth();
  const path = { batch_id: batch.id };
  const { url, preview } = pageUrls(batch.code);
  // The QR and labels need the bearer token, so they are fetched, not linked.
  const qr = useQuery({
    queryKey: ['batches', batch.id, 'qr'],
    queryFn: async ({ signal }) =>
      dataUrl(
        await unwrap(
          api.GET('/v1/batches/{batch_id}/qr.png', { params: { path }, parseAs: 'blob', signal }),
        ),
      ),
  });
  const labels = useMutation({
    mutationFn: () =>
      unwrap(api.GET('/v1/batches/{batch_id}/labels.pdf', { params: { path }, parseAs: 'blob' })),
    onSuccess: (blob) => {
      const href = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = href;
      a.download = `labels-${batch.code}.pdf`;
      a.click();
      // Some browsers start the download after the click handler returns; FileSaver.js waits 40 s too.
      setTimeout(() => {
        URL.revokeObjectURL(href);
      }, 40_000);
    },
  });
  return (
    <Stack spacing={2}>
      <Alert severity="success">
        Published. Public page:{' '}
        <Link href={url} target="_blank" rel="noopener">
          {url}
        </Link>
      </Alert>
      <Stack direction="row" spacing={3} useFlexGap sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
        {qr.isSuccess && (
          <img src={qr.data} width={160} height={160} alt={`QR code opening ${url}`} />
        )}
        {qr.isError && <Alert severity="error">{errorMessage(qr.error)}</Alert>}
        <Button
          variant="outlined"
          disabled={labels.isPending}
          onClick={() => {
            labels.mutate();
          }}
        >
          Download labels
        </Button>
      </Stack>
      {labels.isError && <GateReasons error={labels.error} />}
      <iframe
        key={build.build_no}
        title={`Preview of the public page of batch ${batch.code}`}
        src={preview}
        // The page is static HTML with inline CSS: no scripts, forms or same-origin access needed.
        sandbox=""
        style={{ width: '100%', height: 640, border: '1px solid #ccc', borderRadius: 4 }}
      />
    </Stack>
  );
}

/**
 * Why a build failed: the `public_record_invalid` field paths (values are never echoed).
 * @param props Component props.
 * @param props.build The failed build.
 * @returns An error alert.
 */
function BuildError({ build }: { build: BuildOut }) {
  const details = (build.error?.['details'] ?? []) as { loc?: unknown[]; msg?: string }[];
  return (
    <Alert severity="error">
      Build {build.build_no} failed: the page data did not pass the public page checks. Correct the
      record, then Rebuild.
      {details.length > 0 && (
        <ul aria-label="Failed fields">
          {details.map((d, i) => (
            <li key={i}>
              {(d.loc ?? []).join(' › ')}: {d.msg}
            </li>
          ))}
        </ul>
      )}
    </Alert>
  );
}

/**
 * Publish, build progress, the live page and the builds history.
 * @param props Component props.
 * @param props.batch The batch.
 * @param props.isAdmin Whether the session has the `fpo_admin` role (preview; the server answers 403).
 * @param props.holds Hold reasons of the batch and its lots.
 * @returns The public page section, plus the builds section once published.
 */
export function PublishSection(props: { batch: BatchOut; isAdmin: boolean; holds: GateReason[] }) {
  const { batch, isAdmin, holds } = props;
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const path = { batch_id: batch.id };
  const published = batch.status === 'published';
  /**
   * Re-reads the batch and everything under its key (builds, grade) after a publish or rebuild.
   * @returns The invalidation promise.
   */
  const refresh = () => queryClient.invalidateQueries({ queryKey: ['batches', batch.id] });
  const publish = useMutation({
    mutationFn: () => unwrap(api.POST('/v1/batches/{batch_id}/publish', { params: { path } })),
    onSuccess: refresh,
  });
  const rebuild = useMutation({
    mutationFn: () => unwrap(api.POST('/v1/batches/{batch_id}/rebuild', { params: { path } })),
    onSuccess: refresh,
  });
  // B10 can leave a build queued for good (broker down, S3 retries spent): poll the newest build for two
  // minutes after this page's Publish or Rebuild, then point the admin at Rebuild (B10 supersedes the old row).
  const since = Math.max(publish.submittedAt, rebuild.submittedAt);
  /**
   * Whether the newest build is still worth polling.
   * @param newest The newest build, if any.
   * @param readAt When the builds list was last read (`dataUpdatedAt`, ms), so the check stays pure.
   * @returns True while it is queued and the wait since this page's last Publish or Rebuild is not over.
   */
  const waiting = (newest: BuildOut | undefined, readAt: number) =>
    newest?.status === 'queued' && since > 0 && readAt - since < BUILD_WAIT_MS;
  const builds = useQuery({
    queryKey: ['batches', batch.id, 'builds'],
    enabled: published,
    // shortcut: one page of 200 builds (one per publish or rebuild); page through if a batch ever has more.
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/batches/{batch_id}/builds', {
          params: { path, query: { limit: 200 } },
          signal,
        }),
      ),
    refetchInterval: (query) =>
      waiting(query.state.data?.items.at(-1), query.state.dataUpdatedAt) ? BUILD_POLL_MS : false,
    // Every poll re-renders (an unchanged list too), so the page notices when the wait is over.
    notifyOnChangeProps: ['data', 'error', 'status', 'dataUpdatedAt'],
  });
  const items = builds.data?.items ?? [];
  const latest = items.at(-1);
  const live = items.findLast((b) => b.status === 'built');

  return (
    <>
      <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="publish-heading">
        <Stack spacing={2}>
          <Typography id="publish-heading" component="h2" variant="h6">
            Public page
          </Typography>
          {!published && (
            <GatedButton
              label="Publish"
              reasons={publishReasons(batch, isAdmin, holds).map(gateReasonText)}
              busy={publish.isPending}
              onClick={() => {
                publish.mutate();
              }}
            />
          )}
          {publish.isError && <GateReasons error={publish.error} />}
          {builds.isError && <Alert severity="error">{errorMessage(builds.error)}</Alert>}
          {latest?.status === 'queued' &&
            (waiting(latest, builds.dataUpdatedAt) ? (
              <Stack spacing={1}>
                <Typography>Building the public page (build {latest.build_no})…</Typography>
                <LinearProgress aria-label="Building the public page" />
              </Stack>
            ) : (
              <Alert severity="warning">
                Build {latest.build_no} is taking longer than expected. Press Rebuild to try again.
              </Alert>
            ))}
          {latest?.status === 'failed' && <BuildError build={latest} />}
          {live && <LivePage batch={batch} build={live} />}
        </Stack>
      </Paper>
      {published && (
        <section aria-labelledby="builds-heading">
          <Stack spacing={2}>
            <Typography id="builds-heading" component="h2" variant="h6">
              Page builds
            </Typography>
            <Table size="small" aria-label="Page builds">
              <TableHead>
                <TableRow>
                  <TableCell>Build</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Trigger</TableCell>
                  <TableCell align="right">Generation</TableCell>
                  <TableCell>Built</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {items.map((b) => (
                  <TableRow key={b.id}>
                    <TableCell>{b.build_no}</TableCell>
                    <TableCell>{BUILD_STATUS[b.status] ?? b.status}</TableCell>
                    <TableCell>{b.trigger}</TableCell>
                    <TableCell align="right">{b.generation}</TableCell>
                    <TableCell>{b.built_at ? dayMonth(b.built_at) : '—'}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            {rebuild.isError && <GateReasons error={rebuild.error} />}
            <GatedButton
              label="Rebuild"
              reasons={isAdmin ? [] : [gateReasonText({ code: 'fpo_admin_only' })]}
              busy={rebuild.isPending}
              onClick={() => {
                rebuild.mutate();
              }}
            />
          </Stack>
        </section>
      )}
    </>
  );
}
