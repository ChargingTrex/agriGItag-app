/**
 * FPO settings: FSSAI licence and GI authorised-user numbers, the farmer-name opt-out for public pages, and the
 * tenant's feature flags and captured fields (read-only: they are edited in git, D-017).
 * Serves: FR62 (FSSAI and GI numbers), PRD §Security & Privacy (name opt-out per FPO policy), D-017 (config in
 * YAML), plan §7.3 P06 (Settings). Called by: src/AppRoutes.tsx (`/settings`).
 *
 * Read-only for now: the API has no FPO update route (`GET /v1/fpos/{id}` only), so per D-003 nothing is
 * hand-typed; the opt-out switch and numbers become editable for the FPO admin when B03 adds
 * `PATCH /v1/fpos/{id}` (TODO.md "B03 → P06"). The public page already honours `public_show_farmer_names`.
 */
import Alert from '@mui/material/Alert';
import FormControlLabel from '@mui/material/FormControlLabel';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Switch from '@mui/material/Switch';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import { useQuery } from '@tanstack/react-query';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';

/**
 * A config value as text.
 * @param value Boolean or number from `Features`.
 * @returns `On`/`Off` or the number.
 */
const flagText = (value: boolean | number) =>
  typeof value === 'boolean' ? (value ? 'On' : 'Off') : String(value);

/**
 * The FPO settings page.
 * @returns FPO numbers and name policy, feature flags and fields.
 */
export function SettingsPage() {
  const { api, session } = useAuth();
  const fpoId = session?.fpo_id ?? '';
  const fpo = useQuery({
    queryKey: ['fpos', fpoId],
    queryFn: ({ signal }) =>
      unwrap(api.GET('/v1/fpos/{fpo_id}', { params: { path: { fpo_id: fpoId } }, signal })),
  });
  const features = useQuery({
    queryKey: ['config', 'features'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/config/features', { signal })),
  });
  const fields = useQuery({
    queryKey: ['config', 'fields'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/config/fields', { signal })),
  });

  return (
    <Stack spacing={4}>
      <Typography component="h1" variant="h4">
        Settings
      </Typography>

      <section aria-labelledby="fpo-heading">
        <Typography id="fpo-heading" component="h2" variant="h6" gutterBottom>
          FPO details
        </Typography>
        {fpo.isPending && <LinearProgress aria-label="Loading FPO" />}
        {fpo.isError && <Alert severity="error">{errorMessage(fpo.error)}</Alert>}
        {fpo.isSuccess && (
          <Paper sx={{ p: 2 }}>
            <Stack spacing={1}>
              <Typography>
                {fpo.data.name} ({fpo.data.code})
              </Typography>
              <Typography>FSSAI licence no.: {fpo.data.fssai_no ?? 'Not recorded'}</Typography>
              <Typography>
                GI authorised-user no.: {fpo.data.gi_authorised_user_no ?? 'Not recorded'}
              </Typography>
              <FormControlLabel
                disabled
                control={<Switch checked={!fpo.data.public_show_farmer_names} />}
                label="Hide farmer names on public pages (opt-out)"
              />
              <Typography variant="body2" color="text.secondary">
                {fpo.data.public_show_farmer_names
                  ? 'Public pages show a farmer’s name only when that farmer consented.'
                  : 'Public pages show “Farmer 1”, “Farmer 2” instead of names, whatever the consent.'}{' '}
                Changing these needs the FPO update route, which the API does not have yet.
              </Typography>
            </Stack>
          </Paper>
        )}
      </section>

      <section aria-labelledby="flags-heading">
        <Typography id="flags-heading" component="h2" variant="h6" gutterBottom>
          Feature flags
        </Typography>
        <Typography variant="body2" color="text.secondary" gutterBottom>
          Read-only. Edited in git: apps/api/config/features.yaml and the FPO’s tenants file.
        </Typography>
        {features.isError && <Alert severity="error">{errorMessage(features.error)}</Alert>}
        {features.isSuccess && (
          <Table size="small" aria-label="Feature flags">
            <TableHead>
              <TableRow>
                <TableCell>Flag</TableCell>
                <TableCell>Value</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {Object.entries(features.data).map(([key, value]) => (
                <TableRow key={key}>
                  <TableCell>{key.replaceAll('_', ' ')}</TableCell>
                  <TableCell>{flagText(value)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </section>

      <section aria-labelledby="fields-heading">
        <Typography id="fields-heading" component="h2" variant="h6" gutterBottom>
          Fields captured
        </Typography>
        <Typography variant="body2" color="text.secondary" gutterBottom>
          Read-only. Edited in git: apps/api/config/fields/. Fields the FPO turned off are not
          listed.
        </Typography>
        {fields.isError && <Alert severity="error">{errorMessage(fields.error)}</Alert>}
        {fields.isSuccess && (
          <Table size="small" aria-label="Fields captured">
            <TableHead>
              <TableRow>
                <TableCell>Entity</TableCell>
                <TableCell>Field</TableCell>
                <TableCell>Required</TableCell>
                <TableCell>Who may see it</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {Object.entries(fields.data).flatMap(([entity, specs]) =>
                specs.map((spec) => (
                  <TableRow key={`${entity}.${spec.name}`}>
                    <TableCell>{entity.replaceAll('_', ' ')}</TableCell>
                    <TableCell>{spec.label.en}</TableCell>
                    <TableCell>{spec.required ? 'Yes' : 'No'}</TableCell>
                    <TableCell>{spec.visibility}</TableCell>
                  </TableRow>
                )),
              )}
            </TableBody>
          </Table>
        )}
      </section>
    </Stack>
  );
}
