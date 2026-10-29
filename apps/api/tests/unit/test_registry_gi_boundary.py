"""Unit tests of infra/scripts/gi_boundary/build_virudhunagar.py against tiny synthetic boundary files.

Serves: D-019 (v0 district dissolve, v1 taluk union, provenance recorded), FR27, B03 deliverable 3.
Callers: pytest (`make test-unit`). The script is loaded from its path (it is not part of the package).
"""

import importlib.util
import json
from pathlib import Path
from types import ModuleType
from typing import Any

import pytest
from shapely.geometry import Point, shape

SCRIPT = Path(__file__).parents[4] / "infra" / "scripts" / "gi_boundary" / "build_virudhunagar.py"
URL = "https://example.org/subdistricts.geojson"


def _script() -> ModuleType:
    """Import the build script from its file.

    Returns:
        The loaded module.
    """
    spec = importlib.util.spec_from_file_location("build_virudhunagar", SCRIPT)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _cell(name: str, district: str, lon: float, lat: float) -> dict[str, Any]:
    """A 0.1° square sub-district feature with census-style properties.

    Args:
        name: sub-district name.
        district: district name.
        lon: west edge.
        lat: south edge.

    Returns:
        GeoJSON Feature.
    """
    ring = [[lon, lat], [lon + 0.1, lat], [lon + 0.1, lat + 0.1], [lon, lat + 0.1], [lon, lat]]
    return {
        "type": "Feature",
        "properties": {"SUB_DIST": name, "DISTRICT": district},
        "geometry": {"type": "Polygon", "coordinates": [ring]},
    }


@pytest.fixture
def subdistricts(tmp_path: Path) -> Path:
    """Write four Virudhunagar sub-districts (2×2 grid around the reference point) and one in Madurai.

    Args:
        tmp_path: pytest's temporary directory.

    Returns:
        Path of the GeoJSON file.
    """
    features = [
        _cell("Aruppukottai", "Virudhunagar", 78.05, 9.50),  # holds (9.559806, 78.133521)
        _cell("TIRUCHULI", "Virudhunagar", 78.15, 9.50),
        _cell("Sattur", "Virudhunagar", 78.05, 9.40),
        _cell("Sivakasi", "Virudhunagar", 78.15, 9.40),
        _cell("Madurai South", "Madurai", 78.05, 9.85),
    ]
    path = tmp_path / "subdistricts.geojson"
    path.write_text(json.dumps({"type": "FeatureCollection", "features": features}))
    return path


def _build(subdistricts: Path, out: Path, *extra: str) -> int:
    """Run the build with census-style field names.

    Args:
        subdistricts: input file.
        out: output directory.
        *extra: more command-line arguments.

    Returns:
        Exit code.
    """
    args = ["--subdistricts", str(subdistricts), "--name-field", "SUB_DIST", "--district-field", "DISTRICT"]
    return int(
        _script().main([*args, "--source-url", URL, "--licence", "ODbL-1.0", "--out", str(out), *extra])
    )


def test_builds_v0_district_and_v1_taluk_union_with_provenance(subdistricts: Path, tmp_path: Path) -> None:
    """v0 covers all four Virudhunagar cells; v1 only Sattur, Aruppukottai and Tiruchuli; Madurai is out.

    Args:
        subdistricts: synthetic input file (fixture).
        tmp_path: pytest's temporary directory.
    """
    out = tmp_path / "out"
    assert _build(subdistricts, out) == 0
    v0 = json.loads((out / "gi_region_v0.geojson").read_text())["features"][0]
    v1 = json.loads((out / "gi_region_v1.geojson").read_text())["features"][0]
    for feature, version in ((v0, 0), (v1, 1)):
        props = feature["properties"]
        assert feature["geometry"]["type"] == "MultiPolygon"
        assert props["version_no"] == version and props["licence"] == "ODbL-1.0"
        assert props["confidence"] == "district_derived" and URL in props["source_ref"]
        assert props["built_at"] and props["tolerance_buffer_m"] == 150
        assert props["attribution"].startswith("Boundary data © geoBoundaries")
        assert props["share_alike"] is True
    assert v1["properties"]["taluks"] == ["Sattur", "Aruppukottai", "Tiruchuli"]
    assert v1["properties"]["taluks_confirmed"] is False
    sivakasi, madurai, reference = Point(78.2, 9.45), Point(78.1, 9.9), Point(78.133521, 9.559806)
    assert shape(v0["geometry"]).covers(sivakasi) and not shape(v1["geometry"]).covers(sivakasi)
    assert not shape(v0["geometry"]).covers(madurai)
    assert shape(v1["geometry"]).covers(reference)


def test_missing_taluk_fails_loudly(subdistricts: Path, tmp_path: Path) -> None:
    """A taluk name not found in the district stops the build instead of shrinking the region.

    Args:
        subdistricts: synthetic input file (fixture).
        tmp_path: pytest's temporary directory.
    """
    taluks = tmp_path / "taluks.json"
    taluks.write_text(json.dumps({"confirmed": False, "taluks": [{"name": "Sattur"}, {"name": "Watrap"}]}))
    assert _build(subdistricts, tmp_path / "out", "--taluks", str(taluks)) == 1


def test_districts_file_mode_and_check_point(subdistricts: Path, tmp_path: Path, capsys: Any) -> None:
    """With a separate district layer (geoBoundaries style) sub-districts are picked by containment.

    Args:
        subdistricts: synthetic input file (fixture).
        tmp_path: pytest's temporary directory.
        capsys: pytest's output capture.
    """
    district = {
        "type": "Feature",
        "properties": {"shapeName": "Virudhunagar"},
        "geometry": {
            "type": "Polygon",
            "coordinates": [[[78.05, 9.4], [78.25, 9.4], [78.25, 9.6], [78.05, 9.6], [78.05, 9.4]]],
        },
    }
    districts = tmp_path / "districts.geojson"
    districts.write_text(json.dumps({"type": "FeatureCollection", "features": [district]}))
    out = tmp_path / "out"
    script = _script()
    args = ["--subdistricts", str(subdistricts), "--districts", str(districts), "--name-field", "SUB_DIST"]
    assert script.main([*args, "--source-url", URL, "--licence", "ODbL-1.0", "--out", str(out)]) == 0
    v1 = str(out / "gi_region_v1.geojson")
    assert script.main(["--check-point", "9.559806,78.133521", "--file", v1]) == 0
    assert "is inside" in capsys.readouterr().out
    assert script.main(["--check-point", "9.9252,78.1198", "--file", v1]) == 3
