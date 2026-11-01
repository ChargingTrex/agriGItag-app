# Q07-2 (P3): after "Rebuild" the batch page's preview shows the previous page for up to 60 s

<!-- Purpose: defect found while automating the P06 opt-out line (docs/agents/reports/Q07.md, round 2). Serves:
docs/agents/qa-rubric.md. Readers: Orchestrator, WEB Reviewer, owners of P04 (PublishSection) and B10 (public page). -->

**Found by:** QA Lead (Q07 round 2), 2026-11-02, `main` `24d1c02` (api image = shared `agritrace-api:dev`, identical
API sources), isolated stack `agritrace-q07` (api 8054), portal live mode on :5193.
**Severity:** P3. Nothing is lost and the published page itself is right at once. But an FPO admin who changes
something (here the farmer-name opt-out) and presses Rebuild sees the old page in the preview. The build says
`built`, so it looks as if the change did not work. It shows correctly only after about a minute.
**Owner:** P04 (`apps/portal/src/features/batches/PublishSection.tsx`).

## Reproduction
1. Published batch, page shown in the batch page's preview.
2. Change the page content (e.g. `fpos.public_show_farmer_names` true → false; no API route sets it, see P06) and press
   Rebuild; wait until the new build is `built` (`GET /v1/batches/{id}/builds`).
3. Reload the batch page. The preview still shows the old page ("Page version"/names of the previous build). It
   changes only after 54–60 s. `curl /v1/public/batches/<code>` already returns the new page at that moment.

Robot evidence: in the round-2 portal run, "Name Opt Out Is Reflected In The Preview" waited **54 s** after the first
rebuild and **60 s** after the second before the preview changed (keyword timings in
[Q07/r2/robot/output.xml](../Q07/r2/robot/output.xml)). Before the wait was added the test failed with the old text
(run log [Q07/r2/logs/02-portal-run2-preview-stale.log](../Q07/r2/logs/02-portal-run2-preview-stale.log)).

## Cause
`LivePage` remounts the iframe with `key={build.build_no}`, but its `src` stays `/v1/public/batches/<code>` (dev) or
the public URL (production). The API answers that URL with `Cache-Control: public, max-age=60`, so the browser serves
the cached copy of the previous build to the new iframe.

## Fix
Make the preview URL build-specific, e.g. `src={`${preview}?build=${build.build_no}`}`. The cache key then changes
with every build. The public URL and its caching stay as they are.

## Robot
`qa/robot/portal/portal.robot` "Name Opt Out Is Reflected In The Preview" reloads the batch page for up to 100 s
until the new build shows (keyword `Preview Should Show`). Once this is fixed, the wait drops to one load.
