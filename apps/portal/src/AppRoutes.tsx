/**
 * Route table: public `/login`, everything else behind the auth guard inside the shell layout.
 * Serves: plan §7.3 P00 (placeholder routes for the planned screens, auth guard) and P01 (Members, farmer and
 * plot detail, Processors), P02 (Flags list and detail, lot review), FR13, FR14, FR70.
 * Called by: src/main.tsx (inside BrowserRouter), src/test/render.tsx (inside MemoryRouter).
 */
import { Navigate, Route, Routes } from 'react-router';
import { LoginPage } from './auth/LoginPage';
import { RequireAuth } from './auth/RequireAuth';
import { FlagPage } from './features/flags/FlagPage';
import { FlagsPage } from './features/flags/FlagsPage';
import { LotPage } from './features/flags/LotPage';
import { FarmerPage } from './features/members/FarmerPage';
import { MembersPage } from './features/members/MembersPage';
import { PlotPage } from './features/members/PlotPage';
import { ProcessorsPage } from './features/members/ProcessorsPage';
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
          <Route path="/members" element={<MembersPage />} />
          <Route path="/members/:farmerId" element={<FarmerPage />} />
          <Route path="/members/plots/:plotId" element={<PlotPage />} />
          <Route path="/processors" element={<ProcessorsPage />} />
          <Route path="/flags" element={<FlagsPage />} />
          <Route path="/flags/:flagId" element={<FlagPage />} />
          <Route path="/lots/:lotId" element={<LotPage />} />
          {NAV_ITEMS.filter((item) => !['P01', 'P02'].includes(item.wp) && item.path !== '/').map(
            (item) => (
              <Route
                key={item.path}
                path={item.path}
                element={<PlaceholderPage title={item.label} wp={item.wp} />}
              />
            ),
          )}
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
