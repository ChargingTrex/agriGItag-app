/**
 * Processors screen: the processors this FPO sells to, and a minimal form to register one.
 * Serves: gap analysis "Processor management (separate from FPO)" (PRD §5 Processor entity), FR62 (FSSAI and
 * GI authorised-user numbers), Dataflow Stage 7 (lot intake references a processor), plan §7.3 P01.
 * Called by: src/AppRoutes.tsx (`/processors`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useForm, useWatch } from 'react-hook-form';
import { z } from 'zod';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useAuth } from '../../auth/AuthProvider';

const KINDS = { company: 'Company', coop: 'Co-operative', fpo: 'FPO' } as const;

// Limits mirror ProcessorIn in openapi.json; the server validates again.
const processorForm = z.object({
  name: z.string().trim().min(1, 'Enter the registered name.').max(200),
  kind: z.enum(['company', 'coop', 'fpo']),
  fssai_no: z.string().trim().max(32),
  gi_authorised_user_no: z.string().trim().max(64),
});

/**
 * The Processors page.
 * @returns The list and the create form.
 */
export function ProcessorsPage() {
  const { api } = useAuth();
  const queryClient = useQueryClient();
  // The endpoint returns a plain array (no Page): an FPO registers a handful of processors.
  const processors = useQuery({
    queryKey: ['processors'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/processors', { signal })),
  });
  const form = useForm({
    resolver: zodResolver(processorForm),
    defaultValues: { name: '', kind: 'company' as const, fssai_no: '', gi_authorised_user_no: '' },
  });
  const create = useMutation({
    mutationFn: (values: z.infer<typeof processorForm>) =>
      unwrap(
        api.POST('/v1/processors', {
          body: {
            name: values.name,
            kind: values.kind,
            fssai_no: values.fssai_no || null,
            gi_authorised_user_no: values.gi_authorised_user_no || null,
          },
        }),
      ),
    onSuccess: () => {
      form.reset();
      return queryClient.invalidateQueries({ queryKey: ['processors'] });
    },
  });
  const { errors } = form.formState;
  const kind = useWatch({ control: form.control, name: 'kind' });

  return (
    <Stack spacing={4}>
      <Typography component="h1" variant="h4">
        Processors
      </Typography>

      <section aria-labelledby="processor-list-heading">
        <Typography id="processor-list-heading" component="h2" variant="h6" gutterBottom>
          Registered processors
        </Typography>
        {processors.isError && <Alert severity="error">{errorMessage(processors.error)}</Alert>}
        {processors.isSuccess && processors.data.length === 0 && (
          <Typography color="text.secondary">No processor registered yet.</Typography>
        )}
        {processors.isSuccess && processors.data.length > 0 && (
          <Table size="small" aria-label="Registered processors">
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>FSSAI no.</TableCell>
                <TableCell>GI authorised user no.</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {processors.data.map((processor) => (
                <TableRow key={processor.id}>
                  <TableCell>{processor.name}</TableCell>
                  <TableCell>{KINDS[processor.kind]}</TableCell>
                  <TableCell>{processor.fssai_no ?? '—'}</TableCell>
                  <TableCell>{processor.gi_authorised_user_no ?? '—'}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </section>

      <Paper
        component="form"
        noValidate
        aria-labelledby="processor-form-heading"
        sx={{ p: 3, maxWidth: 520 }}
        onSubmit={(event) =>
          void form.handleSubmit((values) => {
            create.mutate(values);
          })(event)
        }
      >
        <Stack spacing={2}>
          <Typography id="processor-form-heading" component="h2" variant="h6">
            Register a processor
          </Typography>
          {create.isError && <Alert severity="error">{errorMessage(create.error)}</Alert>}
          <TextField
            {...form.register('name')}
            label="Registered name"
            required
            error={Boolean(errors.name)}
            helperText={errors.name?.message}
          />
          <TextField
            select
            label="Type"
            value={kind}
            onChange={(event) => {
              form.setValue('kind', event.target.value as keyof typeof KINDS);
            }}
          >
            {(Object.keys(KINDS) as (keyof typeof KINDS)[]).map((kind) => (
              <MenuItem key={kind} value={kind}>
                {KINDS[kind]}
              </MenuItem>
            ))}
          </TextField>
          <TextField
            {...form.register('fssai_no')}
            label="FSSAI licence no."
            error={Boolean(errors.fssai_no)}
            helperText={errors.fssai_no?.message}
          />
          <TextField
            {...form.register('gi_authorised_user_no')}
            label="GI authorised user no."
            error={Boolean(errors.gi_authorised_user_no)}
            helperText={errors.gi_authorised_user_no?.message}
          />
          <Button type="submit" variant="contained" size="large" disabled={create.isPending}>
            Register processor
          </Button>
        </Stack>
      </Paper>
    </Stack>
  );
}
