/**
 * MSW service worker for `npm run dev:mock` (public/mockServiceWorker.js comes from `npx msw init public`).
 * Serves: plan §7.3 P00. Called by: src/main.tsx (dynamic import, dev builds only).
 */
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
