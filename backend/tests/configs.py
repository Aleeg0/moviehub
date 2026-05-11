from pathlib import Path

from pydantic_settings import SettingsConfigDict

from src.core.configs import DatabaseConfig

ROOT_DIR = Path(__file__).resolve().parent.parent.parent

class TestDatabaseConfig(DatabaseConfig):
    model_config = SettingsConfigDict(
        env_prefix="database_",
        env_file=str(ROOT_DIR / ".env.test"),
        extra="ignore"
    )

test_db_config = TestDatabaseConfig()