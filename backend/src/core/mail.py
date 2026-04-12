from fastapi_mail import FastMail

from .configs import config

fastmail_client: FastMail | None = None

def init_mail():
    global fastmail_client
    fastmail_client = FastMail(config.mail.get_connection_config)

def get_mail() -> FastMail:
    return fastmail_client