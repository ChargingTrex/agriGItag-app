/**
 * Session state for the portal: who is signed in, sign-in/sign-out (with an error when the server cannot
 * sign the device out), silent refresh through the httpOnly cookie (before expiry, and once after a 401),
 * and the API client bound to the access token.
 * Serves: FR14 role-based access, D-024 session model, D-022 web transport, plan §7.3 P00 (auth guard) and
 * P01 (final B02 contract), P09 (sign-out that cannot fail silently). Called by: src/AppProviders.tsx
 * (provider), src/auth/RequireAuth.tsx, src/auth/LoginPage.tsx, src/layout/AppLayout.tsx and screens (`useAuth`).
 */
import Alert from '@mui/material/Alert';
import Snackbar from '@mui/material/Snackbar';
import { useQueryClient } from '@tanstack/react-query';
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import { createApiClient, type ApiClient } from '../api/client';
import { ApiError, errorMessage } from '../api/errors';
import { logout, refreshSession, type SessionOut } from './authApi';

/** A signed-in session exactly as the API returned it (`refresh_token` is null on the web). */
export type Session = SessionOut;

/** Refresh this many seconds before the access token expires. */
const REFRESH_EARLY_S = 60;
/** A 401 for a token that a recovery obtained less than this long ago means the server rejects it outright. */
const LOOP_WINDOW_MS = 10_000;

/** What `useAuth` returns. */
export interface AuthContextValue {
  /** The current session; null when signed out; undefined while the refresh cookie is being tried. */
  session: Session | null | undefined;
  /** Stores a completed session (after OTP and, for office roles, PIN). */
  signIn: (session: Session) => void;
  /**
   * Signs the device out on the server, then clears the session and every cached query; when the server
   * cannot be reached the session stays and an error is shown.
   */
  signOut: () => void;
  /** Typed API client that sends the current token; a 401 tries the refresh cookie once, then signs out. */
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
  // DECISION D-024: the access token lives only in memory (React state plus a ref); nothing goes to web storage.
  //   ADV: an XSS payload cannot read a stored token, and the 15-minute token dies with the tab; the refresh
  //   token is an httpOnly cookie (D-022) that restores the session after a reload.
  //   COMPROMISE: every page load costs one `POST /v1/auth/refresh` before the first screen renders.
  const [session, setSession] = useState<Session | null | undefined>(undefined);
  // The API client reads the token from here per request, so refetches never use a replaced token.
  const tokenRef = useRef<string | null>(null);

  /**
   * Stores a session (or null) in state and in the ref the API client reads.
   * @param next The new session, or null when signed out.
   */
  const store = useCallback((next: Session | null) => {
    tokenRef.current = next?.access_token ?? null;
    setSession(next);
  }, []);

  // One recovery per rejected token: concurrent 401s share it (and one logout), and a token that a recovery
  // obtained moments ago and that still gets a 401 ends the session instead of looping.
  const recoveringFor = useRef<string | null>(null);
  const recovered = useRef<{ token: string; at: number } | null>(null);

  // The message of the last sign-out that failed; null when there is none to show.
  const [signOutError, setSignOutError] = useState<string | null>(null);

  const signOut = useCallback(() => {
    const token = tokenRef.current;
    /**
     * Revokes the device on the server. A dead access token gets a 401, so it trades the refresh cookie for
     * a live one first; when the cookie is dead too nothing is left to revoke.
     * @returns Resolves when the device is signed out on the server (or had nothing left to sign out).
     * @throws {ApiError} Any refusal of logout other than a 401, or of the retried logout.
     * @throws {TypeError} When the network request fails.
     */
    const revoke = async () => {
      if (!token) return;
      try {
        await logout(token);
      } catch (error) {
        if (!(error instanceof ApiError && error.status === 401)) throw error;
        const next = await refreshSession().catch(() => null);
        if (next) await logout(next.access_token);
      }
    };
    revoke().then(
      () => {
        setSignOutError(null);
        store(null);
        queryClient.clear();
      },
      // Clearing only the local state would leave the cookie and device binding alive for the next person.
      (error: unknown) => {
        setSignOutError(errorMessage(error));
      },
    );
  }, [queryClient, store]);

  /**
   * Ends the session when the server refused the refresh (401/403); keeps it on a network error, 5xx or 429
   * (the next call or timer tries again), so a Wi-Fi blip or an API restart does not sign the user out.
   * @param error Whatever `refreshSession` rejected with.
   */
  const endIfRejected = useCallback(
    (error: unknown) => {
      if (error instanceof ApiError && (error.status === 401 || error.status === 403)) signOut();
      else recoveringFor.current = null;
    },
    [signOut],
  );

  /**
   * Handles a 401 from a data call: tries the refresh cookie once (single-flight), then refetches.
   * Signs out only when the refresh itself is refused, or when a freshly recovered token is refused too.
   * @param token The access token the rejected request carried.
   */
  const recover = useCallback(
    (token: string) => {
      // A 401 for a token that is no longer current (signed out, or already replaced) needs nothing.
      if (token !== tokenRef.current || recoveringFor.current === token) return;
      if (
        recovered.current?.token === token &&
        Date.now() - recovered.current.at < LOOP_WINDOW_MS
      ) {
        // Sign-out now waits for the server, so mark the token to keep concurrent 401s to one logout.
        recoveringFor.current = token;
        signOut();
        return;
      }
      recoveringFor.current = token;
      refreshSession().then((next) => {
        recovered.current = { token: next.access_token, at: Date.now() };
        store(next);
        void queryClient.invalidateQueries();
      }, endIfRejected);
    },
    [queryClient, signOut, endIfRejected, store],
  );

  useEffect(() => {
    let live = true;
    refreshSession().then(
      (next) => {
        if (live) store(next);
      },
      () => {
        if (live) store(null);
      },
    );
    return () => {
      live = false;
    };
  }, [store]);

  useEffect(() => {
    if (!session) return;
    const timer = setTimeout(
      () => {
        refreshSession().then(store, endIfRejected);
      },
      Math.max(session.expires_in - REFRESH_EARLY_S, 1) * 1000,
    );
    return () => {
      clearTimeout(timer);
    };
  }, [session, endIfRejected, store]);

  const getToken = useCallback(() => tokenRef.current, []);
  // eslint-disable-next-line react-hooks/refs -- the client calls getToken per request, never during render
  const api = useMemo(() => createApiClient(getToken, recover), [getToken, recover]);
  const value = useMemo(
    () => ({ session, signIn: store, signOut, api }),
    [session, store, signOut, api],
  );
  return (
    <AuthContext.Provider value={value}>
      {children}
      <Snackbar
        open={signOutError !== null}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Alert
          severity="error"
          onClose={() => {
            setSignOutError(null);
          }}
        >
          Could not sign out. {signOutError}
        </Alert>
      </Snackbar>
    </AuthContext.Provider>
  );
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
