/**
 * Sign-in page: mobile number -> SMS code -> 4-digit PIN (office roles), one field per step.
 * Serves: System Architecture "Login" (OTP, admins add a PIN), User Flows "Log in once ... No passwords",
 * plan §7.3 P00 (login passes with MSW). Called by: src/AppRoutes.tsx (`/login`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Navigate, useLocation } from 'react-router';
import { z } from 'zod';
import { errorMessage } from '../api/errors';
import { requestOtp, verifyOtp, verifyPin, type TokenResponse } from './authApi';
import { useAuth } from './AuthProvider';

const phoneForm = z.object({
  value: z.string().regex(/^[6-9]\d{9}$/, 'Enter the 10-digit mobile number.'),
});
const otpForm = z.object({
  value: z.string().regex(/^\d{6}$/, 'Enter the 6-digit code from the SMS.'),
});
const pinForm = z.object({ value: z.string().regex(/^\d{4}$/, 'Enter your 4-digit PIN.') });

type Step = { kind: 'phone' } | { kind: 'otp'; phone: string } | { kind: 'pin'; token: string };

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
      setError('root', { message: errorMessage(error) });
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

  if (session) {
    const from = (location.state as { from?: string } | null)?.from ?? '/';
    return <Navigate to={from} replace />;
  }

  /**
   * Finishes sign-in, or moves to the PIN step when the role needs one.
   * @param tokens Response of OTP or PIN verify.
   */
  function accept(tokens: TokenResponse): void {
    if (tokens.pin_required) {
      setStep({ kind: 'pin', token: tokens.access_token });
      return;
    }
    signIn({
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      role: tokens.role,
      fpoId: tokens.fpo_id,
    });
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
              accept(await verifyOtp(step.phone, code));
            }}
          />
        )}
        {step.kind === 'pin' && (
          <StepForm
            key="pin"
            label="PIN"
            schema={pinForm}
            submitLabel="Sign in"
            inputMode="numeric"
            autoComplete="off"
            secret
            onSubmit={async (pin) => {
              accept(await verifyPin(step.token, pin));
            }}
          />
        )}
      </Paper>
    </Container>
  );
}
