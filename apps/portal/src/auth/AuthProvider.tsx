/**
 * Session state for the portal: who is signed in, sign-in/sign-out, and the API client bound to the token.
 * Serves: plan §7.3 P00 (auth guard), FR14 role-based access, System Architecture "Login".
 * Called by: src/AppProviders.tsx (provider), src/auth/RequireAuth.tsx, src/auth/LoginPage.tsx, src/layout/AppLayout.tsx and screens (`useAuth`).
 */
import { useQueryClient } from '@tanstack/react-query';
import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react';
import { z } from 'zod';
import { createApiClient, type ApiClient } from '../api/client';

const sessionSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  role: z.string(),
  fpoId: z.string(),
});

/** A signed-in user's tokens and scope. */
export type Session = z.infer<typeof sessionSchema>;

/** What `useAuth` returns. */
export interface AuthContextValue {
  /** The current session, or null when signed out. */
  session: Session | null;
  /** Stores a completed session (after OTP and, for office roles, PIN). */
  signIn: (session: Session) => void;
  /** Clears the session and every cached query. */
  signOut: () => void;
  /** Typed API client that sends the current token. */
  api: ApiClient;
}

// shortcut: tokens live in sessionStorage (survive a reload, cleared when the tab closes) and are readable by
// page scripts; upgrade to an httpOnly refresh cookie when B02 defines the web token transport.
export const SESSION_STORAGE_KEY = 'agritrace.session';

const AuthContext = createContext<AuthContextValue | null>(null);

/**
 * Reads and validates the stored session.
 * @returns The stored session, or null when there is none or it is malformed.
 */
function readStoredSession(): Session | null {
  try {
    const parsed = sessionSchema.safeParse(
      JSON.parse(sessionStorage.getItem(SESSION_STORAGE_KEY) ?? 'null'),
    );
    return parsed.success ? parsed.data : null;
  } catch {
    return null;
  }
}

/**
 * Provides the session and API client to the tree. Must sit inside a `QueryClientProvider`.
 * @param props Component props.
 * @param props.children The app.
 * @returns The provider element.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  const [session, setSession] = useState(readStoredSession);

  const signIn = useCallback((next: Session) => {
    sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(next));
    setSession(next);
  }, []);

  // TODO(B02): POST /v1/auth/logout to revoke the refresh token before clearing it here.
  const signOut = useCallback(() => {
    sessionStorage.removeItem(SESSION_STORAGE_KEY);
    queryClient.clear();
    setSession(null);
  }, [queryClient]);

  const api = useMemo(
    () => createApiClient(session?.accessToken ?? null, signOut),
    [session, signOut],
  );
  const value = useMemo(() => ({ session, signIn, signOut, api }), [session, signIn, signOut, api]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

/**
 * Reads the auth context.
 * @returns Session, sign-in/out functions and the API client.
 * @throws {Error} When called outside `AuthProvider` (a wiring bug).
 */
export function useAuth(): AuthContextValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used inside <AuthProvider>');
  return value;
}
