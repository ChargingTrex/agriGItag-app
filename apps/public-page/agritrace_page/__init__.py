"""AgriTrace public QR page renderer (W01; PRD FR15-FR19; D-007).

Purpose: turn a privacy-checked ``PublicBatchRecord`` into static ``index.html`` + ``data.json``,
and render the unavailable page (not published, withdrawn, unknown code; W03).
Callers: the backend publishing job (B10) and the portal preview via the API; ``python -m
agritrace_page`` for local builds. No database or network access anywhere in this package.
"""

from agritrace_page.render import BUDGETS, RenderResult, measure, render, render_unavailable
from agritrace_page.schema import PublicBatchRecord

__all__ = [
    "BUDGETS",
    "PublicBatchRecord",
    "RenderResult",
    "measure",
    "render",
    "render_unavailable",
]
