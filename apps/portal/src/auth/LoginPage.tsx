/**
 * Sign-in page: mobile number -> SMS code -> 4-digit PIN (office roles), one field per step. On an office
 * user's first sign-in (`pin_set: false`) the PIN is chosen and typed twice.
 * Serves: System Architecture "Login" (OTP, admins add a PIN), User Flows "Log in once ... No passwords",
 * D-024, plan §7.3 P00 (login passes with MSW) and P01 (final B02 contract). Called by: src/AppRoutes.tsx
 * (`/login`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import LinearProgress from '@mui/material/LinearProgress';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Navigate, useLocation } from 'react-router';
import { z } from 'zod';
import { ApiError, errorMessage } from '../api/errors';
import { requestOtp, verifyOtp, verifyPin } from './authApi';
import { useAuth } from './AuthProvider';

const phoneForm = z.object({
  value: z.string().regex(/^[6-9]\d{9}$/, 'Enter the 10-digit mobile number.'),
});
const otpForm = z.object({
  value: z.string().regex(/^\d{6}$/, 'Enter the 6-digit code from the SMS.'),
});
const pinForm = z.object({ value: z.string().regex(/^\d{4}$/, 'Enter your 4-digit PIN.') });

type Step =
  | { kind: 'phone' }
  | { kind: 'otp'; phone: string }
  | { kind: 'pin'; token: string; pinSet: boolean }
  | { kind: 'confirm'; token: string; pin: string };

/**
 * The message for a failed sign-in step: the generated text for the code plus the limit the API sent.
 * @param error Whatever the step threw.
 * @returns One sentence or two, e.g. "The PIN is not correct. 3 attempts left."
 */
export function signInError(error: unknown): string {
  const message = errorMessage(error);
  if (!(error instanceof ApiError)) return message;
  const details = (error.details ?? {}) as Record<string, unknown>;
  const { attempts_left: attempts, locked_until: until, retry_after_s: wait } = details;
  if (error.code === 'pin_invalid' && typeof attempts === 'number') {
    return `${message} ${String(attempts)} attempts left.`;
  }
  if (error.code === 'pin_locked' && typeof until === 'string') {
    const time = new Date(until).toLocaleTimeString('en-IN', {
      hour: '2-digit',
      minute: '2-digit',
    });
    return `${message} You can try again at ${time}.`;
  }
  if (error.code === 'rate_limited' && typeof wait === 'number') {
    return `${message} Try again in ${String(wait)} seconds.`;
  }
  return message;
}

/** Props of one login step. */
interface StepFormProps {
  /** Field label, also its accessible name. */
  label: string;
  /** Validation for the single field. */
  schema: typeof phoneForm;
  /** Submit button text. */
  submitLabel: string;
  /** Mobile keyboard to show. */
  inputMode: 'tel' | 'numeric';
  /** Browser autofill hint. */
  autoComplete: string;
  /** Mask the value (PIN). */
  secret?: boolean;
  /** Called with the validated value; its rejection is shown above the field. */
  onSubmit: (value: string) => Promise<void>;
}

/**
 * One validated field with a submit button; API errors are shown via the generated error-code table.
 * @param props See `StepFormProps`.
 * @returns The form.
 */
function StepForm(props: StepFormProps) {
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm({ resolver: zodResolver(props.schema), defaultValues: { value: '' } });
  const { ref, ...field } = register('value');
  const submit = handleSubmit(async ({ value }) => {
    try {
      await props.onSubmit(value);
    } catch (error) {
      setError('root', { message: signInError(error) });
    }
  });
  return (
    <Stack component="form" noValidate spacing={2} onSubmit={(event) => void submit(event)}>
      {errors.root && <Alert severity="error">{errors.root.message}</Alert>}
      <TextField
        {...field}
        inputRef={ref}
        label={props.label}
        type={props.secret ? 'password' : 'text'}
        error={Boolean(errors.value)}
        helperText={errors.value?.message}
        autoFocus
        fullWidth
        slotProps={{
          htmlInput: { inputMode: props.inputMode, autoComplete: props.autoComplete },
        }}
      />
      <Button type="submit" variant="contained" size="large" disabled={isSubmitting}>
        {props.submitLabel}
      </Button>
    </Stack>
  );
}

/**
 * The sign-in page. Redirects to the page the guard came from once a full session exists.
 * @returns The page, or a redirect when already signed in.
 */
export function LoginPage() {
  const { session, signIn } = useAuth();
  const location = useLocation();
  const [step, setStep] = useState<Step>({ kind: 'phone' });

  if (session === undefined) return <LinearProgress aria-label="Restoring session" />;
  if (session) {
    const from = (location.state as { from?: string } | null)?.from ?? '/';
    return <Navigate to={from} replace />;
  }

  return (
    <Container maxWidth="xs" sx={{ py: 8 }}>
      <Paper sx={{ p: 4 }}>
        <Typography component="h1" variant="h5" gutterBottom>
          Sign in to AgriTrace
        </Typography>
        {step.kind === 'phone' && (
          <StepForm
            key="phone"
            label="Mobile number"
            schema={phoneForm}
            submitLabel="Send code"
            inputMode="tel"
            autoComplete="tel-national"
            onSubmit={async (value) => {
              const phone = `+91${value}`;
              await requestOtp(phone);
              setStep({ kind: 'otp', phone });
            }}
          />
        )}
        {step.kind === 'otp' && (
          <StepForm
            key="otp"
            label="SMS code"
            schema={otpForm}
            submitLabel="Verify code"
            inputMode="numeric"
            autoComplete="one-time-code"
            onSubmit={async (code) => {
              const result = await verifyOtp(step.phone, code);
              if (result.kind === 'session') signIn(result);
              else setStep({ kind: 'pin', token: result.pin_token, pinSet: result.pin_set });
            }}
          />
        )}
        {step.kind === 'pin' && (
          <StepForm
            key="pin"
            label={step.pinSet ? 'PIN' : 'Choose a 4-digit PIN'}
            schema={pinForm}
            submitLabel={step.pinSet ? 'Sign in' : 'Next'}
            inputMode="numeric"
            autoComplete={step.pinSet ? 'current-password' : 'new-password'}
            secret
            onSubmit={async (pin) => {
              if (step.pinSet) signIn(await verifyPin(step.token, pin));
              else setStep({ kind: 'confirm', token: step.token, pin });
            }}
          />
        )}
        {step.kind === 'confirm' && (
          <StepForm
            key="confirm"
            label="Type the PIN again"
            schema={z.object({
              value: z.string().refine((value) => value === step.pin, 'The two PINs differ.'),
            })}
            submitLabel="Save PIN and sign in"
            inputMode="numeric"
            autoComplete="new-password"
            secret
            onSubmit={async (pin) => {
              signIn(await verifyPin(step.token, pin));
            }}
          />
        )}
        {(step.kind === 'pin' || step.kind === 'confirm') && (
          // The pin token lives 5 minutes; after that only a new SMS code helps.
          <Button
            fullWidth
            sx={{ mt: 1 }}
            onClick={() => {
              setStep({ kind: 'phone' });
            }}
          >
            Start again
          </Button>
        )}
      </Paper>
    </Container>
  );
}
