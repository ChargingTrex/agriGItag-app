# AgriTrace FPO portal (`apps/portal`)

<!-- Purpose: how to run, test and extend the portal. Serves: plan §7.3 P00, plan §13 C4 (lean lists).
Readers: portal workers (P01–P08), WEB Reviewer, Verifiers. -->

Web portal for FPO admins (User Flows "FPO admin and QC flows"). React 18 + TypeScript strict + Vite,
React Router, TanStack Query, MUI, react-hook-form + zod. P00 is the shell only: sign-in, guard, sidebar
and placeholder screens; each screen is built by the work package shown on its placeholder.

## Commands

Node 24 and npm. Run from `apps/portal`.

| Command             | What it does                                                                                                                                          |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm ci`            | Install exactly the locked dependencies                                                                                                               |
| `npm run dev`       | Vite dev server on http://localhost:5173; `/v1` is proxied to `API_URL` (default http://localhost:8000, the compose `api` service)                    |
| `npm run dev:mock`  | Same, but `/v1` is answered by the MSW handlers in `src/mocks/handlers.ts` (sign in with any valid 10-digit mobile number, code `123456`, PIN `1234`) |
| `npm run gen:api`   | Regenerate `src/api/generated/` from `packages/openapi/openapi.json` and `docs/api/error-codes.md`                                                    |
| `npm run gen:check` | `gen:api`, then fail if the generated files differ from git (CI)                                                                                      |
| `npm run lint`      | ESLint (typescript-eslint strict, jsdoc rules) and Prettier check                                                                                     |
| `npm run typecheck` | `tsc -b` over app, scripts and configs                                                                                                                |
| `npm test`          | Vitest + React Testing Library, network mocked by MSW                                                                                                 |
| `npm run build`     | Typecheck and production build into `dist/`                                                                                                           |
| `npm run size`      | Gzipped size of the initial bundle from `dist/index.html`; fails above 400 KB                                                                         |
| `npm run e2e`       | Playwright against `PORTAL_URL` (default http://localhost:5173). Needs `npx playwright install chromium` first; that and the real tests are P07       |

The CI job is in `ci-job.yml` (to be moved into `.github/workflows/ci.yml`).

## Layout

| Path                                            | What                                                                                                                    |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `src/api/generated/`                            | **Generated, never edit.** `schema.d.ts` (openapi-typescript) and `error-messages.ts` (`scripts/gen-error-messages.ts`) |
| `src/api/client.ts`                             | `openapi-fetch` client typed by `schema.d.ts`; `unwrap()` returns data or throws `ApiError`                             |
| `src/api/errors.ts`                             | Error envelope -> `ApiError`; `errorMessage(error)` for the UI; `isRetryable` (network, 5xx, 429)                       |
| `src/api/cursor.ts`                             | `useCursorList`, `fieldsParam` (below)                                                                                  |
| `src/auth/`                                     | Session context, route guard, sign-in page (OTP then PIN), sign-in calls                                                |
| `src/layout/AppLayout.tsx`, `src/navigation.ts` | Shell and sidebar; add a screen by replacing its placeholder route                                                      |
| `src/mocks/`                                    | MSW handlers shared by tests and `dev:mock`                                                                             |

The generated client lives inside the app (`src/api/generated/`) rather than in `packages/client-ts/`: the
portal is its only TypeScript consumer, so a separate package would add a workspace and a build step for
nothing. Move it if a second TS consumer appears.

## Calling the API

```ts
const { api } = useAuth();
const health = useQuery({
  queryKey: ['healthz'],
  queryFn: ({ signal }) => unwrap(api.GET('/v1/healthz', { signal })),
});
// on error: <Alert>{errorMessage(health.error)}</Alert>
```

Never show `error.message` from the API; `errorMessage()` maps `error.code` to the text from
`docs/api/error-codes.md`. A 401 anywhere signs the user out and the guard sends them to `/login`.

## Lean lists (plan §13 C4)

Every list endpoint is cursor-paginated (`{items, next_cursor, has_more}`) and accepts `?fields=`
(docs/api/conventions.md). Screens must request only the columns they show and load more pages on demand:

```ts
const MEMBER_FIELDS = fieldsParam<Member>(['id', 'name', 'village', 'status']);
const members = useCursorList<Member>({
  queryKey: ['members', { status, fields: MEMBER_FIELDS }],
  fetchPage: ({ cursor, limit, signal }) =>
    unwrap(
      api.GET('/v1/farmers', {
        params: { query: { cursor, limit, fields: MEMBER_FIELDS } },
        signal,
      }),
    ),
});
// members.items, members.hasNextPage, members.fetchNextPage(), members.isFetchingNextPage
```

- No offset pagination, no "fetch everything then filter" on the client.
- Put filters and the `fields` value in `queryKey` so a filter change starts a new list.
- Default page size is 50 (`DEFAULT_PAGE_SIZE`); pass `limit` to change it.

## Not in P00

- `/v1/auth/*` does not exist yet: `src/auth/authApi.ts` and the auth MSW handlers use an assumed contract,
  marked `TODO(B02)`. Token refresh and server logout are also `TODO(B02)`.
- English only; Tamil strings arrive with the screens that need them.
- Icons (`@mui/icons-material`) are not installed; the sidebar is text-only.
