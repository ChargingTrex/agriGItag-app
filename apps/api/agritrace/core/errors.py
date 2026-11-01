"""Application error hierarchy, its code registry, and the handlers that render the error envelope.

Serves: CLAUDE.md §5.5 (registered snake_case codes, en/ta message key, how-to-fix line), plan §7.1
(envelope `{"error": {code, message, details}}`; 422 validation, 409 gates, 501 stubs).
Callers: every module raises `AppError` subclasses; `agritrace.main` installs `install_handlers`;
`infra/scripts/gen-error-codes.py` renders `REGISTRY` into docs/api/error-codes.md.
"""

import logging
from collections.abc import Mapping
from typing import Any, ClassVar

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import DBAPIError
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger(__name__)

REGISTRY: dict[str, type["AppError"]] = {}
HTTP_METHODS = {"get", "put", "post", "delete", "options", "head", "patch", "trace"}


class AppError(Exception):
    """Base of every error the API returns on purpose.

    Subclasses set the class attributes; defining a subclass with a `code` registers it in `REGISTRY`.
    """

    code: ClassVar[str] = ""
    status: ClassVar[int] = 500
    message_key: ClassVar[str] = ""
    message: ClassVar[str] = ""
    fix: ClassVar[str] = ""

    def __init_subclass__(cls, **kwargs: Any) -> None:
        """Register the subclass under its `code`.

        Args:
            **kwargs: passed to `Exception.__init_subclass__`.

        Raises:
            ValueError: another class already registered the same `code`.

        Side effects:
            Adds `cls` to `REGISTRY`.
        """
        super().__init_subclass__(**kwargs)
        if not cls.code:
            return
        if cls.code in REGISTRY:
            raise ValueError(f"error code {cls.code!r} already registered by {REGISTRY[cls.code].__name__}")
        REGISTRY[cls.code] = cls

    def __init__(self, message: str | None = None, details: Any = None) -> None:
        """Create the error.

        Args:
            message: English text for this occurrence; defaults to the class `message`.
            details: JSON-serialisable context for the client (field names, ids, limits).
        """
        self.detail_message = message or self.message
        self.details = details
        super().__init__(self.detail_message)


class ValidationFailedError(AppError):
    """Request body or parameters failed validation or a plausibility check."""

    code, status, message_key = "validation_error", 422, "error.validation_error"
    message = "The request has invalid or implausible values."
    fix = "Correct the fields listed in `details` and send again."


class UnauthorizedError(AppError):
    """No valid access token."""

    code, status, message_key = "unauthorized", 401, "error.unauthorized"
    message = "Sign-in is required."
    fix = "Sign in again (OTP) and retry with the new access token."


class ForbiddenError(AppError):
    """The caller's role or FPO scope does not allow this action."""

    code, status, message_key = "forbidden", 403, "error.forbidden"
    message = "Your role does not allow this action."
    fix = "Ask an FPO admin to do it or to grant the needed role."


class NotFoundError(AppError):
    """The resource does not exist or is outside the caller's FPO."""

    code, status, message_key = "not_found", 404, "error.not_found"
    message = "Not found."
    fix = "Check the id or code; it may belong to another FPO."


class MethodNotAllowedError(AppError):
    """The path exists but not for this HTTP method."""

    code, status, message_key = "method_not_allowed", 405, "error.method_not_allowed"
    message = "This method is not allowed on this path."
    fix = "Use a method listed in the OpenAPI document for this path."


class ConflictError(AppError):
    """The request conflicts with the current state (duplicate, stale version)."""

    code, status, message_key = "conflict", 409, "error.conflict"
    message = "The request conflicts with the current state."
    fix = "Reload the resource and retry with fresh data."


class GateNotMetError(AppError):
    """A lifecycle gate (approve, publish, lot close) has unmet conditions."""

    code, status, message_key = "gate_not_met", 409, "error.gate_not_met"
    message = "The conditions for this step are not met yet."
    fix = "Resolve the items listed in `details` (flags, missing evidence) and retry."


class AppendOnlyViolationError(AppError):
    """Something tried to update or delete an append-only record."""

    code, status, message_key = "append_only_violation", 409, "error.append_only_violation"
    message = "Records of this kind cannot be changed or deleted."
    fix = "Submit a correction as a new version instead of editing the old one."


# --- registry (B03): onboarding, plots, GI regions ------------------------------------------------------


class ClientIdConflictError(AppError):
    """A client-generated id (D-005) is already used by another user, FPO or a different record."""

    code, status, message_key = "client_id_conflict", 409, "error.client_id_conflict"
    message = "This id is already used by another record."
    fix = "Generate a new UUID on the device for the new record and send it again."


class PlotLockedError(AppError):
    """A plot's location is set once at onboarding; only an FPO admin correction may change it (FR71)."""

    code, status, message_key = "plot_locked", 409, "error.plot_locked"
    message = "The plot location is locked after onboarding."
    fix = "Ask the FPO admin to correct the plot with a reason (POST /v1/plots/{id}/correct)."


class ReasonRequiredError(AppError):
    """A correction was sent without the coded reason it must carry (FR71, FR25)."""

    code, status, message_key = "reason_required", 422, "error.reason_required"
    message = "A reason is required for this correction."
    fix = "Pick a reason code (and add a note if useful), then send the correction again."


class InvalidGeometryError(AppError):
    """A GeoJSON geometry is malformed, self-intersecting, empty or outside WGS84 ranges."""

    code, status, message_key = "invalid_geometry", 422, "error.invalid_geometry"
    message = "The shape is not a valid outline."
    fix = "Send a closed, non-self-intersecting outline in WGS84 [lon, lat]; `details` names the problem."


class GiRegionMissingError(AppError):
    """The GI tag has no effective region version yet, so locations cannot be checked against it (FR27)."""

    code, status, message_key = "gi_region_missing", 404, "error.gi_region_missing"
    message = "No GI region is loaded for this GI tag yet."
    fix = "A super-admin uploads a region version (POST /v1/gi-tags/{id}/region-versions)."


class FarmerNotPendingError(AppError):
    """Only a pending farmer can be approved (Stage 0)."""

    code, status, message_key = "farmer_not_pending", 409, "error.farmer_not_pending"
    message = "This farmer is not waiting for approval."
    fix = "Reload the farmer; it may already be active or suspended."


class FarmerPhoneTakenError(AppError):
    """Another farmer of the same FPO already uses this phone (Architect-Gate F7: one home per phone)."""

    code, status, message_key = "farmer_phone_taken", 409, "error.farmer_phone_taken"
    message = "Another farmer in this FPO already has this phone number."
    fix = "Open the existing farmer instead, or check the number with the farmer."


# --- field configuration and imports (B13, D-017) ------------------------------------------------------


class FieldRequiredError(AppError):
    """A field the tenant's configuration marks required is missing or blank (D-017)."""

    code, status, message_key = "field_required", 422, "error.field_required"
    message = "A required field is missing."
    fix = "Fill in the field named in `details.field` (see GET /v1/config/fields) and send again."


class FieldUnknownError(AppError):
    """A payload key is not in the entity's field configuration and the entity forbids extras (D-017)."""

    code, status, message_key = "field_unknown", 422, "error.field_unknown"
    message = "The request has a field this form does not know."
    fix = "Remove the field named in `details.field`, or check its spelling against GET /v1/config/fields."


class FeatureDisabledError(AppError):
    """The endpoint belongs to a feature switched off for the caller's FPO; answered as 404 (D-017)."""

    code, status, message_key = "feature_disabled", 404, "error.feature_disabled"
    message = "This feature is not switched on for your FPO."
    fix = "Ask the platform team to enable the flag in the FPO's tenant file (GET /v1/config/features)."


class ImportTooLargeError(AppError):
    """A CSV import is over 2 MB or 5,000 data rows."""

    code, status, message_key = "import_too_large", 413, "error.import_too_large"
    message = "The file is too large to import."
    fix = "Split the file into parts of at most 5,000 rows and 2 MB, and import each part."


class ImportRowInvalidError(AppError):
    """A CSV row has a value of the wrong kind (bad number, unknown category, bad phone format)."""

    code, status, message_key = "import_row_invalid", 422, "error.import_row_invalid"
    message = "A value in this row is not valid."
    fix = "Correct the column named in `field` for that row (see the template) and import the row again."


class ImportRowExistsError(AppError):
    """A CSV row describes a record that already exists (same LGD code, or same input name and maker)."""

    code, status, message_key = "import_row_exists", 409, "error.import_row_exists"
    message = "This record already exists."
    fix = "No action needed if it was imported before; otherwise change the key column named in `field`."


class RateLimitedError(AppError):
    """Too many requests from this caller."""

    code, status, message_key = "rate_limited", 429, "error.rate_limited"
    message = "Too many requests."
    fix = "Wait for the `Retry-After` interval, then retry with backoff."


class PayloadTooLargeError(AppError):
    """The request body is over the endpoint's limit (sync push: 50 entries or 256 KB)."""

    code, status, message_key = "payload_too_large", 413, "error.payload_too_large"
    message = "The request is too large."
    fix = "Split the request into smaller batches (see `details` for the limit) and send each one."


class InternalError(AppError):
    """Unexpected server failure; the cause is logged, not returned."""

    code, status, message_key = "internal_error", 500, "error.internal_error"
    message = "Something went wrong on the server."
    fix = "Retry later; if it persists, report the time and request path to support."


class NotImplementedPilotError(AppError):
    """Endpoint exists in the contract but is stubbed in the pilot."""

    code, status, message_key = "not_implemented_pilot", 501, "error.not_implemented_pilot"
    message = "This feature is not available in the pilot."
    fix = "No client action; the feature is planned after the pilot."


# Quality readings and grading (B05; PRD §6.8 FR47–FR50). Plausibility codes equal the grade engine's
# `Violation.code` values, so the phone preview (D-006) shows the same reason.


class ImplausibleValueError(AppError):
    """A reading lies outside the parameter's physically plausible range (FR50)."""

    code, status, message_key = "implausible_value", 422, "error.implausible_value"
    message = "The value is outside the plausible range for this parameter."
    fix = "Re-measure and enter the value shown by the instrument; `details` gives the allowed range."


class UnitMismatchError(AppError):
    """A reading's unit differs from the unit its Standards Profile parameter uses (FR42, FR58)."""

    code, status, message_key = "unit_mismatch", 422, "error.unit_mismatch"
    message = "The unit does not match the standards profile."
    fix = "Send the value in the unit named in `details` (convert it on the device if needed)."


class UnknownParameterError(AppError):
    """A reading names a parameter the crop's Standards Profile does not define (FR46)."""

    code, status, message_key = "unknown_parameter", 422, "error.unknown_parameter"
    message = "This parameter is not part of the crop's standards profile."
    fix = "Refresh the standards bundle and pick a parameter from the current profile."


class SourceNotAllowedError(AppError):
    """The measurement source (lab, instrument, visual) is not accepted for this parameter (FR44)."""

    code, status, message_key = "source_not_allowed", 422, "error.source_not_allowed"
    message = "This measurement source is not accepted for this parameter."
    fix = "Measure with one of the sources listed in `details` (e.g. a calibrated instrument or a lab)."


class InstrumentCalibrationExpiredError(AppError):
    """The instrument was past its calibration due date (or has none) when the reading was taken (FR50)."""

    code, status, message_key = "instrument_calibration_expired", 422, "error.instrument_calibration_expired"
    message = "The instrument's calibration has expired."
    fix = "Recalibrate the instrument and update its calibration dates, or use another calibrated instrument."


class MoistureTrailViolationError(AppError):
    """A later-stage reading rose above the earlier stage beyond the tolerance, without a reason (FR50)."""

    code, status, message_key = "moisture_trail_violation", 422, "error.moisture_trail_violation"
    message = "The value rose since the previous stage."
    fix = "Re-measure, or send the reading again with a `reason_code` (it is then accepted and flagged)."


class UnknownGradeForProfileError(AppError):
    """The declared grade is not in the Standards Profile applied (FR49), e.g. "A" for AGMARK chilli."""

    code, status, message_key = "unknown_grade_for_profile", 422, "error.unknown_grade_for_profile"
    message = "This grade does not exist in the standards profile."
    fix = "Declare one of the grades listed in `details`."


class NoPublishedProfileError(AppError):
    """The crop has no published Standards Profile, so readings cannot be checked or graded (FR47)."""

    code, status, message_key = "no_published_profile", 422, "error.no_published_profile"
    message = "The crop has no published standards profile."
    fix = "Ask the compliance team (super-admin) to publish a standards profile for the crop."


class ProfileIncompleteNotAllowedError(AppError):
    """Publishing a profile version whose grading parameters still say load_from_standard (FR47, D-015)."""

    code, status, message_key = "profile_incomplete_not_allowed", 422, "error.profile_incomplete_not_allowed"
    message = "Some grading parameters have no limits yet (load_from_standard)."
    fix = "Enter the limits from the standard, or publish with `allow_incomplete: true` (public note shown)."


# Identity (B02, FR1, D-024). Wrong codes and PINs get their own codes, never a bare 401 (P00 contract).
class OtpInvalidError(AppError):
    """The one-time code is wrong, or the phone cannot sign in (indistinguishable on purpose)."""

    code, status, message_key = "otp_invalid", 422, "error.otp_invalid"
    message = "The code is not correct."
    fix = "Re-enter the 6-digit code from the SMS; after 5 wrong tries request a new code."


class OtpExpiredError(AppError):
    """The one-time code is older than its 5-minute lifetime."""

    code, status, message_key = "otp_expired", 422, "error.otp_expired"
    message = "The code has expired."
    fix = "Request a new code (`POST /v1/auth/otp/request`) and enter it within 5 minutes."


class OtpLockedError(AppError):
    """Five wrong codes were entered for the current challenge."""

    code, status, message_key = "otp_locked", 409, "error.otp_locked"
    message = "Too many wrong codes."
    fix = "Request a new code after 60 seconds; the locked code can no longer be used."


class PinInvalidError(AppError):
    """The office PIN is wrong."""

    code, status, message_key = "pin_invalid", 422, "error.pin_invalid"
    message = "The PIN is not correct."
    fix = "Re-enter your 4-digit PIN; 5 wrong tries lock it for 5 minutes."


class PinLockedError(AppError):
    """Five wrong PINs were entered; the PIN is locked for 5 minutes."""

    code, status, message_key = "pin_locked", 409, "error.pin_locked"
    message = "Too many wrong PINs; try again in 5 minutes."
    fix = "Wait until `details.locked_until`, then sign in again with a new OTP."


class RefreshReusedError(AppError):
    """A refresh token that was already rotated was presented again; the device is signed out."""

    code, status, message_key = "refresh_reused", 401, "error.refresh_reused"
    message = "This sign-in was used elsewhere and has been closed."
    fix = "Sign in again with an OTP; make sure the app sends only one refresh at a time."


class AssistSessionInvalidError(AppError):
    """The assist session named by `X-Assist-Session` or a sync entry's `assist_session_id` is not usable.

    Not the caller's, or (header only) already closed; a sync entry may name an ended session (D-032).
    """

    code, status, message_key = "assist_session_invalid", 403, "error.assist_session_invalid"
    message = "The assist session is not open for you."
    fix = (
        "Start a new assist session (`POST /v1/assist/start` or an `assist_session` push entry) and send its "
        "id in `X-Assist-Session` or the push entry's `assist_session_id`."
    )


class DeviceInUseError(AppError):
    """The device id is signed in for another user; it must sign out before someone else signs in on it."""

    code, status, message_key = "device_in_use", 409, "error.device_in_use"
    message = "This device is signed in for another user."
    fix = "Sign out on this device first (`POST /v1/auth/logout`), then sign in again."


class AccountInactiveError(AppError):
    """The OTP matched, but the account has no FPO membership left or is suspended (B14: rejected farmer).

    Raised only after the code check, so a wrong code still gets `otp_invalid` and a phone number alone
    reveals nothing (D-024).
    """

    code, status, message_key = "account_inactive", 403, "error.account_inactive"
    message = "This account is not active in any FPO."
    fix = "Your FPO has not approved this account; contact the FPO office."


class ConsentConflictError(AppError):
    """A consent `client_id` already exists with different content or for another farmer (D-005)."""

    code, status, message_key = "consent_conflict", 409, "error.consent_conflict"
    message = "A different consent was already saved with this id."
    fix = "Generate a new client_id for a new consent; resend the same body only to retry."


# Events and sync (B06; FR25, FR59, D-005). Reuses `client_id_conflict`, `payload_too_large`,
# `append_only_violation` and `not_implemented_pilot` from above.


class StaleVersionError(AppError):
    """An event version's `version_no` is not the next one (max + 1), e.g. two devices corrected at once."""

    code, status, message_key = "stale_version", 409, "error.stale_version"
    message = "This event was changed since your copy; the version number is not the next one."
    fix = "Pull the latest version of the event, re-apply your change on it and send it with version max + 1."


class UndoWindowClosedError(AppError):
    """A farmer tried to undo an own entry more than 24 hours after it was captured (FR6, FR25)."""

    code, status, message_key = "undo_window_closed", 409, "error.undo_window_closed"
    message = "Entries can be undone only within 24 hours."
    fix = "Ask your field officer to correct the entry with a reason instead."


# Rules and flags (B08; FR70 review on flags). Reuses `reason_required`, `forbidden` and `not_found`.


class FlagNotOpenError(AppError):
    """A flag was already resolved (cleared or fixed); only open or escalated flags can be resolved."""

    code, status, message_key = "flag_not_open", 409, "error.flag_not_open"
    message = "This flag is already resolved."
    fix = "Reload the flag; a later rule run reopens it if the problem comes back worse."


class ResolutionForbiddenError(AppError):
    """A field officer tried to resolve a `hold` flag or an escalated one; only an FPO admin may (FR70)."""

    code, status, message_key = "resolution_forbidden", 403, "error.resolution_forbidden"
    message = "Only an FPO admin can resolve this flag."
    fix = "Escalate it, or ask an FPO admin to review and resolve it."


# Publishing (B10; FR15-FR17, CLAUDE.md §6). Rebuild and label gates reuse `gate_not_met`.


class PublicRecordInvalidError(AppError):
    """The public page record failed the renderer's allow-list or privacy check (W01 `PublicBatchRecord`)."""

    code, status, message_key = "public_record_invalid", 409, "error.public_record_invalid"
    message = "The public page could not be built from this batch's data."
    fix = (
        "Read `details` (field path and reason, never the value), correct that record (e.g. farming type, "
        "village, FSSAI number) and call POST /v1/batches/{id}/rebuild."
    )


class RetryLaterError(AppError):
    """Postgres aborted the transaction to break a deadlock or a serialization conflict (QA issue B08-2)."""

    code, status, message_key = "retry_later", 503, "error.retry_later"
    message = "The server was busy with a conflicting change; nothing was saved."
    fix = "Send the same request again (same client_id) after `Retry-After` seconds."


SQLSTATE_RESTRICT_VIOLATION = "23001"
SQLSTATE_RETRYABLE = {
    "40P01",
    "40001",
}  # deadlock_detected, serialization_failure: the transaction rolled back


def append_only_error(exc: BaseException) -> AppendOnlyViolationError | None:
    """Translate the append-only trigger's database error into the registered AppError (TODO B06/B07).

    Args:
        exc: any exception, typically `sqlalchemy.exc.DBAPIError` from a flush or execute.

    Returns:
        `AppendOnlyViolationError` when the driver reports SQLSTATE 23001 (`restrict_violation`, raised by
        `forbid_change()` in migration 0001), else None.
    """
    sqlstate = getattr(getattr(exc, "orig", None), "sqlstate", None)
    return AppendOnlyViolationError() if sqlstate == SQLSTATE_RESTRICT_VIOLATION else None


def _envelope(
    status: int, code: str, message: str, details: Any = None, headers: Mapping[str, str] | None = None
) -> JSONResponse:
    """Render the standard error envelope.

    Args:
        status: HTTP status code.
        code: registered snake_case error code.
        message: human-readable English message.
        details: JSON-serialisable context, or None.
        headers: response headers to keep, e.g. `Allow` on 405.

    Returns:
        `{"error": {"code", "message", "details"}}` as a JSON response.
    """
    body = {"error": {"code": code, "message": message, "details": details}}
    return JSONResponse(jsonable_encoder(body), status_code=status, headers=headers)


async def _app_error(_: Request, exc: Exception) -> JSONResponse:
    """Render a raised `AppError`.

    Args:
        _: the request (unused).
        exc: the raised `AppError`.

    Returns:
        The envelope with the error's status, code, message and details.
    """
    assert isinstance(exc, AppError)
    return _envelope(exc.status, exc.code, exc.detail_message, exc.details)


async def _validation_error(_: Request, exc: Exception) -> JSONResponse:
    """Render FastAPI request validation failures as `validation_error`.

    Args:
        _: the request (unused).
        exc: the `RequestValidationError` raised by FastAPI.

    Returns:
        422 envelope whose `details` lists each failing field (`loc`, `msg`, `type`).
    """
    assert isinstance(exc, RequestValidationError)
    details = [{"loc": e["loc"], "msg": e["msg"], "type": e["type"]} for e in exc.errors()]
    return _envelope(422, ValidationFailedError.code, ValidationFailedError.message, details)


async def _http_error(request: Request, exc: Exception) -> JSONResponse:
    """Render Starlette HTTP errors (unknown path, wrong method) with a registered code.

    Args:
        request: the request, used to list every method served on its path for a 405.
        exc: the `StarletteHTTPException`.

    Returns:
        Envelope using the first registered code with the same status, else `internal_error`; the
        exception's headers are kept. On 405, `Allow` lists every method documented for the path
        (Starlette only names the first matching route's, e.g. GET but not HEAD on /v1/healthz; RFC 9110
        wants all).
    """
    assert isinstance(exc, StarletteHTTPException)
    cls = next((c for c in REGISTRY.values() if c.status == exc.status_code), InternalError)
    headers = dict(exc.headers or {})
    route = request.scope.get("route")  # the partially matched route, set by the router on a 405
    if exc.status_code == 405 and route is not None:
        # The OpenAPI path item is the public, already-flattened view of all routes on this path.
        item = request.app.openapi()["paths"].get(getattr(route, "path_format", ""), {})
        methods = set(getattr(route, "methods", None) or ()) | {k.upper() for k in item if k in HTTP_METHODS}
        headers["Allow"] = ", ".join(sorted(methods))
    return _envelope(exc.status_code, cls.code, cls.message, None, headers)


async def _db_error(request: Request, exc: Exception) -> JSONResponse:
    """Render SQLSTATE 23001 as `append_only_violation`, 40P01/40001 as `retry_later`; hide every other error.

    Args:
        request: the request (passed on to `_unhandled`).
        exc: a `sqlalchemy.exc.DBAPIError`.

    Returns:
        409 `append_only_violation`, 503 `retry_later` with `Retry-After: 1`, or the `internal_error`
        envelope from `_unhandled`.

    Side effects:
        Logs a WARNING for a retryable error; every other error with its traceback (through `_unhandled`).
    """
    if getattr(getattr(exc, "orig", None), "sqlstate", None) in SQLSTATE_RETRYABLE:
        log.warning(
            "retryable database error on %s %s: %s", request.method, request.url.path, exc.__class__.__name__
        )
        return _envelope(503, RetryLaterError.code, RetryLaterError.message, headers={"Retry-After": "1"})
    mapped = append_only_error(exc)
    if mapped is None:
        return await _unhandled(request, exc)
    return _envelope(mapped.status, mapped.code, mapped.detail_message)


async def _unhandled(_: Request, exc: Exception) -> JSONResponse:
    """Hide unexpected exceptions behind `internal_error`.

    Args:
        _: the request (unused).
        exc: any exception no other handler caught.

    Returns:
        500 envelope without internals.

    Side effects:
        Logs the exception with its traceback.
    """
    log.exception("unhandled error", exc_info=exc)
    return _envelope(500, InternalError.code, InternalError.message)


def install_handlers(app: FastAPI) -> None:
    """Attach every envelope handler to the app.

    Args:
        app: the FastAPI application.

    Side effects:
        Registers exception handlers on `app`.
    """
    app.add_exception_handler(AppError, _app_error)
    app.add_exception_handler(RequestValidationError, _validation_error)
    app.add_exception_handler(StarletteHTTPException, _http_error)
    app.add_exception_handler(DBAPIError, _db_error)
    app.add_exception_handler(Exception, _unhandled)
