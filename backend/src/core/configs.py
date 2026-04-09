from pathlib import Path

from fastapi_mail import ConnectionConfig
from pydantic import Field, SecretStr
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

class RedisConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='redis_')

    host: str = Field(default="localhost")
    port: int = Field(default=6379)
    password: str = Field(default="")
    db: str = Field(default="0")

    @property
    def get_connection_url(self) -> str:
        return f"redis://:{self.password}@{self.host}:{self.port}/{self.db}"

PROJECT_PATH = Path(__file__).resolve().parent.parent.parent

class PdfConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='pdf_')

    path: str = Field(default="")
    cache_max_age: int = Field(default=3600)
    agreement_name: str = Field(default="")

    @property
    def get_pdf_path(self):
        test = (PROJECT_PATH / self.path).resolve()
        return test

class MailConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='mail_')

    port: int = Field(default=587)
    server: str = Field(default="smtp.gmail.com")
    username: str = Field(default="")
    from_mail: str = Field(default="")
    starttls: bool = Field(default=True)
    ssl_tls: bool = Field(default=False)
    use_credentials: bool = Field(default=False)
    validate_certs: bool = Field(default=False)
    template_folder: str = Field(default="")
    password: SecretStr = Field(default="")

    @property
    def get_connection_config(self):
        template_folder = (PROJECT_PATH / self.template_folder).resolve()

        return ConnectionConfig(
            MAIL_USERNAME=self.username,
            MAIL_PASSWORD=self.password,
            MAIL_FROM=self.from_mail,
            MAIL_PORT=self.port,
            MAIL_SERVER=self.server,
            MAIL_STARTTLS=self.starttls,
            MAIL_SSL_TLS=self.ssl_tls,
            USE_CREDENTIALS=self.use_credentials,
            VALIDATE_CERTS=self.validate_certs,
            TEMPLATE_FOLDER=template_folder
        )

class Config(BaseSettings):
    debug: bool = Field(default=False)
    cors: str = Field(default="*")

    database: DatabaseConfig = DatabaseConfig()
    redis: RedisConfig = RedisConfig()
    auth: AuthConfig = AuthConfig()
    pdf: PdfConfig = PdfConfig()
    mail: MailConfig = MailConfig()

config = Config()