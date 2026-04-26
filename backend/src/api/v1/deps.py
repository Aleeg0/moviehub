from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from src.core.errors import UnauthorizedError
from src.services import AuthService
from src.services.deps import get_auth_service

security = HTTPBearer()

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