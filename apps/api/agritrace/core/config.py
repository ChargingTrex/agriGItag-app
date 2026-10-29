"""Process settings read from environment variables (and `apps/api/.env` when present).

Serves: Arch §Backend services (twelve-factor config), D-008 (bucket names), D-009 (Redis broker URL).
Callers: `core.db`, `core.storage`, `agritrace.main`, `agritrace.worker`, `alembic/env.py`, tests.
Every variable is documented in `apps/api/.env.example`.
"""

from functools import lru_cache
from typing import Literal, Self

from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed view of the environment. Defaults target the local docker-compose stack.

    Secrets have no code defaults (fail closed): `JWT_SECRET` must come from the environment or `.env`,
    and the dev OTP bypass is off unless `OTP_DEV_CODE` is set. `.env.example` and compose set dev values.
    """

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

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
    jwt_secret: str = Field(description="HMAC secret for access tokens; required, at least 32 bytes in prod.")
    otp_dev_code: str | None = Field(
        None, description="Fixed OTP for testers outside prod (no SMS); off when unset; refused in prod."
    )

    @model_validator(mode="after")
    def _refuse_dev_secrets_in_prod(self) -> Self:
        """Stop a production process from starting with development secrets.

        Returns:
            The validated settings, unchanged.

        Raises:
            ValueError: `ENV=prod` with a `JWT_SECRET` shorter than 32 bytes or with `OTP_DEV_CODE` set.
        """
        if self.env == "prod" and (len(self.jwt_secret.encode()) < 32 or self.otp_dev_code):
            raise ValueError("ENV=prod requires JWT_SECRET of at least 32 bytes and no OTP_DEV_CODE")
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
