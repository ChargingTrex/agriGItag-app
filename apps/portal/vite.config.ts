/**
 * Vite build, dev server and Vitest configuration for the portal.
 * Serves: plan §7.3 P00 (build < 60 s, initial bundle < 400 KB gz; Vitest + RTL).
 * Called by: `npm run dev|build|preview|test` and the CI `portal` job.
 *
 * DECISION D-022: the dev server proxies only `/v1`, so the portal calls the API with same-origin relative
 * URLs (`/v1/...`) exactly as it will behind the production load balancer.
 *   ADV: no CORS configuration in the API and no base URL to keep in sync per environment.
 *   COMPROMISE: production must serve the portal and `/v1` from one origin (or set a proxy rule there).
 */
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

const apiUrl = process.env['API_URL'] ?? 'http://localhost:8000';

export default defineConfig({
  plugins: [react()],
  build: {
    // public/ holds only MSW's mockServiceWorker.js, which production must not serve.
    copyPublicDir: false,
    // The budget that matters is the gzipped initial bundle (scripts/bundle-size.ts, < 400 KB); Vite's raw
    // 500 KB warning would fire on MUI + React alone.
    chunkSizeWarningLimit: 800,
  },
  server: { port: 5173, proxy: { '/v1': apiUrl } },
  preview: { port: 4173, proxy: { '/v1': apiUrl } },
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}', 'scripts/**/*.test.ts'],
  },
});
