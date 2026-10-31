/**
 * Session state for the portal: who is signed in, sign-in/sign-out, silent refresh through the httpOnly
 * cookie, and the API client bound to the access token.
 * Serves: FR14 role-based access, D-024 session model, D-022 web transport, plan §7.3 P00 (auth guard) and
 * P01 (final B02 contract). Called by: src/AppProviders.tsx (provider), src/auth/RequireAuth.tsx,
 * src/auth/LoginPage.tsx, src/layout/AppLayout.tsx and screens (`useAuth`).
 */
import { useQueryClient } from '@tanstack/react-query';
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { createApiClient, type ApiClient } from '../api/client';
import { logout, refreshSession, type SessionOut } from './authApi';

/** A signed-in session exactly as the API returned it (`refresh_token` is null on the web). */
export type Session = SessionOut;

/** Refresh this many seconds before the access token expires. */
const REFRESH_EARLY_S = 60;

/** What `useAuth` returns. */
export interface AuthContextValue {
  /** The current session; null when signed out; undefined while the refresh cookie is being tried. */
  session: Session | null | undefined;
  /** Stores a completed session (after OTP and, for office roles, PIN). */
  signIn: (session: Session) => void;
  /** Signs the device out on the server, clears the session and every cached query. */
  signOut: () => void;
  /** Typed API client that sends the current token. */
  api: ApiClient;
}

const AuthContext = createContext<AuthContextValue | null>(null);

/**
 * Provides the session and API client to the tree. Must sit inside a `QueryClientProvider`.
 * On mount it tries the refresh cookie once, so a reload keeps the user signed in without storing tokens.
 * @param props Component props.
 * @param props.children The app.
 * @returns The provider element.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  // DECISION D-024: the access token lives only in React state (memory); nothing goes to web storage.
  //   ADV: an XSS payload cannot read a stored token, and the 15-minute token dies with the tab; the refresh
  //   token is an httpOnly cookie (D-022) that restores the session after a reload.
  //   COMPROMISE: every page load costs one `POST /v1/auth/refresh` before the first screen renders.
  const [session, setSession] = useState<Session | null | undefined>(undefined);

  const signIn = useCallback((next: Session) => {
    setSession(next);
  }, []);

  const signOut = useCallback(() => {
    // Best effort: a dead token (the usual reason for signing out) cannot log out anyway.
    if (session) void logout(session.access_token).catch(() => undefined);
    setSession(null);
    queryClient.clear();
  }, [session, queryClient]);

  useEffect(() => {
    let live = true;
    refreshSession().then(
      (next) => {
        if (live) setSession(next);
      },
      () => {
        if (live) setSession(null);
      },
    );
    return () => {
      live = false;
    };
  }, []);

  useEffect(() => {
    if (!session) return;
    const timer = setTimeout(
      () => {
        refreshSession().then(setSession, signOut);
      },
      Math.max(session.expires_in - REFRESH_EARLY_S, 1) * 1000,
    );
    return () => {
      clearTimeout(timer);
    };
  }, [session, signOut]);

  const api = useMemo(
    () => createApiClient(session?.access_token ?? null, signOut),
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
