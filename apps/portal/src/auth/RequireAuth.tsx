/**
 * Route guard: renders the protected routes only when signed in, else redirects to /login and remembers
 * where the user was going. Serves: plan §7.3 P00 (auth guard), FR14 role-based access (role checks per
 * screen arrive with B02 roles). Called by: src/AppRoutes.tsx.
 */
import { Navigate, Outlet, useLocation } from 'react-router';
import { useAuth } from './AuthProvider';

/**
 * Guards nested routes.
 * @returns The nested routes when signed in, else a redirect to `/login` with `state.from` set.
 */
export function RequireAuth() {
  const { session } = useAuth();
  const location = useLocation();
  if (!session) {
    return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />;
  }
  return <Outlet />;
}
