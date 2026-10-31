/**
 * Master data uploads: CSV import of farmers, villages and inputs. Per tab: the template (columns from the
 * tenant's field config, served by the API), a file picker, the server's dry-run report shown over the file's
 * rows (rejected rows in red with the error code, its message and the column), the counts, and Confirm, which
 * imports exactly the checked bytes.
 * Serves: PLAN gap analysis "Master data uploads", plan §7.3 P08 (template, dry-run preview, row-level error
 * report), FR53 (structured village directory with LGD code), FR56 (input list), D-017 (columns from
 * apps/api/config/fields), CLAUDE.md §6 (phone numbers masked on screen).
 * Called by: src/AppRoutes.tsx (`/uploads`).
 */
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import { alpha } from '@mui/material/styles';
import Tab from '@mui/material/Tab';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import Tabs from '@mui/material/Tabs';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link } from 'react-router';
import { unwrap, type ApiClient } from '../../api/client';
import { ApiError, errorMessage } from '../../api/errors';
import { ERROR_MESSAGES } from '../../api/generated/error-messages';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';
import { maskPhone, parseCsv, readCsvFile, type CsvFile } from './csvFile';

type Kind = 'farmers' | 'villages' | 'inputs';
type ImportReport = components['schemas']['ImportReport'];

const KINDS: Record<Kind, { label: string; entity: string; note: string }> = {
  farmers: {
    label: 'Farmers',
    entity: 'farmer',
    note: 'Imported farmers wait for approval on the Members page. Pick the village by its LGD code.',
  },
  villages: {
    label: 'Villages',
    entity: 'village',
    note: 'Villages are shared by every FPO: only the platform team (super-admin) can import them.',
  },
  inputs: {
    label: 'Inputs',
    entity: 'input',
    note: 'Fertilisers and pesticides for this FPO. A row with the same name and manufacturer is refused.',
  },
};
const PATHS = {
  farmers: '/v1/imports/farmers',
  villages: '/v1/imports/villages',
  inputs: '/v1/imports/inputs',
} as const;
const PAGE_SIZE = 100;

/** Thrown by Confirm when the file on disk no longer has the checked bytes. */
class FileChangedError extends Error {}

/**
 * Sends a CSV to the import endpoint.
 * @param api The session's API client.
 * @param kind Which master data.
 * @param file The checked file (its exact bytes are sent).
 * @param dryRun True: the server validates and rolls back.
 * @returns The row-level report.
 * @throws {ApiError} `import_too_large`, `validation_error` (unreadable CSV), `forbidden` (villages by an FPO
 *   admin) and any other error envelope.
 */
function postImport(api: ApiClient, kind: Kind, file: CsvFile, dryRun: boolean) {
  return unwrap(
    api.POST(PATHS[kind], {
      params: { query: { dry_run: dryRun } },
      // The spec types the binary part as a string; the serializer sends the real bytes as multipart.
      body: { file: '' },
      bodySerializer: () => {
        const form = new FormData();
        form.append('file', file.blob, file.name);
        return form;
      },
    }),
  );
}

/**
 * The message for a failed check or import: the generated text, plus the server's hint for an unreadable file.
 * @param error What the mutation threw.
 * @returns The text to show.
 */
function failureText(error: unknown): string {
  if (error instanceof FileChangedError)
    return 'The file changed after it was checked. Choose it again to check the new version.';
  const hint =
    error instanceof ApiError && typeof error.details === 'object' && error.details !== null
      ? (error.details as Record<string, unknown>)['file']
      : undefined;
  return typeof hint === 'string' ? `${errorMessage(error)} (${hint})` : errorMessage(error);
}

/**
 * The Master data uploads page.
 * @returns The page with one tab per kind.
 */
export function MasterDataPage() {
  const [kind, setKind] = useState<Kind>('farmers');
  return (
    <Stack spacing={3}>
      <Typography component="h1" variant="h4">
        Master data uploads
      </Typography>
      <Tabs
        value={kind}
        onChange={(_, value: Kind) => {
          setKind(value);
        }}
        aria-label="Master data"
      >
        {(Object.keys(KINDS) as Kind[]).map((k) => (
          <Tab
            key={k}
            value={k}
            label={KINDS[k].label}
            id={`tab-${k}`}
            aria-controls="import-panel"
          />
        ))}
      </Tabs>
      <div role="tabpanel" id="import-panel" aria-labelledby={`tab-${kind}`}>
        <ImportPanel key={kind} kind={kind} />
      </div>
    </Stack>
  );
}

/**
 * One kind's template, file picker, preview and Confirm.
 * @param props Component props.
 * @param props.kind Which master data.
 * @returns The panel.
 */
function ImportPanel({ kind }: { kind: Kind }) {
  const { api } = useAuth();
  const queryClient = useQueryClient();
  const { label, entity, note } = KINDS[kind];
  const [page, setPage] = useState(0);
  const fields = useQuery({
    queryKey: ['config', 'fields'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/config/fields', { signal })),
  });
  const template = useQuery({
    queryKey: ['imports', kind, 'template'],
    queryFn: ({ signal }) =>
      unwrap(
        api.GET('/v1/imports/{kind}/template.csv', {
          params: { path: { kind } },
          parseAs: 'text',
          signal,
        }),
      ),
  });
  const check = useMutation({
    mutationFn: async (picked: File) => {
      const file = await readCsvFile(picked);
      return { picked, file, report: await postImport(api, kind, file, true) };
    },
  });
  const commit = useMutation({
    mutationFn: async ({ picked, hash }: { picked: File; hash: string }) => {
      // Import only what was checked: re-read the file and refuse if its bytes changed since the dry run.
      const file = await readCsvFile(picked);
      if (file.hash !== hash) throw new FileChangedError();
      return postImport(api, kind, file, false);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [kind] }),
  });

  const spec = new Map(fields.data?.[entity]?.map((f) => [f.name, f]));
  const checked = check.data;
  const report: ImportReport | undefined = commit.data ?? checked?.report;
  const rejected = new Map(report?.rejected.map((r) => [r.row, r]));
  const rows = checked?.file.rows.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE) ?? [];

  return (
    <Stack spacing={3} sx={{ pt: 2 }}>
      <Typography>{note}</Typography>

      <section aria-labelledby="template-heading">
        <Typography id="template-heading" component="h2" variant="h6" gutterBottom>
          1. Download the template
        </Typography>
        {(template.isError || fields.isError) && (
          <Alert severity="error">{errorMessage(template.error ?? fields.error)}</Alert>
        )}
        {template.isSuccess && fields.isSuccess && (
          <Stack spacing={1} sx={{ alignItems: 'flex-start' }}>
            <Button
              variant="outlined"
              href={`data:text/csv;charset=utf-8,${encodeURIComponent(template.data)}`}
              download={`${kind}-template.csv`}
            >
              Download {label.toLowerCase()} template
            </Button>
            <Table size="small" aria-label={`${label} template columns`}>
              <TableHead>
                <TableRow>
                  <TableCell>Column</TableCell>
                  <TableCell>Meaning</TableCell>
                  <TableCell>Required</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {parseCsv(template.data).columns.map((name) => (
                  <TableRow key={name}>
                    <TableCell>
                      <code>{name}</code>
                    </TableCell>
                    <TableCell>{spec.get(name)?.label.en ?? name}</TableCell>
                    <TableCell>{spec.get(name)?.required ? 'Required' : 'Optional'}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Stack>
        )}
      </section>

      <section aria-labelledby="upload-heading">
        <Typography id="upload-heading" component="h2" variant="h6" gutterBottom>
          2. Check the filled file
        </Typography>
        <Stack spacing={1} sx={{ alignItems: 'flex-start' }}>
          <label htmlFor={`file-${kind}`}>CSV file (UTF-8, at most 2 MB and 5,000 rows)</label>
          <input
            id={`file-${kind}`}
            type="file"
            accept=".csv,text/csv"
            onChange={(event) => {
              const picked = event.target.files?.[0];
              // Cleared so that choosing the same (edited) file again fires another check.
              event.target.value = '';
              if (!picked) return;
              setPage(0);
              commit.reset();
              check.mutate(picked);
            }}
          />
          {check.isPending && <Typography>Checking the file…</Typography>}
          {check.isError && <Alert severity="error">{failureText(check.error)}</Alert>}
        </Stack>
      </section>

      {checked && report && fields.isSuccess && (
        <section aria-labelledby="preview-heading">
          <Typography id="preview-heading" component="h2" variant="h6" gutterBottom>
            {report.dry_run
              ? `3. Preview of ${checked.file.name}`
              : `Imported ${checked.file.name}`}
          </Typography>
          <Typography role="status" gutterBottom>
            {report.dry_run ? 'Rows that can be imported' : 'Rows imported'}: {report.accepted} ·
            Rows rejected: {report.rejected.length}
          </Typography>
          {commit.isError && <Alert severity="error">{failureText(commit.error)}</Alert>}
          {report.dry_run ? (
            <Button
              variant="contained"
              size="large"
              sx={{ my: 1 }}
              disabled={report.accepted === 0 || commit.isPending}
              onClick={() => {
                commit.mutate({ picked: checked.picked, hash: checked.file.hash });
              }}
            >
              Import {report.accepted} rows
            </Button>
          ) : (
            <Alert severity="success" sx={{ my: 1 }}>
              {report.accepted} rows imported.
              {report.rejected.length > 0 &&
                ' Fix the rejected rows and upload a file with only those rows.'}
              {kind === 'farmers' && (
                <>
                  {' '}
                  <Link to="/members">Open Members</Link> to approve the new farmers.
                </>
              )}
            </Alert>
          )}
          <Table size="small" aria-label={`Rows of ${checked.file.name}`}>
            <TableHead>
              <TableRow>
                <TableCell>Row</TableCell>
                {checked.file.columns.map((name) => (
                  <TableCell key={name}>{name}</TableCell>
                ))}
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {rows.map(({ row, cells }) => {
                const error = rejected.get(row);
                return (
                  <TableRow
                    key={row}
                    sx={error ? { bgcolor: (theme) => alpha(theme.palette.error.main, 0.1) } : {}}
                  >
                    <TableCell>{row}</TableCell>
                    {checked.file.columns.map((name) => (
                      <TableCell
                        key={name}
                        sx={
                          error?.field === name
                            ? { outline: 2, outlineColor: 'error.main', outlineOffset: -2 }
                            : {}
                        }
                      >
                        {spec.get(name)?.type === 'phone' || /phone|mobile/i.test(name)
                          ? maskPhone(cells[name] ?? '')
                          : cells[name]}
                      </TableCell>
                    ))}
                    <TableCell>
                      {error ? (
                        <Typography color="error" variant="body2">
                          <strong>Rejected</strong> {error.code}
                          {error.field && ` in ${error.field}`}:{' '}
                          {ERROR_MESSAGES[error.code] ?? error.code}
                        </Typography>
                      ) : (
                        'OK'
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
          {checked.file.rows.length > PAGE_SIZE && (
            <TablePagination
              component="div"
              count={checked.file.rows.length}
              page={page}
              rowsPerPage={PAGE_SIZE}
              rowsPerPageOptions={[]}
              onPageChange={(_, next) => {
                setPage(next);
              }}
            />
          )}
        </section>
      )}
    </Stack>
  );
}
