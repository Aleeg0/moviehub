from fastapi import Depends
from fastapi_mail import FastMail
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db, get_mail, get_redis
from src.services import UserService, AuthService, MailService, PdfService


def get_auth_service(session: AsyncSession = Depends(get_db)) ->AuthService:
    return AuthService(session=session)

def get_mail_service(fastmail: FastMail = Depends(get_mail)) -> MailService:
    return MailService(fastmail)

def get_user_service(
    session: AsyncSession = Depends(get_db),
    auth_service: AuthService = Depends(get_auth_service),
    mail_service: MailService = Depends(get_mail_service),
    redis: Redis = Depends(get_redis)
) -> UserService:
    return UserService(
        session=session,
        auth_service=auth_service,
        mail_service=mail_service,
        redis=redis
    )

def get_pdf_service() -> PdfService:
    return PdfService()
