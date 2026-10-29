"""Identifier generators: UUIDv7 primary keys and the human-readable lot, batch and super-lot codes.

Serves: plan §7.1 ground rules (lot `LOT`+8 hex, batch 12-char Crockford base32 such as `FGP8T4033HM7`),
PRD §12 super-lot `COMBO_LOT_6C1DCCFE`, D-005 (time-ordered client/server UUIDs).
Callers: lots_batches and events services (B01+), seed data, tests/unit/test_ids.py.
"""

import secrets
import uuid

import uuid6

# Crockford base32: digits plus letters without I, L, O, U (no confusion with 1, 0 or rude words).
CROCKFORD = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"


def uuid7() -> uuid.UUID:
    """Return a new time-ordered UUIDv7 (RFC 9562).

    Returns:
        A UUID whose value increases with every call in this process, so B-tree inserts stay append-like.
    """
    return uuid6.uuid7()


def lot_code() -> str:
    """Return a new lot code such as `LOT0EF81415`.

    Only 32 random bits (format fixed by plan §7.1): about 1 % collision chance at 10,000 lots, so callers
    insert under a UNIQUE constraint and retry with a new code on conflict.

    Returns:
        "LOT" followed by 8 upper-case hex characters (32 random bits).
    """
    # shortcut: 32-bit random code; callers insert under a UNIQUE constraint and retry on conflict (B01
    #   adds the unique index, B09 the retry). Upgrade to a longer code if the format may change.
    return "LOT" + secrets.token_hex(4).upper()


def batch_code() -> str:
    """Return a new 12-character Crockford base32 batch code such as `FGP8T4033HM7`.

    Returns:
        12 characters from `CROCKFORD` (60 random bits); printed on packs and in QR links.
    """
    return "".join(secrets.choice(CROCKFORD) for _ in range(12))


def superlot_code() -> str:
    """Return a new super-lot (combined lot) code such as `COMBO_LOT_6C1DCCFE`.

    Same 32-bit collision caveat as `lot_code`: insert under a UNIQUE constraint and retry on conflict.

    Returns:
        "COMBO_LOT_" followed by 8 upper-case hex characters.
    """
    return "COMBO_LOT_" + secrets.token_hex(4).upper()
