from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.services import UserService

def get_user_service(
    session: AsyncSession = Depends(get_db),
) -> UserService:
    return UserService(session)
