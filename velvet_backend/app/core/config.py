from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # App
    APP_NAME: str = "VelvetHub"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://velvet:velvet@localhost:5432/velvetdb"

    # Telegram
    BOT_TOKEN: str = ""  # Set via env
    BOT_USERNAME: str = "RedVelvetOfficial_bot"

    # JWT / Session
    SECRET_KEY: str = "change-me-in-production-ourvelvet-dsn-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Crypto / Payments (placeholders)
    OV_CONTRACT: str = ""          # $OV token contract
    WEB3_RPC: str = ""
    PRIMARY_CURRENCY: str = "OV"   # $OV come moneta primaria

    # AI / AGI (external service)
    AGI_API_URL: str = ""
    AGI_API_KEY: str = ""

    class Config:
        env_file = ".env"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
