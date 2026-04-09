from fastapi_mail import FastMail, MessageSchema, MessageType
from pydantic import EmailStr

from src.core import config


class MailService:
    def __init__(self, fastmail: FastMail):
        self.fastmail = fastmail

    async def send_reset_mail(self, email: EmailStr, reset_code: str):
        print(config.mail.get_connection_config)

        message = MessageSchema(
            recipients=[email],
            subject='Reset Email',
            template_body={ "code": reset_code },
            subtype=MessageType.html
        )

        await self.fastmail.send_message(message=message, template_name='reset_password.html')