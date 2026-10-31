"""config module: HTTP view of the field and feature configuration (D-017); no tables.

The schema, loader, tenant overrides and validator live in `agritrace.core.fieldconfig` (every module may
import core); this package only holds the router, because `agritrace.main` mounts routers by discovering
`agritrace.modules.<name>.router` (D-004). One place for the logic (core), one for the routes (here).

Serves: D-017, backend-design.md §1 config row, FR23.
Callers: `agritrace.main` mounts `router.router`.
"""

__all__: list[str] = []
