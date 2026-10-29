/**
 * Browser entry point: optionally starts the MSW mock API (dev only), then renders the app.
 * Serves: plan §7.3 P00. Called by: index.html.
 */
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router';
import { AppProviders } from './AppProviders';
import { AppRoutes } from './AppRoutes';
import { createQueryClient } from './queryClient';

/**
 * Starts the MSW service worker when running `npm run dev:mock`. `import.meta.env.DEV` is the literal `false`
 * in production builds, so the mocks are never bundled or reachable there.
 * @returns Resolves once mocking is active (or immediately when it is off).
 */
async function startMocks(): Promise<void> {
  if (!import.meta.env.DEV || import.meta.env.VITE_MSW !== 'true') return;
  const { worker } = await import('./mocks/browser');
  await worker.start({ onUnhandledFrame: 'bypass' });
}

const container = document.getElementById('root');
if (!container) throw new Error('index.html has no #root element');

void startMocks().then(() => {
  createRoot(container).render(
    <StrictMode>
      <BrowserRouter>
        <AppProviders queryClient={createQueryClient()}>
          <AppRoutes />
        </AppProviders>
      </BrowserRouter>
    </StrictMode>,
  );
});
