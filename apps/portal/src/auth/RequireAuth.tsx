/**
 * Route guard: renders the protected routes only when signed in, else redirects to /login and remembers
 * where the user was going. While the refresh cookie is being tried it shows a progress bar.
 * Serves: plan §7.3 P00 (auth guard), P01 (cookie session restore, D-024), FR14 role-based access (the API
 * enforces roles per call). Called by: src/AppRoutes.tsx.
 */
import LinearProgress from '@mui/material/LinearProgress';
import { Navigate, Outlet, useLocation } from 'react-router';
import { useAuth } from './AuthProvider';

/**
 * Guards nested routes.
 * @returns The nested routes when signed in, a progress bar while the session is restored, else a redirect
 *   to `/login` with `state.from` set.
 */
export function RequireAuth() {
  const { session } = useAuth();
  const location = useLocation();
  if (session === undefined) return <LinearProgress aria-label="Restoring session" />;
  if (!session) {
    return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />;
  }
  return <Outlet />;
}
