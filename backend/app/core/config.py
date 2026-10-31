from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "MediMate API"
    environment: str = "development"
    database_url: str = "sqlite:///./medimate.db"
    cors_origins: list[str] = []

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="MEDIMATE_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()

