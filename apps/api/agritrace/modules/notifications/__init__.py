"""notifications module: Notification templates and delivery (console/SMS providers).

Serves: plan §7.1 B04; D-004 (module boundary).
Callers: other modules only through `models` and `service`, and in practice only by enqueueing
`task_names.NOTIFICATIONS_SEND`; `agritrace.main` mounts `router.router`.
"""

__all__: list[str] = []
