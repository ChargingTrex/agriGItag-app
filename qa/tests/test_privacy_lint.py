"""Tests for infra/scripts/privacy-lint.py: the fixtures in qa/fixtures/privacy/ and one case per leak format.

Serves: BM-09 (privacy lint), plan §7.5 Q00, Q00 review r1 P1-1/P1-2/P2-2/P2-3. Callers: CI docs job and
`pytest qa/tests -q`.
"""

import json
import pathlib
import subprocess
import sys

import pytest

ROOT = pathlib.Path(__file__).resolve().parents[2]
LINT = ROOT / "infra" / "scripts" / "privacy-lint.py"
FIXTURES = ROOT / "qa" / "fixtures" / "privacy"
CANARY = "CANARY-FARMER-7F3A"
PRETTY_POINT = json.dumps({"type": "Point", "coordinates": [78.1335214, 9.5598061]}, indent=2)
PRETTY_RING = json.dumps({"boundary": [[78.1335, 9.5598], [78.134, 9.5598], [78.134, 9.5602]]}, indent=2)

LEAKS = [
    ("index.html", "<p>Farmer contact 98765 43210</p>", "phone"),
    ("index.html", "<p>+91 98765 43210</p>", "phone"),
    ("index.html", "<p>98765-43210</p>", "phone"),
    ("index.html", "<p>09876543210</p>", "phone"),
    ("index.html", "<p>0091 98765 43210</p>", "phone"),
    ("index.html", "<p>(987) 654-3210</p>", "phone"),
    ("index.html", "<p>98765.43210</p>", "phone"),
    ("index.html", "<p>98765\u200b43210</p>", "phone"),
    ("index.html", '<a href="https://example.org/call?to=9876543210">x</a>', "phone"),
    ("index.html", "<p>ID 2345-6789-0123</p>", "aadhaar"),
    ("index.html", "<p>ID 2345 6789 0123</p>", "aadhaar"),
    ("index.html", "<p>POINT(78.1335214 9.5598061)</p>", "coordinate_precision"),
    ("index.html", '<a href="https://maps.example.org/?q=9.5598061%2C78.1335214">m</a>', "coordinate_precision"),
    ("data.json", PRETTY_POINT, "coordinate_precision"),
    ("data.json", PRETTY_RING, "polygon"),
    ("data.json", '{"x": 78.1335214, "y": 9.5598061}', "coordinate_precision"),
    ("index.html", "<table><tr><th>பட்டா</th><td>45</td></tr></table>", "sensitive_label"),
    ("index.html", "<dl><dt>சிட்டா</dt><dd>12</dd></dl>", "sensitive_label"),
    ("index.html", "<p>சர்வே எண் 12</p>", "sensitive_label"),
    ("index.html", "<label>தொலைபேசி</label>", "sensitive_label"),
    ("index.html", "<p>அலைபேசி: 2026 1029</p>", "sensitive_label"),
    ("index.html", "<p>ஆதார் எண் 4321</p>", "sensitive_label"),
    ("index.html", "<p>S.F. No. 123/4A</p>", "sensitive_label"),
    ("index.html", "<p>Sy. No. 77</p>", "sensitive_label"),
    ("index.html", "<p>Survey No 77</p>", "sensitive_label"),
    ("index.html", "<table><tr><th>Mobile</th><td>on request</td></tr></table>", "sensitive_label"),
    ("data.json", '{"farmer_phone": "on request"}', "sensitive_label"),
    ("app.js", 'const c = "98765 43210";', "phone"),
    ("area.geojson", '{"type": "Polygon", "coordinates": []}', "polygon"),
    ("sitemap.xml", "<loc>/tmp/page</loc>", "temp_path"),
]


def run_lint(*args: str) -> subprocess.CompletedProcess:
    """Run the privacy linter as CI does.

    Args:
        *args: command-line arguments passed after the script path.

    Returns:
        The completed process with text stdout/stderr.
    """
    return subprocess.run([sys.executable, str(LINT), *args], capture_output=True, text=True, check=False)


def test_clean_fixture_passes() -> None:
    """The clean folder, full of look-alikes (3-dp pins, FSSAI number, UUID, hashes, dates), has zero hits."""
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


@pytest.mark.parametrize(("name", "content", "rule"), LEAKS)
def test_each_leak_format_is_caught(tmp_path: pathlib.Path, name: str, content: str, rule: str) -> None:
    """One file holding one leak makes the linter exit 1 with the expected rule.

    Args:
        tmp_path: pytest's per-test folder.
        name: file name to write (its suffix decides JSON parsing).
        content: the file content holding the leak.
        rule: the rule that must fire.
    """
    (tmp_path / name).write_text(content, encoding="utf-8")
    done = run_lint(str(tmp_path))
    assert done.returncode == 1
    assert f": {rule}: " in done.stdout, done.stdout


@pytest.mark.parametrize(
    "content",
    [
        "<style>/* Mobile-first; system fonts only */ body{margin:0}</style>",
        "<script>// phone numbers never shown here\nconst a = 1;</script>",
        "<p>Works on any mobile phone, even offline.</p>",
    ],
)
def test_label_words_outside_label_context_pass(tmp_path: pathlib.Path, content: str) -> None:
    """Regression for W01-1: label words in CSS/JS or plain prose are not personal data.

    Args:
        tmp_path: pytest's per-test folder.
        content: page content with a label word but no label context.
    """
    (tmp_path / "index.html").write_text(content, encoding="utf-8")
    done = run_lint(str(tmp_path))
    assert done.returncode == 0, done.stdout


def test_w01_built_page_with_phone_next_to_label_fails() -> None:
    """The real W01 page passes (clean fixture); the same page with "Mobile: <number>" fails on both rules."""
    done = run_lint(str(FIXTURES / "dirty" / "w01"))
    assert done.returncode == 1
    assert ": sensitive_label: Mobile" in done.stdout and ": phone: " in done.stdout


def test_tel_link_reports_phone_once(tmp_path: pathlib.Path) -> None:
    """A +91 number is one phone hit, not also an Aadhaar hit.

    Args:
        tmp_path: pytest's per-test folder.
    """
    (tmp_path / "index.html").write_text('<a href="tel:+919876543210">call</a>', encoding="utf-8")
    done = run_lint(str(tmp_path))
    assert done.stdout.count(": phone: ") == 1 and ": aadhaar: " not in done.stdout


def test_missing_or_empty_directory_is_a_usage_error(tmp_path: pathlib.Path) -> None:
    """A wrong path or a folder with nothing to scan must not pass silently.

    Args:
        tmp_path: pytest's per-test folder.
    """
    assert run_lint(str(FIXTURES / "does-not-exist")).returncode == 2
    (tmp_path / "logo.png").write_bytes(b"\x89PNG")
    assert run_lint(str(tmp_path)).returncode == 2
