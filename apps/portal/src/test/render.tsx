/**
 * Test helper: renders the real route table at a given path with fresh providers.
 * Serves: plan §7.3 P00 tests. Called by: *.test.tsx under src/.
 */
import { render, type RenderResult } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { AppProviders } from '../AppProviders';
import { AppRoutes } from '../AppRoutes';
import { SESSION_STORAGE_KEY, type Session } from '../auth/AuthProvider';
import { createQueryClient } from '../queryClient';

/** A complete session as the PIN step would store it. */
export const TEST_SESSION: Session = {
  accessToken: 'mock-access-token',
  refreshToken: 'mock-refresh-token',
  role: 'fpo_admin',
  fpoId: 'mock-fpo',
};

/**
 * Renders the app at `path`.
 * @param path Initial URL path.
 * @param session Session to pre-store (as after a previous sign-in), or null for signed out.
 * @returns The RTL render result.
 */
export function renderApp(path: string, session: Session | null = null): RenderResult {
  if (session) sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));
  return render(
    <MemoryRouter initialEntries={[path]}>
      <AppProviders queryClient={createQueryClient()}>
        <AppRoutes />
      </AppProviders>
    </MemoryRouter>,
  );
}
