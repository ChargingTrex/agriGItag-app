"""Unit tests of the identity request/response schemas and the role dependency matrix.

Covers the discriminated OTP-verify response (and its OpenAPI `oneOf` + discriminator), input validation
at the trust boundary (phone, code, PIN), and which roles each identity guard admits.

Serves: FR1, FR14, P00 cross-package contract (B02 acceptance), D-024.
Callers: pytest (`make test-unit`).
"""

import uuid

import pytest
from pydantic import TypeAdapter, ValidationError

from agritrace.core.auth import SUPER_ADMIN, CurrentUser, require_role
from agritrace.core.enums import Role
from agritrace.core.errors import ForbiddenError
from agritrace.main import create_app
from agritrace.modules.identity.router import OFFICE_ROLES
from agritrace.modules.identity.schemas import (
    OtpRequestIn,
    OtpVerifyIn,
    OtpVerifyOut,
    PinIn,
    PinRequiredOut,
    SessionOut,
)

VERIFY = TypeAdapter(OtpVerifyOut)


def test_verify_response_is_discriminated_by_kind() -> None:
    """`kind` picks the model; a pin_required body has no refresh token, role or FPO."""
    fpo = uuid.uuid4()
    session = VERIFY.validate_python(
        {
            "kind": "session",
            "access_token": "a",
            "refresh_token": "r",
            "expires_in": 900,
            "roles": ["farmer"],
            "fpo_id": str(fpo),
        }
    )
    assert isinstance(session, SessionOut) and session.fpo_id == fpo
    pin = VERIFY.validate_python(
        {"kind": "pin_required", "pin_token": "p", "expires_in": 300, "pin_set": True}
    )
    assert isinstance(pin, PinRequiredOut)
    assert set(PinRequiredOut.model_fields) == {"kind", "pin_token", "expires_in", "pin_set"}
    with pytest.raises(ValidationError):
        VERIFY.validate_python({"kind": "other"})


def test_openapi_renders_the_union_as_one_of_with_a_discriminator() -> None:
    """The contract the clients are generated from has `oneOf` + `discriminator.propertyName = kind`."""
    spec = create_app().openapi()
    schema = spec["paths"]["/v1/auth/otp/verify"]["post"]["responses"]["200"]["content"]["application/json"]
    assert schema["schema"]["discriminator"]["propertyName"] == "kind"
    assert len(schema["schema"]["oneOf"]) == 2


@pytest.mark.parametrize("phone", ["9876543210", "+0123456789", "+91 98765 43210", "+91987654321012345"])
def test_phone_must_be_e164(phone: str) -> None:
    """Numbers without `+`, with spaces, a leading zero country code or over 15 digits are refused.

    Args:
        phone: an invalid number.
    """
    with pytest.raises(ValidationError):
        OtpRequestIn(phone=phone)


@pytest.mark.parametrize(("code", "ok"), [("123456", True), ("12345", False), ("12345a", False)])
def test_otp_code_is_six_digits(code: str, ok: bool) -> None:
    """Only exactly 6 digits pass.

    Args:
        code: the submitted code.
        ok: whether it should validate.
    """
    body = {"phone": "+919876543210", "code": code, "device_id": str(uuid.uuid4()), "platform": "android"}
    if ok:
        assert OtpVerifyIn.model_validate(body).code == code
    else:
        with pytest.raises(ValidationError):
            OtpVerifyIn.model_validate(body)


@pytest.mark.parametrize(("pin", "ok"), [("0420", True), ("123", False), ("12345", False), ("12a4", False)])
def test_pin_is_four_digits(pin: str, ok: bool) -> None:
    """Only exactly 4 digits pass.

    Args:
        pin: the submitted PIN.
        ok: whether it should validate.
    """
    if ok:
        assert PinIn(pin=pin).pin == pin
    else:
        with pytest.raises(ValidationError):
            PinIn(pin=pin)


GUARDS = {
    "pin_set (office roles)": OFFICE_ROLES,
    "assist start/end": (Role.FIELD_OFFICER,),
    "flags-style admin route": (Role.FPO_ADMIN, Role.QC_OFFICER, Role.FIELD_OFFICER),
    "super-admin route": (SUPER_ADMIN,),
}


@pytest.mark.parametrize("guard", sorted(GUARDS))
@pytest.mark.parametrize("role", list(Role))
@pytest.mark.parametrize("super_admin", [False, True])
async def test_role_matrix(guard: str, role: Role, super_admin: bool) -> None:
    """Each guard admits exactly its roles; the super-admin flag only opens routes that list it.

    Args:
        guard: name of the guard under test.
        role: the caller's membership role.
        super_admin: the caller's super-admin flag.
    """
    allowed = GUARDS[guard]
    user = CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=role, is_super_admin=super_admin)
    expected = role in allowed or (super_admin and SUPER_ADMIN in allowed)
    if expected:
        assert await require_role(*allowed)(user) is user
    else:
        with pytest.raises(ForbiddenError):
            await require_role(*allowed)(user)
