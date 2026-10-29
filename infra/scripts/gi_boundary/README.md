# GI 883 region outlines (D-019)

`build_virudhunagar.py` builds two versions of the Virudhunagar Samba Vathal (GI 883) production-area
outline from an open sub-district (taluk) boundary file, and records where they came from:

| File | Version | What it is |
|---|---|---|
| `gi_region_v0.geojson` | 0 | Virudhunagar district outline (dissolve of its sub-districts) |
| `gi_region_v1.geojson` | 1 | Union of the taluks in `taluks.json` (Sattur, Aruppukottai, Tiruchuli; `confirmed: false`) |

Each is a FeatureCollection with one MultiPolygon feature whose properties are `version_no`, `source_ref`
(download URL, file name and SHA-256 prefix, build method), `licence`, `attribution` (default "Boundary
data © geoBoundaries contributors, ODbL-1.0; derived region shared under ODbL-1.0", `--attribution` to
change it), `share_alike` (true for an ODbL source), `confidence: district_derived`,
`taluks`, `taluks_confirmed`, `built_at`, `district`, `tolerance_buffer_m` (150). The script prints one
JSON line per version: these are the fields of `POST /v1/gi-tags/{id}/region-versions` (put the file's
`geometry` in `geometry`). Nothing is downloaded by the script or by CI.

## Source file (download by hand)

**Recommended: geoBoundaries gbOpen, India ADM3 (sub-districts) and ADM2 (districts), release commit `9469f09`.**

- ADM3: <https://github.com/wmgeolab/geoBoundaries/raw/9469f09/releaseData/gbOpen/IND/ADM3/geoBoundaries-IND-ADM3.geojson> (≈ 106 MB)
- ADM2: <https://github.com/wmgeolab/geoBoundaries/raw/9469f09/releaseData/gbOpen/IND/ADM2/geoBoundaries-IND-ADM2.geojson> (≈ 48 MB)
- Metadata: <https://www.geoboundaries.org/api/current/gbOpen/IND/ADM3/>
- Source named by geoBoundaries: Pathways Data Pvt. Ltd., lgdirectory.gov.in (LGD sub-districts).
- Licence: **Open Data Commons Open Database License 1.0 (ODbL-1.0)**. Use is commercial-safe with
  attribution; a *published derived database* must be offered under ODbL too. Our derived outline is
  shown only as a simplified boundary map, with the `attribution` line from the output files. The API
  stores `attribution` and `share_alike` inside `source_ref` (no column for them yet).

Why not the file D-019 names: the Datameet maps repository (<https://github.com/datameet/maps>, CC BY 4.0)
has Census 2011 **district** outlines (`Districts/Census_2011/2011_Dist.shp`) but no sub-district layer,
and the Datameet village boundaries (ODbL) do not cover Tamil Nadu. Census-2011 sub-district files found
elsewhere are non-commercial (CC BY-NC-SA, rejected under D-018) or restricted. GADM is non-commercial
(cross-check only, D-019). geoBoundaries ADM3 is open and derived from the current LGD sub-district list,
so it is closer to today's taluks than 2011 boundaries. The script works with any sub-district GeoJSON:

- geoBoundaries (no district name on ADM3 features): pass `--districts` ADM2; defaults
  `--name-field shapeName --district-field shapeName` fit.
- A Census-2011-style file whose features carry the district name: omit `--districts` and pass e.g.
  `--name-field SUB_DIST --district-field DISTRICT`.
- Shapefiles: convert first, e.g. `ogr2ogr -f GeoJSON -t_srs EPSG:4326 out.geojson in.shp`.

## Run

From `apps/api` (its environment has shapely):

```sh
uv run python ../../infra/scripts/gi_boundary/build_virudhunagar.py \
  --subdistricts ~/Downloads/geoBoundaries-IND-ADM3.geojson \
  --districts ~/Downloads/geoBoundaries-IND-ADM2.geojson \
  --source-url https://github.com/wmgeolab/geoBoundaries/raw/9469f09/releaseData/gbOpen/IND/ADM3/geoBoundaries-IND-ADM3.geojson \
  --licence ODbL-1.0 --out /tmp/gi883

uv run python ../../infra/scripts/gi_boundary/build_virudhunagar.py \
  --check-point 9.559806,78.133521 --file /tmp/gi883/gi_region_v1.geojson
```

Exit codes: 0 built / point inside; 1 district or a taluk not found (stderr lists the sub-district names
found, so a spelling can be added to `aliases` in `taluks.json`); 3 point outside.

Measured on 2026-10-29 with the files above: v0 40.7 KB (2,128 vertices; sub-districts Aruppukkottai,
Kariapatti, Rajapalayam, Sattur, Sivakasi, Srivilliputhur, Tiruchuli, Vembakottai, Virudhunagar, Watrap),
v1 33.1 KB (1,565 vertices); `(9.559806, 78.133521)` is inside both; Madurai `(9.9252, 78.1198)` is outside.

## Before v1 is used for checks

`taluks.json` is a working list (`confirmed: false`). Confirm the taluks against GI Journal No. 200 /
Application 883 (TODO.md §2), set `confirmed: true`, rebuild, and upload. Until then the seed uses v0 or
the non-official test fixture `apps/api/agritrace/seed/fixtures/gi_region_fixture.geojson`.
