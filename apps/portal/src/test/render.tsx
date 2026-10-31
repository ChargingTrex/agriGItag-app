/**
 * Test helper: renders the real route table at a given path with fresh providers.
 * Serves: plan §7.3 P00/P01 tests. Called by: *.test.tsx under src/.
 */
import { render, type RenderResult } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { AppProviders } from '../AppProviders';
import { AppRoutes } from '../AppRoutes';
import { mockState } from '../mocks/handlers';
import { createQueryClient } from '../queryClient';

/**
 * Renders the app at `path`.
 * @param path Initial URL path.
 * @param signedIn When true the mock refresh "cookie" is set, so the app restores a session on mount exactly
 *   as after a reload (D-024: no token is stored in the browser).
 * @returns The RTL render result.
 */
export function renderApp(path: string, signedIn = false): RenderResult {
  mockState.signedIn = signedIn;
  return render(
    <MemoryRouter initialEntries={[path]}>
      <AppProviders queryClient={createQueryClient()}>
        <AppRoutes />
      </AppProviders>
    </MemoryRouter>,
  );
}
