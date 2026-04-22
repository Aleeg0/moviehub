from fastapi import Depends
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_redis, get_db
from src.services import AuthService, MailService, UserService
from .auth import get_auth_service
from .mail import get_mail_service


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