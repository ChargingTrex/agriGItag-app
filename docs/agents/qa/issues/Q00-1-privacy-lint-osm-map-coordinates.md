# Q00-1 (P2, privacy-lint gap): OpenStreetMap map links with precise coordinates pass the linter

**Found by:** Q00 Verifier, 2026-10-29, commit 2225c57 (worktree agent-a1e874f99a5c27fbd). It was found by a verifier-only probe (V07). It is not part of the reviewer's 90-probe set.
**Severity:** P2. This is the same family as the accepted Q00-r2 P2-3 (degree, DMS and space-separated coordinates), which is already in TODO with W02 as owner. It is more likely than those cases, because B10 writes a map link to every public page ("map link 3 dp", plan §7.1) and the portal uses OSM/MapLibre.
**Owner:** W02, together with the P2-3 TODO (TODO.md line 49).

## Reproduction
```
mkdir -p /tmp/v07/a /tmp/v07/c
echo '<a href="https://www.openstreetmap.org/?mlat=9.559806&mlon=78.133521">map</a>' > /tmp/v07/a/index.html
echo '<a href="https://www.openstreetmap.org/#map=17/9.559806/78.133521">map</a>'     > /tmp/v07/c/index.html
python3 infra/scripts/privacy-lint.py /tmp/v07/a   # privacy-lint: 0 hit(s) ... exit=0   (6 dp should fail)
python3 infra/scripts/privacy-lint.py /tmp/v07/c   # privacy-lint: 0 hit(s) ... exit=0   (6 dp should fail)
```
These forms are caught:
- `?lat=9.559806&lon=78.133521`
- `geo:9.5598061,78.1335214`
- `data-lat="9.5598061"`

Evidence:
- `docs/agents/qa/Q00/logs/04-probe-V07-variants.txt`
- `docs/agents/qa/Q00/logs/03-probes.txt`, row V07

## Cause
The key/parameter alternative in `coordinate_precision` is `\b(?:lat|lng|lon)\w*[\"']?\s*[:=]\s*[\"']?{PRECISE}`. OSM's `mlat`/`mlon` have a word character before `lat`, so the `\b` does not match. The OSM fragment `#map=<zoom>/<lat>/<lon>` uses `/` as the separator, and no rule covers that.

## Fix options
- Allow an `m` prefix in the key rule: `\b(?:m?lat|m?lng|m?lon)\w*...`. This is one token, and it needs a `LEAKS` test row.
- Add `#map=\d+/{PRECISE}/{NUM}` (and the reverse order) when W02 takes on P2-3. B10 should build its map link from already-rounded values, so the linter stays a backstop.
