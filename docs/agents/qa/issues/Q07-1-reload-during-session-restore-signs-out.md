# Q07-1 (P3): a reload while the portal restores its session signs the web device out

<!-- Purpose: defect found while automating the P02 review line (docs/agents/reports/Q07.md). Serves:
docs/agents/qa-rubric.md. Readers: Orchestrator, WEB/SEC Reviewers, owners of P01 (portal auth) and B02 (refresh). -->

**Found by:** QA Lead (Q07), 2026-11-02, image built from `92a8c53` (`agritrace-q07-api:dev`), isolated compose stack
`agritrace-q07` (api 8044), portal `npx vite --port 5183` in live mode, fresh seed.
**Severity:** P3. No acceptance line fails and no data is lost, but an FPO admin who reloads (or navigates by URL)
while the page is still starting is signed out of that browser and must spend another OTP (10 per phone per day).
On a slow connection the window is the whole refresh round trip.
**Owner:** P01 (`apps/portal/src/auth/AuthProvider.tsx`, session restore on mount); B02 for the server option below.
Related: TODO.md "P01 risk: two portal tabs restoring a session at the same moment … `refresh_reused`" (same cause,
one tab is enough).

## Reproduction
1. Sign the admin `+919000000001` in through the login form.
2. Open `/ready-lots` by URL and reload at once, before the page has finished loading.
3. The page shows "Sign in to AgriTrace". `devices` row of that web sign-in: `revoked_at` set 2 s after `created_at`;
   API log: `POST /v1/auth/refresh` 200, then 401 for every later refresh.

Script and log: [Q07/logs/repro.robot](../Q07/logs/repro.robot), [Q07/logs/06-q07-1-repro.log](../Q07/logs/06-q07-1-repro.log)
(round 0 passes, round 1 is signed out). The second G4 fresh-seed attempt hit the same in the suite's reload loop
([Q07/logs/05-robot-g4-fresh-seed-attempt2-FAIL-Q07-1.log](../Q07/logs/05-robot-g4-fresh-seed-attempt2-FAIL-Q07-1.log): device revoked at 20:24:13Z, 9 tests
then on the sign-in page).

## Cause
Every page load calls `POST /v1/auth/refresh` with the httpOnly cookie. The server rotates the token on that call.
A reload cancels the request in the browser after the server has rotated, so the new `Set-Cookie` is never stored.
The next load sends the rotated-out token, and B02's reuse rule (`identity/service.py refresh`, outcome `reused`)
revokes the device.

## Fix options
- Server (B02): accept the previous token for a few seconds after a rotation (a grace window) and answer with the
  current session, instead of treating it as theft at once.
- Portal (P01): no full fix on the client alone; a single-tab lock only covers the two-tab case.

## Robot
`qa/robot/portal/portal.robot` avoids reload loops: it waits for the server state over the API, then loads the screen
once, and it never navigates before the previous page has shown API content.
