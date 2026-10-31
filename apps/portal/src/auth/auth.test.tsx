/**
 * Tests the auth guard, the OTP + PIN login of the final B02 contract (pin_required, first PIN, pin_locked)
 * and the cookie-based session restore, against the MSW mock API.
 * Serves: plan §7.3 P00 "login passes with MSW", P01 auth adaptation, D-022/D-024. Called by: Vitest.
 */
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import {
  MOCK_LOCKED_PIN,
  MOCK_NEW_USER_PHONE,
  MOCK_OTP,
  MOCK_PIN,
  mockState,
} from '../mocks/handlers';
import { renderApp } from '../test/render';
import { server } from '../test/setup';
import { DEVICE_ID_KEY } from './authApi';

/**
 * Types the phone and the SMS code.
 * @param user The user-event instance.
 * @param phone Ten-digit mobile number.
 * @returns Resolves when the PIN field is on screen.
 */
async function passOtp(user: ReturnType<typeof userEvent.setup>, phone = '9876543210') {
  await user.type(await screen.findByLabelText('Mobile number'), phone);
  await user.click(screen.getByRole('button', { name: 'Send code' }));
  await user.type(await screen.findByLabelText('SMS code'), MOCK_OTP);
  await user.click(screen.getByRole('button', { name: 'Verify code' }));
}

describe('auth guard', () => {
  it('redirects a signed-out user from a protected route to the sign-in page', async () => {
    renderApp('/members');
    expect(
      await screen.findByRole('heading', { name: 'Sign in to AgriTrace' }),
    ).toBeInTheDocument();
    expect(screen.queryByRole('heading', { name: 'Members' })).not.toBeInTheDocument();
  });

  it('restores the session from the refresh cookie with X-Client: web and an empty body', async () => {
    const seen: { client: string | null; body: unknown }[] = [];
    server.events.on('request:start', ({ request }) => {
      if (new URL(request.url).pathname === '/v1/auth/refresh') {
        void request
          .clone()
          .json()
          .then((body: unknown) => seen.push({ client: request.headers.get('X-Client'), body }));
      }
    });
    renderApp('/members', true);
    expect(await screen.findByRole('heading', { name: 'Members' })).toBeInTheDocument();
    expect(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
    expect(seen).toEqual([{ client: 'web', body: {} }]);
    expect(sessionStorage.length).toBe(0);
    server.events.removeAllListeners();
  });
});

describe('login with MSW', () => {
  it('signs in an office user: otp -> pin_required -> pin/verify, then returns to the guarded page', async () => {
    const user = userEvent.setup();
    let verifyBody: Record<string, unknown> = {};
    server.events.on('request:start', ({ request }) => {
      if (new URL(request.url).pathname === '/v1/auth/otp/verify') {
        void request
          .clone()
          .json()
          .then((body: Record<string, unknown>) => (verifyBody = body));
      }
    });
    renderApp('/batches');

    await passOtp(user);
    await user.type(await screen.findByLabelText('PIN'), MOCK_PIN);
    await user.click(screen.getByRole('button', { name: 'Sign in' }));

    expect(await screen.findByRole('heading', { name: 'Batches' })).toBeInTheDocument();
    expect(verifyBody).toMatchObject({
      phone: '+919876543210',
      platform: 'web',
      device_id: localStorage.getItem(DEVICE_ID_KEY),
    });
    expect(mockState.signedIn).toBe(true);
    expect(sessionStorage.length).toBe(0);
    server.events.removeAllListeners();
  });

  it('lets a first-time office user choose a PIN and type it twice (pin_set false)', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await passOtp(user, MOCK_NEW_USER_PHONE);
    await user.type(await screen.findByLabelText('Choose a 4-digit PIN'), '4321');
    await user.click(screen.getByRole('button', { name: 'Next' }));
    await user.type(await screen.findByLabelText('Type the PIN again'), '4329');
    await user.click(screen.getByRole('button', { name: 'Save PIN and sign in' }));
    expect(await screen.findByText('The two PINs differ.')).toBeInTheDocument();

    await user.clear(screen.getByLabelText('Type the PIN again'));
    await user.type(screen.getByLabelText('Type the PIN again'), '4321');
    await user.click(screen.getByRole('button', { name: 'Save PIN and sign in' }));
    expect(await screen.findByRole('heading', { name: 'Dashboard' })).toBeInTheDocument();
  });

  it('shows attempts left for a wrong PIN and the unlock time for pin_locked', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await passOtp(user);
    await user.type(await screen.findByLabelText('PIN'), '9999');
    await user.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The PIN is not correct. 3 attempts left.',
    );

    await user.clear(screen.getByLabelText('PIN'));
    await user.type(screen.getByLabelText('PIN'), MOCK_LOCKED_PIN);
    await user.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(await screen.findByRole('alert')).toHaveTextContent(
      /Too many wrong PINs; try again in 5 minutes\. You can try again at \d{1,2}:\d{2}/,
    );
  });

  it('shows the message for the error code when the SMS code is wrong', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await user.type(await screen.findByLabelText('Mobile number'), '9876543210');
    await user.click(screen.getByRole('button', { name: 'Send code' }));
    await user.type(await screen.findByLabelText('SMS code'), '000000');
    await user.click(screen.getByRole('button', { name: 'Verify code' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('The code is not correct.');
  });

  it('shows the wait from rate_limited when a code is asked for too soon', async () => {
    server.use(
      http.post('/v1/auth/otp/request', () =>
        HttpResponse.json(
          { error: { code: 'rate_limited', message: 'x', details: { retry_after_s: 42 } } },
          { status: 429 },
        ),
      ),
    );
    const user = userEvent.setup();
    renderApp('/');

    await user.type(await screen.findByLabelText('Mobile number'), '9876543210');
    await user.click(screen.getByRole('button', { name: 'Send code' }));

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Too many requests. Try again in 42 seconds.',
    );
  });

  it('rejects a malformed phone number before calling the API', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await user.type(await screen.findByLabelText('Mobile number'), '12345');
    await user.click(screen.getByRole('button', { name: 'Send code' }));

    expect(await screen.findByText('Enter the 10-digit mobile number.')).toBeInTheDocument();
  });

  it('signs out on the server and returns to the sign-in page', async () => {
    const user = userEvent.setup();
    renderApp('/', true);

    await user.click(await screen.findByRole('button', { name: 'Sign out' }));

    expect(
      await screen.findByRole('heading', { name: 'Sign in to AgriTrace' }),
    ).toBeInTheDocument();
    await waitFor(() => {
      expect(mockState.signedIn).toBe(false);
    });
  });
});
