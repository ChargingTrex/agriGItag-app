/**
 * TanStack Query client factory with the API's retry policy.
 * Serves: docs/api/conventions.md (retry only on network errors, 5xx and 429), plan §7.3 P00.
 * Called by: src/main.tsx (one per page load), src/test/render.tsx (one per test).
 */
import { QueryClient } from '@tanstack/react-query';
import { isRetryable } from './api/errors';

/**
 * Creates the app's query client.
 * @returns A client that retries a failed query at most 3 times, and only when the failure is retryable.
 */
export function createQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: (failureCount, error) => failureCount < 3 && isRetryable(error),
        staleTime: 30_000,
      },
    },
  });
}
