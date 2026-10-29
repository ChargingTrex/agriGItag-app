# agritrace_page: public QR page renderer

Purpose: turns one batch's public record into the static page a buyer sees after scanning the
pack QR (`index.html`) and its machine-readable twin (`data.json`). Serves PRD FR15–FR19, FR30,
FR51, FR58, FR62, FR63, FR72 and plan §13 E1/E2. Decision D-007: the page is static, built by a
worker job and served from object storage. Nothing in this package touches a database or network.

## What it does

- `agritrace_page.schema.PublicBatchRecord` is the full allow-list of what a public page may show.
  Unknown fields, and lists of numbers or coordinates, are rejected by `extra="forbid"` and the
  field types. A record whose text carries a phone number (also with a leading 0 or +91, spaced,
  dashed, or glued to letters or Tamil text), an Aadhaar-like number, a survey/S.F./Sy. No.,
  patta or chitta reference, a polygon, precise coordinates, or a `temp_uploads` / `/tmp/` path
  is refused before rendering (CLAUDE.md §6). Model instances are re-validated on every render,
  so a field changed after construction is checked too. Farm pins are rounded to 3 decimal places
  (about 100 m) inside the schema. Photo URLs must point into an `evidence/` path, and
  `boundary_map_url` must be `https://`. The Lab-certified badge needs at least one reading with
  source `lab`. The procured quantity must be at least the batch quantity, in the same unit.
  Events are sorted by date, then instance. `lot_count`, per-lot `event_count`,
  `farming_event_count`, `processing_event_count` and each lot's `map_link` are computed, so they
  always match the data.
- `agritrace_page.render.render(record)` returns `RenderResult(html, data_json)`. Labels are
  Tamil first, then English. Dates read "14 Feb 2026", numbers use Indian grouping (1,20,000),
  and every quantity is printed with its unit. A lot whose `farmer_name` is null (the FPO opted
  out) is shown as "Farmer N".
- The CLI builds and checks pages locally.

## How the publishing job (B10) calls it

```python
from agritrace_page import render

result = render(record_dict)  # raises pydantic.ValidationError on bad or personal data
put("public-pages/batches/{code}/index.html", result.html)  # Cache-Control max-age=60 (plan §13 E3)
put("public-pages/batches/{code}/data.json", result.data_json)
```

The builder sets `farmer_name` to null when name consent is missing, sends raw pins (the schema
rounds them), and fills `footer.generation` and `footer.page_version`. For each photo it sends:

- `thumb_url` (WebP, about 60 KB) and `medium_url` (WebP, about 150 KB), from the variants B06
  records after a photo is verified;
- `width` and `height` of the thumbnail, from the same variants record;
- `jpeg_url`, the original evidence JPEG object (about 350 KB after phone compression), used only
  by browsers without WebP.

`total_quantity` is the quantity packed under this batch code. `procured_quantity` is what was
procured from the lots, and the lot shares are shares of it.
`data.json` is output only: it contains computed fields, so it is not accepted back as input.
The portal preview calls the same function through the API.

## CLI

```sh
uv sync
uv run python -m agritrace_page build fixtures/batch_sample.json out/
uv run python -m agritrace_page check out/   # exit 1 if any budget is breached
```

## Budgets (plan §13 E1)

| Part | Budget | Measured by |
|---|---|---|
| Inline CSS (`<style>`) | < 12 KB | `measure()` / `check` |
| Inline JS (`<script>`) | < 4 KB | `measure()` / `check` |
| `index.html` total (HTML + CSS + JS, no images) | < 100 KB | `measure()` / `check` |

The only JS is tap-to-enlarge (thumbnail to medium WebP). Without JS the photo link opens the
medium image. Per-lot timelines use native `<details>`, so they expand with JS off.

## Adding a label

1. Add the key to both `agritrace_page/i18n/ta.json` and `agritrace_page/i18n/en.json`.
   `tests/test_render.py` fails if the two files have different keys.
2. Use it in `templates/batch.html.j2` as `{{ t("your_key") }}`. Placeholders work as
   `{{ t("farmer_n", n=2) }}`.
3. A new stage needs a `Stage` literal in `schema.py` and a `stage.<key>` label in both files.

## Not built here (later work packages)

Print stylesheet, OG tags, unpublished/404 variant and static map thumbnail are W03. Privacy lint
over the built output, html-validate and Lighthouse CI are W02.

## Tests

```sh
uv run pytest -q
uv run ruff check .
uv run interrogate -vv --fail-under 100 agritrace_page
```
