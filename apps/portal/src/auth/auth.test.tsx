/**
 * Tests the auth guard and the OTP + PIN login against the MSW mock API.
 * Serves: plan §7.3 P00 acceptance "login passes with MSW", auth guard redirects unauthenticated users.
 * Called by: Vitest (`npm test`).
 */
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';
import { MOCK_OTP, MOCK_PIN } from '../mocks/handlers';
import { renderApp, TEST_SESSION } from '../test/render';

describe('auth guard', () => {
  it('redirects a signed-out user from a protected route to the sign-in page', async () => {
    renderApp('/members');
    expect(
      await screen.findByRole('heading', { name: 'Sign in to AgriTrace' }),
    ).toBeInTheDocument();
    expect(screen.queryByRole('heading', { name: 'Members' })).not.toBeInTheDocument();
  });

  it('shows the protected route and the sidebar to a signed-in user', async () => {
    renderApp('/members', TEST_SESSION);
    expect(await screen.findByRole('heading', { name: 'Members' })).toBeInTheDocument();
    expect(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Ready lots' })).toHaveAttribute('href', '/ready-lots');
  });
});

describe('login with MSW', () => {
  it('signs in with phone, SMS code and PIN, then returns to the page the guard came from', async () => {
    const user = userEvent.setup();
    renderApp('/batches');

    await user.type(await screen.findByLabelText('Mobile number'), '9876543210');
    await user.click(screen.getByRole('button', { name: 'Send code' }));
    await user.type(await screen.findByLabelText('SMS code'), MOCK_OTP);
    await user.click(screen.getByRole('button', { name: 'Verify code' }));
    await user.type(await screen.findByLabelText('PIN'), MOCK_PIN);
    await user.click(screen.getByRole('button', { name: 'Sign in' }));

    expect(await screen.findByRole('heading', { name: 'Batches' })).toBeInTheDocument();
  });

  it('shows the message for the error code when the code is wrong', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await user.type(await screen.findByLabelText('Mobile number'), '9876543210');
    await user.click(screen.getByRole('button', { name: 'Send code' }));
    await user.type(await screen.findByLabelText('SMS code'), '000000');
    await user.click(screen.getByRole('button', { name: 'Verify code' }));

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The request has invalid or implausible values.',
    );
  });

  it('rejects a malformed phone number before calling the API', async () => {
    const user = userEvent.setup();
    renderApp('/');

    await user.type(await screen.findByLabelText('Mobile number'), '12345');
    await user.click(screen.getByRole('button', { name: 'Send code' }));

    expect(await screen.findByText('Enter the 10-digit mobile number.')).toBeInTheDocument();
  });
});
