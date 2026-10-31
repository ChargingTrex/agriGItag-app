/**
 * MSW service worker for `npm run dev:mock` (public/mockServiceWorker.js comes from `npx msw init public`).
 * Serves: plan §7.3 P00, P06 (dashboard handlers). Called by: src/main.tsx (dynamic import, dev builds only).
 */
import { setupWorker } from 'msw/browser';
import { dashboardHandlers } from './dashboardHandlers';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers, ...dashboardHandlers);
