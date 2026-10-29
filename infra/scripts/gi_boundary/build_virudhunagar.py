#!/usr/bin/env python3
"""Build GI 883 region outlines v0 (district) and v1 (GI taluks) from open boundaries, or check a point.

v0 is the Virudhunagar district dissolve, v1 the union of the taluks in taluks.json; both carry provenance.

Serves: D-019 (GI region from open administrative boundaries with recorded provenance), FR27 (GI
boundary as GeoJSON per tag), FR31 (versioned, loaded by the compliance team), backend-design.md §5
(seed region v0/v1, buffer 150 m).
Callers: a super-admin / the B12 seed by hand (`make`-less, see README.md next to this file); the output
is uploaded with POST /v1/gi-tags/{id}/region-versions. apps/api/tests/unit/test_registry_gi_boundary.py.
Downloads nothing: the source file is fetched by a person (README.md) and passed by path.

Usage (from apps/api, which has shapely):
  uv run python ../../infra/scripts/gi_boundary/build_virudhunagar.py \
      --subdistricts ADM3.geojson --districts ADM2.geojson --source-url URL --licence ODbL-1.0 --out DIR
  uv run python ../../infra/scripts/gi_boundary/build_virudhunagar.py --check-point 9.559806,78.133521 \
      --file DIR/gi_region_v1.geojson
Exit codes: 0 ok / point inside; 1 bad input (district or a taluk not found); 3 point outside.
"""

import argparse
import hashlib
import json
import pathlib
import re
import sys
from datetime import UTC, datetime
from typing import Any

import shapely
from shapely.geometry import MultiPolygon, Point, mapping, shape
from shapely.geometry.base import BaseGeometry

HERE = pathlib.Path(__file__).resolve().parent
SCRIPT_REF = "infra/scripts/gi_boundary/build_virudhunagar.py"


def norm(name: object) -> str:
    """Normalise a place name for matching ("Tiruchuli " == "TIRUCHULI" == "Tiru-chuli").

    Args:
        name: a name from a property or taluks.json (None allowed).

    Returns:
        Lower-case letters and digits only.
    """
    return re.sub(r"[^0-9a-z]", "", str(name or "").casefold())


def load_features(path: pathlib.Path) -> list[dict[str, Any]]:
    """Read the features of a GeoJSON FeatureCollection.

    Args:
        path: GeoJSON file.

    Returns:
        Its features.

    Raises:
        OSError: the file cannot be read.
        json.JSONDecodeError: not JSON.
        KeyError: no `features` member.
    """
    features: list[dict[str, Any]] = json.loads(path.read_text())["features"]
    return features


def as_multipolygon(geom: BaseGeometry) -> MultiPolygon:
    """Coerce a dissolved outline to a valid MultiPolygon rounded to 6 decimal places (about 0.1 m).

    Args:
        geom: Polygon or MultiPolygon (or a collection holding polygons).

    Returns:
        A valid MultiPolygon.
    """
    geom = shapely.make_valid(shapely.set_precision(geom, 1e-6))
    polygons = [g for g in getattr(geom, "geoms", [geom]) if g.geom_type in ("Polygon", "MultiPolygon")]
    parts = [p for g in polygons for p in getattr(g, "geoms", [g])]
    return MultiPolygon(parts)


def write_version(path: pathlib.Path, geom: MultiPolygon, props: dict[str, Any]) -> int:
    """Write one region version as a FeatureCollection with a single feature.

    Args:
        path: output file.
        geom: the outline.
        props: provenance properties.

    Returns:
        Bytes written.

    Side effects:
        Creates or overwrites `path`.
    """
    doc = {
        "type": "FeatureCollection",
        "features": [{"type": "Feature", "properties": props, "geometry": mapping(geom)}],
    }
    text = json.dumps(doc, separators=(",", ":"))
    path.write_text(text)
    return len(text.encode())


def build(args: argparse.Namespace) -> int:
    """Build v0 and v1 and print an upload-ready summary per version.

    Args:
        args: parsed command line (see `main`).

    Returns:
        0 on success, 1 when the district or a configured taluk is not found (message on stderr).

    Side effects:
        Writes `gi_region_v0.geojson` and `gi_region_v1.geojson` into `args.out`; prints JSON lines.
    """
    subdistricts = load_features(args.subdistricts)
    district_source = load_features(args.districts) if args.districts else subdistricts
    district_parts = [
        shape(f["geometry"])
        for f in district_source
        if norm(f["properties"].get(args.district_field)) == norm(args.district)
    ]
    if not district_parts:
        print(f"district {args.district!r} not found in field {args.district_field!r}", file=sys.stderr)
        return 1
    district = shapely.union_all(district_parts)
    # A sub-district belongs to the district when an interior point of it lies in the district outline,
    # which tolerates small edge mismatches between two boundary layers.
    inside = [f for f in subdistricts if district.covers(shape(f["geometry"]).representative_point())]
    by_name = {norm(f["properties"].get(args.name_field)): f for f in inside}

    config = json.loads(args.taluks.read_text())
    chosen, missing = [], []
    for taluk in config["taluks"]:
        hit = next(
            (by_name[n] for n in map(norm, [taluk["name"], *taluk.get("aliases", [])]) if n in by_name), None
        )
        if hit:
            chosen.append(hit)
        else:
            missing.append(taluk["name"])
    if missing:
        names = sorted(str(f["properties"].get(args.name_field)) for f in inside)
        print(
            f"taluks not found in {args.district}: {missing}; sub-districts there: {names}", file=sys.stderr
        )
        return 1

    digest = hashlib.sha256(args.subdistricts.read_bytes()).hexdigest()[:16]
    common = {
        "licence": args.licence,
        "confidence": "district_derived",
        "built_at": datetime.now(UTC).isoformat(timespec="seconds"),
        "district": args.district,
        "tolerance_buffer_m": args.buffer_m,
    }
    source = f"{args.source_url} ({args.subdistricts.name} sha256:{digest}) via {SCRIPT_REF}"
    versions = [
        (
            0,
            as_multipolygon(district),
            sorted(str(f["properties"].get(args.name_field)) for f in inside),
            True,
            "district dissolve",
        ),
        (
            1,
            as_multipolygon(shapely.union_all([shape(f["geometry"]) for f in chosen])),
            [t["name"] for t in config["taluks"]],
            bool(config.get("confirmed")),
            "union of GI taluks",
        ),
    ]
    args.out.mkdir(parents=True, exist_ok=True)
    for version_no, geom, taluks, confirmed, method in versions:
        props = common | {
            "version_no": version_no,
            "source_ref": f"{source}; {method}",
            "taluks": taluks,
            "taluks_confirmed": confirmed,
        }
        path = args.out / f"gi_region_v{version_no}.geojson"
        size = write_version(path, geom, props)
        vertices = int(shapely.get_num_coordinates(geom))
        print(
            json.dumps({"file": str(path), "bytes": size, "vertices": vertices, **props}, ensure_ascii=False)
        )
    return 0


def check_point(spec: str, path: pathlib.Path) -> int:
    """Report whether a point lies inside a built outline.

    Args:
        spec: "lat,lon" in decimal degrees, e.g. "9.559806,78.133521".
        path: a file written by `build`.

    Returns:
        0 when the outline covers the point, 3 when it does not.

    Side effects:
        Prints `inside` or `outside` with the file's version and the distance in degrees to the outline.
    """
    lat, lon = (float(v) for v in spec.split(","))
    feature = load_features(path)[0]
    geom, point = shape(feature["geometry"]), Point(lon, lat)
    covered = geom.covers(point)
    where = "inside" if covered else f"outside ({geom.distance(point):.5f} deg from the outline)"
    print(f"({lat}, {lon}) is {where} of {path.name} v{feature['properties'].get('version_no')}")
    return 0 if covered else 3


def main(argv: list[str] | None = None) -> int:
    """Parse the command line and run `build` or `check_point`.

    Args:
        argv: arguments without the program name; None reads `sys.argv`.

    Returns:
        The process exit code.
    """
    parser = argparse.ArgumentParser(description=(__doc__ or "").splitlines()[0])
    parser.add_argument(
        "--subdistricts", type=pathlib.Path, help="sub-district (taluk) GeoJSON FeatureCollection"
    )
    parser.add_argument(
        "--districts", type=pathlib.Path, help="district GeoJSON, when sub-districts carry no district name"
    )
    parser.add_argument(
        "--name-field", default="shapeName", help="sub-district name property (geoBoundaries: shapeName)"
    )
    parser.add_argument(
        "--district-field", default="shapeName", help="district name property in the district source"
    )
    parser.add_argument("--district", default="Virudhunagar", help="district to select")
    parser.add_argument("--taluks", type=pathlib.Path, default=HERE / "taluks.json", help="GI taluk list")
    parser.add_argument("--source-url", help="where the sub-district file was downloaded from (recorded)")
    parser.add_argument("--licence", help="licence of the source data, e.g. ODbL-1.0 (recorded)")
    parser.add_argument("--buffer-m", type=float, default=150.0, help="tolerance buffer in metres (FR32)")
    parser.add_argument("--out", type=pathlib.Path, default=pathlib.Path("."), help="output directory")
    parser.add_argument(
        "--check-point", metavar="LAT,LON", help="report inside/outside for --file instead of building"
    )
    parser.add_argument("--file", type=pathlib.Path, help="built outline to check with --check-point")
    args = parser.parse_args(argv)
    if args.check_point:
        if not args.file:
            parser.error("--check-point needs --file")
        return check_point(args.check_point, args.file)
    if not (args.subdistricts and args.source_url and args.licence):
        parser.error(
            "building needs --subdistricts, --source-url and --licence (provenance is mandatory, D-019)"
        )
    return build(args)


if __name__ == "__main__":
    sys.exit(main())
