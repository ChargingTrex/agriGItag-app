/**
 * MSW service worker for `npm run dev:mock` (public/mockServiceWorker.js comes from `npx msw init public`).
 * Serves: plan §7.3 P00, P06 (dashboard handlers), P07 (the e2e chain reads the mock state, D-052).
 * Called by: src/main.tsx (dynamic import, dev builds only).
 */
import { setupWorker } from 'msw/browser';
import { dashboardHandlers } from './dashboardHandlers';
import { handlers, mockState } from './handlers';

export const worker = setupWorker(...handlers, ...dashboardHandlers);

// DECISION D-052: the mock state is reachable from the page as `agritraceMock`, so the e2e chain can play the
//   QC officer's phone (write the batch grade the portal has no screen for).
//   ADV: one portal-only chain covers grading approval → publish → labels without a phone emulator.
//   COMPROMISE: a test hook in the mock bundle; it exists only under `npm run dev:mock` (this module is never
//   imported by a production build, see src/main.tsx).
Object.assign(globalThis, { agritraceMock: mockState });
