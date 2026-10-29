"""Write the OpenAPI 3.1 contract to packages/openapi/openapi.json.

Serves: D-003 (one contract, generated clients), D-020 (oasdiff compares this file across seasons).
Callers: `make openapi`, CI drift check; run as `python -m agritrace.export_openapi` from apps/api.
"""

import json
import pathlib

from agritrace.main import create_app

OUT = pathlib.Path(__file__).resolve().parents[3] / "packages" / "openapi" / "openapi.json"


def main() -> None:
    """Generate the spec and write it with stable key order.

    Raises:
        RuntimeError: FastAPI produced a spec version other than 3.1.x.

    Side effects:
        Creates or overwrites `packages/openapi/openapi.json`; prints its path.
    """
    spec = create_app().openapi()
    if not spec["openapi"].startswith("3.1"):
        raise RuntimeError(f"expected OpenAPI 3.1, got {spec['openapi']}")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(spec, indent=2, sort_keys=True) + "\n")
    print(OUT)


if __name__ == "__main__":
    main()
