from http import HTTPStatus

from fastapi import APIRouter, Depends, Response, Cookie

from src.api.v1.dep import get_user_service
from src.core import config
from src.schemas.user import UserLogin, UserAuthResponse, UserRegister
from src.services import UserService

router = APIRouter(prefix="/users")

def _set_refresh_cookie(response: Response, refresh_token: str):
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        secure=False,
        samesite="lax",
        max_age=config.auth.refresh_token_expire,
        path="/"
    )

@router.post("/login", response_model=UserAuthResponse, status_code=HTTPStatus.OK)
async def login(response: Response, request: UserLogin, service: UserService = Depends(get_user_service)):
    tokens = await service.login(request)
    _set_refresh_cookie(response, tokens.refresh_token)
    return UserAuthResponse(access_token=tokens.access_token)

@router.post("/register", response_model=UserAuthResponse, status_code=HTTPStatus.OK)
async def register(response: Response, request: UserRegister, service: UserService = Depends(get_user_service)):
    tokens = await service.register(request)
    _set_refresh_cookie(response, tokens.refresh_token)
    return UserAuthResponse(access_token=tokens.access_token)

@router.post("/logout", status_code=HTTPStatus.NO_CONTENT)
async def logout(
        response: Response,
        refresh_token: str | None = Cookie(None),
        service: UserService = Depends(get_user_service)
):
    if refresh_token:
        await service.logout(refresh_token)

    response.delete_cookie("refresh_token", path="/")

@router.delete("/{user_id}", response_model=None, status_code=HTTPStatus.NO_CONTENT)
async def delete_user(user_id: int, service: UserService = Depends(get_user_service)):
    return await service.delete(user_id)