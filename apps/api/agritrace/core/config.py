"""Process settings read from environment variables (and `apps/api/.env` when present).

Serves: Arch §Backend services (twelve-factor config), D-008 (bucket names), D-009 (Redis broker URL),
D-024 (JWT secret, OTP dev code and daily cap, absolute session lifetime B23), FR7 (SMS provider, B04),
plan §13 E3 (CDN, B10).
Callers: `core.db`, `core.storage`, `core.auth`, identity service (B02), notifications providers (B04),
`agritrace.main`, `agritrace.worker`, `alembic/env.py`, tests.
Every variable is documented in `apps/api/.env.example`.
"""

from functools import lru_cache
from typing import Literal, Self

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed view of the environment. Defaults target the local docker-compose stack.

    Secrets have no code defaults (fail closed): `JWT_SECRET` must come from the environment or `.env`,
    and the dev OTP bypass is off unless `OTP_DEV_CODE` is set. `.env.example` and compose set dev values.
    """

    # hide_input_in_errors: validation errors (and the logs that carry them) never echo secrets or the DSN.
    model_config = SettingsConfigDict(env_file=".env", extra="ignore", hide_input_in_errors=True)

    env: Literal["dev", "test", "prod"] = Field("dev", description="Deployment environment name.")
    database_url: str = Field(
        "postgresql+asyncpg://agritrace:agritrace@localhost:5432/agritrace",
        description="SQLAlchemy async URL for Postgres 16 + PostGIS (asyncpg driver).",
    )
    redis_url: str = Field("redis://localhost:6379/0", description="Redis URL; Celery broker and cache.")
    s3_endpoint: str = Field(
        "http://localhost:4566", description="S3 API endpoint the API and worker call (LocalStack or AWS)."
    )
    s3_public_endpoint: str = Field(
        "http://localhost:4566", description="S3 endpoint phones and browsers reach; presigned URLs use it."
    )
    s3_region: str = Field("ap-south-1", description="S3 region used for signing.")
    s3_access_key: str = Field("test", description="S3 access key id.")
    s3_secret_key: str = Field("test", description="S3 secret access key.")
    s3_bucket_evidence: str = Field("evidence", description="Write-once evidence photo bucket (object lock).")
    s3_bucket_public: str = Field("public-pages", description="Anonymous-read bucket for built public pages.")
    s3_bucket_iddocs: str = Field("id-docs", description="Private bucket for farmer identity documents.")
    public_base_url: str = Field(
        "http://localhost:4566/public-pages", description="Base URL consumers open for a public batch page."
    )
    cloudfront_distribution_id: str | None = Field(
        None,
        description="CDN in front of public-pages; a build invalidates `/b/<code>*` there (plan §13 E3). "
        "Unset locally: no invalidation.",
    )
    jwt_secret: str = Field(description="HMAC secret for access tokens; required, at least 32 bytes in prod.")
    otp_dev_code: str | None = Field(
        None, description="Fixed OTP for testers outside prod (no SMS); off when unset; refused in prod."
    )

    otp_daily_cap: int = Field(
        10, ge=1, description="Most OTP codes one phone may request in any 24 hours (SMS cost and guessing)."
    )
    session_max_days: int = Field(
        30,
        ge=1,
        description="Days after a device's OTP/PIN sign-in when its refresh is refused and the device signed "
        "out, so the user signs in again (`session_expired`; ASVS 3.3.2 L1 wants at most 30; D-024).",
    )
    # TODO(provider): add the real gateway's name to this Literal; until then ENV=prod cannot start.
    sms_provider: Literal["console"] | None = Field(
        None,
        description="SMS gateway: `console` logs messages without sending (dev); unset fails every SMS with "
        "`provider_not_configured`. ENV=prod refuses both (no real gateway yet).",
    )
    sms_sender_id: str | None = Field(
        None, description="DLT-registered 6-letter SMS sender id (header), used by the real SMS gateway."
    )

    @field_validator("otp_dev_code")
    @classmethod
    def _empty_otp_is_off(cls, value: str | None) -> str | None:
        """Give "off" a single representation: an empty `OTP_DEV_CODE` becomes None.

        Args:
            value: the raw setting.

        Returns:
            The code, or None when unset or empty (so an empty submitted OTP can never match).
        """
        return value or None

    @model_validator(mode="after")
    def _refuse_dev_secrets_in_prod(self) -> Self:
        """Stop a production process from starting with development secrets.

        Returns:
            The validated settings, unchanged.

        Raises:
            ValueError: `ENV=prod` with a `JWT_SECRET` shorter than 32 bytes, with `OTP_DEV_CODE` set, or
                without a real SMS gateway (`SMS_PROVIDER` unset or `console`: OTPs would never arrive).
        """
        if self.env != "prod":
            return self
        if len(self.jwt_secret.encode()) < 32 or self.otp_dev_code:
            raise ValueError("ENV=prod requires JWT_SECRET of at least 32 bytes and no OTP_DEV_CODE")
        if self.sms_provider in (None, "console"):
            raise ValueError("ENV=prod requires a real SMS_PROVIDER (unset or `console` sends no OTP SMS)")
        return self


@lru_cache
def get_settings() -> Settings:
    """Build the settings once per process.

    Returns:
        The cached `Settings`. Tests call `get_settings.cache_clear()` after changing the environment.

    Raises:
        pydantic.ValidationError: `JWT_SECRET` is missing or a variable has an invalid value.
    """
    return Settings()
