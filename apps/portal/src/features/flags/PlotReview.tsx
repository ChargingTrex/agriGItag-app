/**
 * Plot review form for flagged plots (map pin, needs review, near the edge, outside): approve the location or
 * keep it for review, optionally with a corrected pin, through the registry correct endpoint with a mandatory
 * reason; plus the plot's revision and last review.
 * Serves: FR70 (review method, outcome, date, reason), FR64/FR67 (pin and GI region check), FR71 (corrections
 * keep revisions), Dataflow Stage 0 "flagged plot review", plan §7.3 P02. Called by:
 * src/features/members/PlotPage.tsx (below the map).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { unwrap } from '../../api/client';
import { errorMessage } from '../../api/errors';
import type { components } from '../../api/generated/schema';
import { useAuth } from '../../auth/AuthProvider';
import { dayMonth, REASON_CODES } from './flagModel';

type PlotOut = components['schemas']['PlotOut'];

const OUTCOMES = {
  accepted: 'Approve the location',
  rejected: 'Keep it for review',
} as const;
const METHODS = {
  land_record: 'Land record',
  satellite: 'Satellite imagery',
  field_visit: 'Field visit',
} as const;

/**
 * A coordinate field: empty, or a number within ±`max`.
 * @param max Largest absolute value (90 for latitude, 180 for longitude).
 * @returns The zod schema.
 */
const coordinate = (max: number) =>
  z
    .string()
    .trim()
    .refine(
      (v) => v === '' || Math.abs(Number(v)) <= max,
      `Enter a number between -${String(max)} and ${String(max)}.`,
    );

const reviewForm = z
  .object({
    review_outcome: z.enum(['accepted', 'rejected'], { error: 'Choose an outcome.' }),
    review_method: z.enum(['land_record', 'satellite', 'field_visit'], {
      error: 'Choose how you checked.',
    }),
    reason_code: z.string().min(1, 'Choose a reason.'),
    reason_text: z.string().trim().max(500, 'Keep the note under 500 characters.'),
    lat: coordinate(90),
    lon: coordinate(180),
  })
  .refine((v) => (v.lat === '') === (v.lon === ''), {
    path: ['lon'],
    message: 'Enter both latitude and longitude, or neither.',
  });

/**
 * The review form and revision line for one plot.
 * @param props Component props.
 * @param props.plot The plot as last read.
 * @returns The section.
 */
export function PlotReview({ plot }: { plot: PlotOut }) {
  const { api, session } = useAuth();
  const queryClient = useQueryClient();
  const isAdmin = session?.roles.includes('fpo_admin') === true;
  const form = useForm({
    resolver: zodResolver(reviewForm),
    defaultValues: { reason_code: '', reason_text: '', lat: '', lon: '' },
  });
  const correct = useMutation({
    mutationFn: ({ lat, lon, reason_text, ...values }: z.infer<typeof reviewForm>) =>
      unwrap(
        api.POST('/v1/plots/{plot_id}/correct', {
          params: { path: { plot_id: plot.id } },
          body: {
            ...values,
            reason_text: reason_text || null,
            ...(lat ? { pin: { lat: Number(lat), lon: Number(lon) }, pin_method: 'map_pin' } : {}),
          },
        }),
      ),
    onSuccess: () => {
      form.reset();
      // The correction re-runs the plot rules on the server, which close or keep the plot's flags.
      return Promise.all([
        queryClient.invalidateQueries({ queryKey: ['plots'] }),
        queryClient.invalidateQueries({ queryKey: ['flags'] }),
      ]);
    },
  });
  const { errors } = form.formState;
  const disabled = !isAdmin || correct.isPending;

  return (
    <section aria-labelledby="review-heading">
      <Typography id="review-heading" component="h2" variant="h6" gutterBottom>
        Location review
      </Typography>
      {/* shortcut: no endpoint lists `plot_revisions` (B03/B14), so only the current revision and the last
          review are shown; list every revision once the registry adds GET /v1/plots/{id}/revisions. */}
      <Typography gutterBottom>
        Revision {plot.revision_no}
        {plot.reviewed_at
          ? `, last reviewed on ${dayMonth(plot.reviewed_at)}: ${plot.review_outcome ?? ''} (${plot.review_method ?? 'method not given'})`
          : ', not reviewed yet'}
      </Typography>
      {correct.isSuccess && (
        <Alert severity="success" sx={{ mb: 2 }}>
          Review saved.
        </Alert>
      )}
      {plot.location_status !== 'confirmed' && (
        <Paper
          component="form"
          noValidate
          aria-label="Review the plot location"
          sx={{ p: 3, maxWidth: 560 }}
          onSubmit={(event) =>
            void form.handleSubmit((values) => {
              correct.mutate(values);
            })(event)
          }
        >
          <Stack spacing={2}>
            {!isAdmin && (
              <Alert severity="info">Only an FPO admin can review or correct a plot.</Alert>
            )}
            {correct.isError && <Alert severity="error">{errorMessage(correct.error)}</Alert>}
            {(
              [
                ['review_outcome', 'Outcome', OUTCOMES, 'Choose an outcome'],
                ['review_method', 'How you checked', METHODS, 'Choose a method'],
                ['reason_code', 'Reason', REASON_CODES, 'Choose a reason'],
              ] as const
            ).map(([name, label, options, placeholder]) => (
              <TextField
                key={name}
                {...form.register(name)}
                select
                label={label}
                required
                disabled={disabled}
                error={Boolean(errors[name])}
                helperText={errors[name]?.message}
                slotProps={{ select: { native: true }, inputLabel: { shrink: true } }}
              >
                <option value="">{placeholder}</option>
                {Object.entries(options).map(([value, text]) => (
                  <option key={value} value={value}>
                    {text}
                  </option>
                ))}
              </TextField>
            ))}
            <TextField
              {...form.register('reason_text')}
              label="Note"
              multiline
              minRows={2}
              disabled={disabled}
              error={Boolean(errors.reason_text)}
              helperText={errors.reason_text?.message}
            />
            <Typography variant="body2" color="text.secondary">
              Corrected pin (optional), e.g. read from the land record or the satellite view:
            </Typography>
            <Stack direction="row" spacing={2}>
              <TextField
                {...form.register('lat')}
                label="Latitude"
                inputMode="decimal"
                disabled={disabled}
                error={Boolean(errors.lat)}
                helperText={errors.lat?.message}
              />
              <TextField
                {...form.register('lon')}
                label="Longitude"
                inputMode="decimal"
                disabled={disabled}
                error={Boolean(errors.lon)}
                helperText={errors.lon?.message}
              />
            </Stack>
            <Button
              type="submit"
              variant="contained"
              size="large"
              disabled={disabled}
              sx={{ alignSelf: 'start' }}
            >
              Save review
            </Button>
          </Stack>
        </Paper>
      )}
    </section>
  );
}
