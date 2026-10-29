"""Application error hierarchy, its code registry, and the handlers that render the error envelope.

Serves: CLAUDE.md §5.5 (registered snake_case codes, en/ta message key, how-to-fix line), plan §7.1
(envelope `{"error": {code, message, details}}`; 422 validation, 409 gates, 501 stubs).
Callers: every module raises `AppError` subclasses; `agritrace.main` installs `install_handlers`;
`infra/scripts/gen-error-codes.py` renders `REGISTRY` into docs/api/error-codes.md.
"""

import logging
from typing import Any, ClassVar

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger(__name__)

REGISTRY: dict[str, type["AppError"]] = {}


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


class RateLimitedError(AppError):
    """Too many requests from this caller."""

    code, status, message_key = "rate_limited", 429, "error.rate_limited"
    message = "Too many requests."
    fix = "Wait for the `Retry-After` interval, then retry with backoff."


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


def _envelope(status: int, code: str, message: str, details: Any = None) -> JSONResponse:
    """Render the standard error envelope.

    Args:
        status: HTTP status code.
        code: registered snake_case error code.
        message: human-readable English message.
        details: JSON-serialisable context, or None.

    Returns:
        `{"error": {"code", "message", "details"}}` as a JSON response.
    """
    body = {"error": {"code": code, "message": message, "details": details}}
    return JSONResponse(jsonable_encoder(body), status_code=status)


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


async def _http_error(_: Request, exc: Exception) -> JSONResponse:
    """Render Starlette HTTP errors (unknown path, wrong method) with a registered code.

    Args:
        _: the request (unused).
        exc: the `StarletteHTTPException`.

    Returns:
        Envelope using the first registered code with the same status, else `internal_error`.
    """
    assert isinstance(exc, StarletteHTTPException)
    cls = next((c for c in REGISTRY.values() if c.status == exc.status_code), InternalError)
    return _envelope(exc.status_code, cls.code, cls.message, None)


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
    app.add_exception_handler(Exception, _unhandled)
