"""Message templates in Tamil and English, one sentence each, each telling the reader one thing to do.

Keys are the `template_key` other modules pass to `notifications.send`; the mobile app may show the same
message from its own l10n under `notif` + the camelCased key (e.g. `notifHarvestReminder`).
Rendering is plain `str.format` with the task's `payload`; amounts and quantities arrive already formatted
with their units (FR58), e.g. `"120 kg"`, `"₹12,400"`.

Serves: FR7 (reminders and results by push/SMS), FR5 (farmer's language), UserFlows §Alerts, help and
feature phones ("every message tells them one thing to do"; reminders; sale, grade, payment results).
Callers: notifications service (`deliver`), tests/unit/test_notifications_templates.py.
"""

from typing import Any

# Payload keys whose values are secrets: never stored, logged or shown back (TODO B02 kwargs contract).
SECRET_KEYS = frozenset({"code"})
REDACTED = "***"

# Each entry: `when` (who receives it, what triggers it, payload variables), then the text per language.
TEMPLATES: dict[str, dict[str, str]] = {
    "otp": {
        "when": "Any user signing in (identity, B02). Variables: code (secret; redacted except in the SMS).",
        "en": "Your AgriTrace sign-in code is {code}; type it in the app and share it with no one.",
        "ta": "உங்கள் AgriTrace உள்நுழைவுக் குறியீடு {code}; இதைச் செயலியில் உள்ளிடுங்கள், யாரிடமும் பகிர வேண்டாம்.",
    },
    "harvest_reminder": {
        "when": "Farmer, from the crop calendar when the harvest window opens. Variables: plot_name.",
        "en": "Time to log your harvest for {plot_name}: open AgriTrace and tap Harvest.",
        "ta": "{plot_name} அறுவடையைப் பதிவு செய்யும் நேரம்: AgriTrace-ஐத் திறந்து 'அறுவடை' என்பதைத் தொடுங்கள்.",
    },
    "sale_received": {
        "when": "Farmer, when the FPO records the intake of their lot. Variables: quantity, lot_code.",
        "en": "The FPO received {quantity} from your lot {lot_code}; open AgriTrace to check the weight.",
        "ta": "உங்கள் {lot_code} லாட்டிலிருந்து {quantity} FPO-வுக்கு வந்து சேர்ந்தது; எடையைச் சரிபார்க்க "
        "AgriTrace-ஐத் திறங்கள்.",
    },
    "grade_given": {
        "when": "Farmer, when their lot (or the batch it went into) is graded. Variables: lot_code, grade.",
        "en": "Your lot {lot_code} was graded {grade}; open AgriTrace to see the result.",
        "ta": "உங்கள் {lot_code} லாட்டுக்கு {grade} தரம் வழங்கப்பட்டது; முடிவைப் பார்க்க AgriTrace-ஐத் திறங்கள்.",
    },
    "payment_made": {
        "when": "Farmer, when the FPO records a payment for their lot. Variables: amount, lot_code.",
        "en": "{amount} was paid for your lot {lot_code}; check your bank account.",
        "ta": "உங்கள் {lot_code} லாட்டுக்கு {amount} செலுத்தப்பட்டது; உங்கள் வங்கிக் கணக்கைச் சரிபாருங்கள்.",
    },
    "flag_raised": {
        "when": "Field officer, when a rule raises a flag on their farmer. Variables: severity, farmer_code.",
        "en": "A {severity} flag was raised for farmer {farmer_code}; open AgriTrace to review it.",
        "ta": "விவசாயி {farmer_code}-க்கு {severity} எச்சரிக்கை எழுப்பப்பட்டது; அதைச் சரிபார்க்க AgriTrace-ஐத் திறங்கள்.",
    },
}


def redact(payload: dict[str, Any]) -> dict[str, Any]:
    """Copy a payload with every secret value replaced.

    Args:
        payload: template variables as sent by the caller.

    Returns:
        A new dict; values under `SECRET_KEYS` become `***`, all others are unchanged.
    """
    return {k: REDACTED if k in SECRET_KEYS else v for k, v in payload.items()}


def render(template_key: str, lang: str, payload: dict[str, Any]) -> tuple[str, str]:
    """Fill a template in the requested language, falling back to English.

    Args:
        template_key: a key of `TEMPLATES`.
        lang: `ta` or `en`; any language without a text renders in English.
        payload: the template's variables.

    Returns:
        `(lang_rendered, text)`.

    Raises:
        KeyError: unknown `template_key`, or a variable the template needs is missing from `payload`.
    """
    entry = TEMPLATES[template_key]
    used = lang if lang in entry and lang != "when" else "en"
    return used, entry[used].format(**payload)
