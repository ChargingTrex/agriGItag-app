/**
 * The portal's API client: `openapi-fetch` over the types generated from packages/openapi/openapi.json.
 * Serves: plan §7.3 P00 (generated client), docs/api/conventions.md (error envelope, `/v1` base path).
 * Called by: src/auth/AuthProvider.tsx (creates one client per session and exposes it as `useAuth().api`),
 * screens via `unwrap(api.GET('/v1/...'))`, src/auth/authApi.ts (`unwrap`).
 *
 * DECISION D-003: the client is `openapi-fetch` typed by `openapi-typescript` output that is never edited.
 *   ADV: paths, params and bodies are checked against the contract at compile time; the runtime is ~6 KB and
 *   regeneration is one command (`npm run gen:api`) with a CI diff check.
 *   COMPROMISE: an endpoint missing from the spec cannot be called until the backend WP adds it (P01 leaves
 *   TODOs for the phone reveal, farmer reject and per-farmer plot list instead of hand-typed calls).
 */
import createClient, { type Client } from 'openapi-fetch';
import { toApiError } from './errors';
import type { paths } from './generated/schema';

/** A typed client for every path in openapi.json. */
export type ApiClient = Client<paths>;

/**
 * Creates a client that sends the bearer token and reports 401 responses.
 * @param getToken Returns the current access token, or null when signed out (no Authorization header is
 *   sent). Read per request, so a query refetched right after a refresh already carries the new token.
 * @param onUnauthorized Called on every 401 response with the token that request carried, so the session can
 *   be recovered or cleared.
 * @returns The typed client. Requests go to the page's own origin (paths already start with `/v1`, D-020).
 */
export function createApiClient(
  getToken: () => string | null,
  onUnauthorized: (token: string) => void,
): ApiClient {
  const client = createClient<paths>({ baseUrl: window.location.origin });
  client.use({
    /**
     * Adds the bearer token.
     * @param params Middleware parameters.
     * @param params.request The outgoing request.
     * @returns The same request with an Authorization header when signed in.
     */
    onRequest({ request }) {
      const token = getToken();
      if (token) request.headers.set('Authorization', `Bearer ${token}`);
      return request;
    },
    /**
     * Reports 401 responses. AuthProvider's handler tries the refresh cookie once and signs out only when
     * that is refused (revoked or signed-out device).
     * @param params Middleware parameters.
     * @param params.request The request that was answered (its Authorization header names the token).
     * @param params.response The incoming response.
     * @returns The response unchanged.
     */
    onResponse({ request, response }) {
      if (response.status === 401) {
        onUnauthorized(request.headers.get('Authorization')?.replace(/^Bearer /, '') ?? '');
      }
      return response;
    },
  });
  return client;
}

/**
 * Awaits an openapi-fetch call and returns its data or throws the parsed error envelope.
 * @param call The pending `api.GET(...)`/`api.POST(...)` result.
 * @returns The typed response body.
 * @throws {ApiError} When the response status is not 2xx; `code` comes from the error envelope.
 * @throws {TypeError} When the network request itself fails (passed through from fetch).
 */
export async function unwrap<T>(
  call: Promise<{ data?: T; error?: unknown; response: Response }>,
): Promise<T> {
  const { data, error, response } = await call;
  if (!response.ok) throw toApiError(response.status, error);
  return data as T;
}
