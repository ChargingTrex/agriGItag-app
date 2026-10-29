"""Self-test for infra/scripts/privacy-lint.py against the fixtures in qa/fixtures/privacy/.

Serves: BM-09 (privacy lint), plan §7.5 Q00. Callers: CI docs job and pre-merge runs of
`pytest qa/tests -q`.
"""

import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
LINT = ROOT / "infra" / "scripts" / "privacy-lint.py"
FIXTURES = ROOT / "qa" / "fixtures" / "privacy"
CANARY = "CANARY-FARMER-7F3A"


def run_lint(*args: str) -> subprocess.CompletedProcess:
    """Run the privacy linter as CI does.

    Args:
        *args: command-line arguments passed after the script path.

    Returns:
        The completed process with text stdout/stderr.
    """
    return subprocess.run([sys.executable, str(LINT), *args], capture_output=True, text=True, check=False)


def test_clean_fixture_passes() -> None:
    """The clean page, full of look-alikes (3-dp link, FSSAI number, hash), has zero hits."""
    done = run_lint(str(FIXTURES / "clean"), "--canary", CANARY)
    assert done.returncode == 0, done.stdout
    assert "0 hit(s)" in done.stdout


def test_dirty_fixture_reports_every_rule_without_echoing_the_leak() -> None:
    """Every rule fires on the dirty fixture and redacted rules never print the leaked value."""
    done = run_lint(str(FIXTURES / "dirty"), "--canary", CANARY)
    assert done.returncode == 1
    for rule in ("phone", "aadhaar", "sensitive_label", "coordinate_precision", "polygon", "temp_path", "canary"):
        assert f": {rule}: " in done.stdout, f"rule {rule} did not fire:\n{done.stdout}"
    for leak in ("9876543210", "2345 6789 0123", CANARY):
        assert leak not in done.stdout


def test_missing_directory_is_a_usage_error() -> None:
    """A wrong path must not pass silently."""
    assert run_lint(str(FIXTURES / "does-not-exist")).returncode == 2
