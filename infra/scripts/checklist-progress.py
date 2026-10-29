#!/usr/bin/env python3
"""Rewrite the `Completion:` line of CHECKLIST.md from its checkbox counts.

Serves: project tracking requirement (plan §5). Called by: `make progress`, the pre-commit hook,
and the Orchestrator after every merge.

Args: none (reads and writes ./CHECKLIST.md relative to the repo root, found via this file's path).
Returns: exit code 0; prints the new completion line.
Raises: FileNotFoundError if CHECKLIST.md is missing.
Side effects: overwrites CHECKLIST.md in place.
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
PATH = ROOT / "CHECKLIST.md"


def main() -> None:
    """Count `- [x]` and `- [ ]` items and rewrite the completion line."""
    text = PATH.read_text()
    done = len(re.findall(r"^- \[x\]", text, flags=re.MULTILINE | re.IGNORECASE))
    todo = len(re.findall(r"^- \[ \]", text, flags=re.MULTILINE))
    total = done + todo
    pct = round(100 * done / total) if total else 0
    line = f"Completion: {pct} % ({done}/{total} items)"
    text = re.sub(r"^Completion: .*$", line, text, count=1, flags=re.MULTILINE)
    PATH.write_text(text)
    print(line)


if __name__ == "__main__":
    main()
