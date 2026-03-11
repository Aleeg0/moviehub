from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='database_')

    host: str = Field(default="localhost")
    port: str = Field(default=5432)
    name: str = Field(default="")
    user: str = Field(default="")
    password: str = Field(default="")

    @property
    def get_database_url(self) -> str:
        return f"postgresql+asyncpg://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"

class Config(BaseSettings):
    debug: bool = Field(default=False)

    database: DatabaseConfig = DatabaseConfig()

config = Config()