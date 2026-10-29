"""quality module: Standards profiles, instruments, quality readings and the grade engine.

Serves: plan §7.1 B05; PRD §6.8 FR42–FR52; Dataflow Stages 5, 7, 8; D-015; D-004 (module boundary).
Callers: other modules only through `models` and the names in `service.__all__` (`create_reading`,
`latest_profile_version_for_crop`, `yield_params_for_crop`, `lot_gate_passes`, `compute_grade_for_batch`);
`agritrace.main` mounts `router.router`. Kept empty so importing `quality.models` (alembic, other modules)
does not load the service.
"""

__all__: list[str] = []
