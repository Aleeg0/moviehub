from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.core.errors import UnauthorizedError
from src.services import AuthService

security = HTTPBearer()

def get_auth_service(session: AsyncSession = Depends(get_db)) -> AuthService:
    return AuthService(session=session)

async def get_user_id_http(
    authorization: HTTPAuthorizationCredentials = Depends(security),
    auth_service: AuthService = Depends(get_auth_service)
) -> int:
    user_id = await auth_service.validate_access_token(authorization.credentials)
    if not user_id:
        raise UnauthorizedError("User unauthorized")
    return user_id

async def get_user_id_ws(
    token: str,
    auth_service: AuthService = Depends(get_auth_service),
) -> int:
    user_id = await auth_service.validate_refresh_token(token)
    if not user_id:
        raise UnauthorizedError("User unauthorized")
    return user_id