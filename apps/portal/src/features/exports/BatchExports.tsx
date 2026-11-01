/**
 * The batch page's "Labels and exports" section: the pack label sheet (`labels-<batchId>.pdf`, B10) with what is on
 * it and a print hint, the audit trail CSV (B11 `audit-export.csv`) and a CSV of the batch's lots and shares built
 * in the browser. Every greyed button says why (role, packing, loading).
 * Serves: FR62 (pack labels), FR12 (QR on every pack), FR9 (batch ID in the file name), FR21 (CSV export), FR58
 * (unit on every quantity), FR60 (shares), plan §7.3 P05 (`labels-<batchId>.pdf`; CSV unit on every quantity).
 * Called by: src/features/batches/BatchPage.tsx.
 */
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useMutation } from '@tanstack/react-query';
import { unwrap } from '../../api/client';
import { useAuth } from '../../auth/AuthProvider';
import {
  formatKg,
  gateReasonText,
  toGrams,
  type BatchOut,
  type LotOut,
} from '../batches/batchModel';
import { GatedButton, GateReasons } from '../batches/ReadyLotsPage';
import { lotsCsvRows, saveBlob, saveCsv } from './exportModel';

/** Labels per A4 sheet, as B10 `labels_pdf` draws them (2 × 4). */
export const LABELS_PER_SHEET = 8;

/**
 * Labels, audit CSV and lots CSV of one batch.
 * @param props Component props.
 * @param props.batch The batch.
 * @param props.lots The share lots loaded so far (for their codes).
 * @param props.lotsLoading True while a share lot is still being read.
 * @param props.farmerName Name per farmer id (P03 `useFarmerNames`; `pending` while a name is being read).
 * @returns The section.
 */
export function BatchExports(props: {
  batch: BatchOut;
  lots: readonly LotOut[];
  lotsLoading: boolean;
  farmerName: ((id: string) => string) & { pending: boolean };
}) {
  const { batch, lots, lotsLoading, farmerName } = props;
  const { api, session } = useAuth();
  const roles = session?.roles ?? [];
  const path = { batch_id: batch.id };
  // The PDF and the audit CSV need the bearer token, so they are fetched, not linked (D-050).
  const labels = useMutation({
    mutationFn: () =>
      unwrap(api.GET('/v1/batches/{batch_id}/labels.pdf', { params: { path }, parseAs: 'blob' })),
    onSuccess: (blob) => {
      saveBlob(blob, `labels-${batch.code}.pdf`);
    },
  });
  const audit = useMutation({
    mutationFn: () =>
      unwrap(
        api.GET('/v1/batches/{batch_id}/audit-export.csv', {
          params: { path },
          parseAs: 'arrayBuffer',
        }),
      ),
    onSuccess: (bytes) => {
      // B11 writes no BOM; prepend one so Excel opens Tamil names right (D-051). The bytes are kept as sent.
      const blob = new Blob(['\uFEFF', bytes], { type: 'text/csv;charset=utf-8' });
      saveBlob(blob, `audit-${batch.code}.csv`);
    },
  });
  const packed = batch.status === 'packed' || batch.status === 'published';
  // UI preview of the server's roles (B10 labels: any office role, P05 offers it to admin and QC; B11 audit CSV:
  // admin or viewer); the server answers 403 / 409 anyway.
  const labelReasons = [
    ...(roles.includes('fpo_admin') || roles.includes('qc_officer')
      ? []
      : ['Only an FPO admin or QC officer prints labels.']),
    ...(packed ? [] : [gateReasonText({ code: 'final_packing_missing' })]),
  ];
  const auditReasons =
    roles.includes('fpo_admin') || roles.includes('viewer')
      ? []
      : ['Only an FPO admin or viewer can download the audit trail.'];

  return (
    <Paper variant="outlined" sx={{ p: 2 }} component="section" aria-labelledby="exports-heading">
      <Stack spacing={2}>
        <Typography id="exports-heading" component="h2" variant="h6">
          Labels and exports
        </Typography>
        <Typography>
          Pack labels: one A4 sheet of {LABELS_PER_SHEET} labels, each with the batch QR, product,
          batch ID {batch.code}
          {batch.packed ? `, net ${formatKg(toGrams(batch.packed.value))}` : ''}, pack and
          best-before dates and FSSAI number. Stick one label on every pack.
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Print at 100 % (actual size, not &ldquo;fit to page&rdquo;) on A4, as many sheets as you
          have packs divided by {LABELS_PER_SHEET}.
        </Typography>
        <GatedButton
          label="Download labels"
          reasons={labelReasons}
          busy={labels.isPending}
          onClick={() => {
            labels.mutate();
          }}
        />
        {labels.isError && <GateReasons error={labels.error} />}
        <Typography>
          Audit trail: every version of every event of the batch and its lots, with who entered it
          and the assist session.
        </Typography>
        <GatedButton
          label="Download audit CSV"
          reasons={auditReasons}
          busy={audit.isPending}
          onClick={() => {
            audit.mutate();
          }}
        />
        {audit.isError && <GateReasons error={audit.error} />}
        <Typography>
          Lots and shares: lot code, farmer, harvested, on-farm packed and received kg, the share of
          the final packed kg (derived: packed kg × share %) and share %.
        </Typography>
        <GatedButton
          label="Download lots CSV"
          reasons={[
            ...(lotsLoading ? ['Loading the lots…'] : []),
            ...(farmerName.pending ? ['Loading farmer names…'] : []),
          ]}
          onClick={() => {
            const byId = new Map(lots.map((lot) => [lot.id, lot]));
            saveCsv(lotsCsvRows(batch, byId, farmerName), `batch-${batch.code}-lots.csv`);
          }}
        />
      </Stack>
    </Paper>
  );
}
