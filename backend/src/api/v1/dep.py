from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.services import UserService, AuthService, MailService


def get_auth_service(session: AsyncSession = Depends(get_db)) ->AuthService:
    return AuthService(session=session)

def get_mail_service() -> MailService:
    return MailService()

def get_user_service(
    session: AsyncSession = Depends(get_db),
    auth_service: AuthService = Depends(get_auth_service),
    mail_service: MailService = Depends(MailService)
) -> UserService:
    return UserService(
        session=session,
        auth_service=auth_service,
        mail_service=mail_service
    )
