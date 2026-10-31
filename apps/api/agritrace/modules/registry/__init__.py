"""registry module: FPOs, farmers, plots (PostGIS), crops, GI tags and regions, input masters.

Serves: plan §7.1 B03; D-004 (module boundary).
Callers: other modules only through `models` and the names in `service.__all__` (geo checks, area,
address formatting, plot-rule enqueue); `agritrace.main` mounts `router.router`.

The public surface is `agritrace.modules.registry.service.__all__`, not this package: import-linter only
admits `<module>.models` and `<module>.service` edges between modules (pyproject.toml, D-004), so a
re-export here could not be used by other modules and would make every `models` import load FastAPI.
"""

__all__: list[str] = []
