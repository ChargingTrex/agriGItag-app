/**
 * Dashboard placeholder. Until P06 it shows only the API health, which proves the generated client, TanStack
 * Query and the error mapping end to end. Serves: FR13 dashboard shell, plan §7.3 P00. Called by:
 * src/AppRoutes.tsx (index route).
 */
import Alert from '@mui/material/Alert';
import { useQuery } from '@tanstack/react-query';
import { unwrap } from '../api/client';
import { errorMessage } from '../api/errors';
import { useAuth } from '../auth/AuthProvider';
import { PlaceholderPage } from './PlaceholderPage';

/**
 * The dashboard page.
 * @returns The placeholder with an API status line.
 */
export function DashboardPage() {
  const { api } = useAuth();
  const health = useQuery({
    queryKey: ['healthz'],
    queryFn: ({ signal }) => unwrap(api.GET('/v1/healthz', { signal })),
  });
  return (
    <PlaceholderPage title="Dashboard" wp="P06">
      {health.isSuccess && (
        <Alert severity="success" sx={{ mt: 2 }}>
          API reachable (database {health.data.db}, cache {health.data.redis}, storage{' '}
          {health.data.s3}).
        </Alert>
      )}
      {health.isError && (
        <Alert severity="warning" sx={{ mt: 2 }}>
          {errorMessage(health.error)}
        </Alert>
      )}
    </PlaceholderPage>
  );
}
