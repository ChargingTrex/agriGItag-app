/**
 * Types for the Vite environment variables the portal reads.
 * Serves: plan §7.3 P00. Read by: src/main.tsx.
 */
interface ImportMetaEnv {
  /** `true` to serve the API from MSW mocks in `npm run dev:mock` (ignored in production builds). */
  readonly VITE_MSW?: string;
}
