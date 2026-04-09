from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class AuthConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='auth_')

    secret_key: str = Field(default="")
    algorithm: str = Field(default="HS256")
    access_token_expire: int = Field(default=180)
    refresh_token_expire: int = Field(default=1800)


class DatabaseConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='database_')

    host: str = Field(default="localhost")
    port: int = Field(default=5432)
    name: str = Field(default="")
    user: str = Field(default="")
    password: str = Field(default="")

    @property
    def get_database_url(self) -> str:
        return f"postgresql+asyncpg://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"

PROJECT_PATH = Path(__file__).resolve().parent.parent.parent

class PdfConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='pdf_')

    path: str = Field(default="")
    cache_max_age: int = Field(default=3600)
    agreement_name: str = Field(default="")

    @property
    def get_pdf_path(self):
        test = (PROJECT_PATH / self.path).resolve()
        print(test)
        return test

class Config(BaseSettings):
    debug: bool = Field(default=False)
    cors: str = Field(default="*")

    database: DatabaseConfig = DatabaseConfig()
    auth: AuthConfig = AuthConfig()
    pdf: PdfConfig = PdfConfig()

config = Config()