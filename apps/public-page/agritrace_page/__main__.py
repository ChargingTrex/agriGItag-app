"""Entry point for ``python -m agritrace_page`` (W01; FR15 local build).

Callers: developers and CI; the commands live in cli.py.
"""

from agritrace_page.cli import main

raise SystemExit(main())
