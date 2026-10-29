/**
 * Route table: public `/login`, everything else behind the auth guard inside the shell layout.
 * Serves: plan §7.3 P00 (placeholder routes for the planned screens, auth guard), FR13, FR14.
 * Called by: src/main.tsx (inside BrowserRouter), src/test/render.tsx (inside MemoryRouter).
 */
import { Navigate, Route, Routes } from 'react-router';
import { LoginPage } from './auth/LoginPage';
import { RequireAuth } from './auth/RequireAuth';
import { AppLayout } from './layout/AppLayout';
import { NAV_ITEMS } from './navigation';
import { DashboardPage } from './pages/DashboardPage';
import { PlaceholderPage } from './pages/PlaceholderPage';

/**
 * All routes of the portal.
 * @returns The route tree; unknown paths redirect to the dashboard.
 */
export function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAuth />}>
        <Route element={<AppLayout />}>
          <Route index element={<DashboardPage />} />
          {NAV_ITEMS.filter((item) => item.path !== '/').map((item) => (
            <Route
              key={item.path}
              path={item.path}
              element={<PlaceholderPage title={item.label} wp={item.wp} />}
            />
          ))}
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
