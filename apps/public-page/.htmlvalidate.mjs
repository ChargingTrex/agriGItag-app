/**
 * html-validate configuration for the built public batch page (W02 acceptance "0 HTML errors").
 *
 * Purpose: fail CI on any HTML conformance or accessibility error in out/site/index.html.
 * Requirements: plan §7.4 W02 (0 HTML errors), FR-16 (public page content), BM-03 (page quality gate).
 * Callers: `npm run validate` in the public-page CI job, qa/robot/public/page.robot, developers.
 *
 * DECISION D-007: the page is one static file with inline <style> and <script> (no external assets),
 *   so inline CSS/JS is intended and `no-inline-style` is off; native <details> timelines are allowed.
 *   ADV: one request on a slow 3G link; the page works with JS off.
 *   COMPROMISE: no CSP without 'unsafe-inline' or hashes; W03/B10 can add hashes if a CSP is set.
 * DECISION D-018: html-validate's own `standard` (spec conformance) and `a11y` presets instead of
 *   hand-picked rules; `recommended` adds style-only rules (lower-case doctype is valid HTML).
 *   ADV: rules maintained upstream; a style preference never fails the build.
 *   COMPROMISE: new upstream rules can fail CI after a version bump; the version is pinned exactly.
 */
export default {
  extends: ["html-validate:standard", "html-validate:a11y"],
  rules: {
    "no-inline-style": "off",
  },
};
