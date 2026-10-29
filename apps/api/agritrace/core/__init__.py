"""Shared kernel used by every module: config, DB, ids, errors, schemas, storage, time, task names.

Serves: Arch §Backend services, D-004 (core never imports a module).
Callers: every `agritrace.modules.*` package, `agritrace.main`, `agritrace.worker`.
"""
