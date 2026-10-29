/**
 * Context providers shared by the app and the tests: TanStack Query, MUI theme, session.
 * Serves: plan §7.3 P00 (shell). Called by: src/main.tsx, src/test/render.tsx.
 *
 * DECISION D-018: server state lives in TanStack Query and UI state in React state/context; no other state
 * library, no wrapper components around MUI, no theme system beyond MUI's `createTheme`.
 *   ADV: one caching/retry model for every screen; fewer dependencies and abstractions to learn.
 *   COMPROMISE: cross-screen client state (rare in an admin portal) must go through context or the URL.
 */
import CssBaseline from '@mui/material/CssBaseline';
import { ThemeProvider } from '@mui/material/styles';
import { QueryClientProvider, type QueryClient } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { AuthProvider } from './auth/AuthProvider';
import { theme } from './theme';

/**
 * Wraps the app in its providers.
 * @param props Component props.
 * @param props.queryClient The query client (a fresh one per test).
 * @param props.children Routes or the element under test.
 * @returns The provider tree.
 */
export function AppProviders({
  queryClient,
  children,
}: {
  queryClient: QueryClient;
  children: ReactNode;
}) {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AuthProvider>{children}</AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}
