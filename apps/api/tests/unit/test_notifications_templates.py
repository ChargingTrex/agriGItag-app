"""Unit tests of the notification templates: ta/en rendering, English fallback, redaction, documentation.

Serves: FR7, FR5, UserFlows §Alerts, help and feature phones (one sentence, one action), B04 deliverable 3.
Callers: pytest (`make test-unit`).
"""

import pytest

from agritrace.modules.notifications import templates
from agritrace.modules.notifications.templates import TEMPLATES, redact, render


def test_renders_tamil_and_english() -> None:
    """The same template renders in the requested language with the variables filled."""
    assert render("otp", "en", {"code": "123456"}) == (
        "en",
        "Your AgriTrace sign-in code is 123456; type it in the app and share it with no one.",
    )
    lang, text = render("otp", "ta", {"code": "123456"})
    assert lang == "ta" and "123456" in text and "AgriTrace" in text


def test_unknown_language_falls_back_to_english() -> None:
    """A language without a text (or the `when` doc key) renders in English."""
    assert render("grade_given", "hi", {"lot_code": "L-7", "grade": "A"})[0] == "en"
    assert render("grade_given", "when", {"lot_code": "L-7", "grade": "A"})[0] == "en"


def test_unknown_template_and_missing_variable_raise_key_error() -> None:
    """The service turns both into a failed row; here they surface as KeyError."""
    with pytest.raises(KeyError):
        render("nope", "en", {})
    with pytest.raises(KeyError):
        render("payment_made", "en", {"amount": "₹100"})


def test_redact_hides_only_secrets() -> None:
    """`code` is replaced, other variables are kept, the input is not modified."""
    payload = {"code": "987654", "lot_code": "L-1"}
    assert redact(payload) == {"code": templates.REDACTED, "lot_code": "L-1"}
    assert payload["code"] == "987654"


@pytest.mark.parametrize("key", sorted(TEMPLATES))
def test_every_template_is_documented_in_both_languages(key: str) -> None:
    """Each template has its doc line and one sentence (no full stop before the end) per language.

    Args:
        key: template key.
    """
    entry = TEMPLATES[key]
    assert set(entry) == {"when", "en", "ta"}
    for lang in ("en", "ta"):
        assert entry[lang].count(".") <= 1 and entry[lang].endswith(".")
