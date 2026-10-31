/**
 * Types for the Vite environment variables the portal reads.
 * Serves: plan §7.3 P00, P04 (public page URL). Read by: src/main.tsx, src/features/batches/PublishSection.tsx.
 */
interface ImportMetaEnv {
  /** `true` to serve the API from MSW mocks in `npm run dev:mock` (ignored in production builds). */
  readonly VITE_MSW?: string;
  /** Origin of the public batch pages (the API's `PUBLIC_BASE_URL`); unset: the portal's own origin (D-044). */
  readonly VITE_PUBLIC_BASE_URL?: string;
}
