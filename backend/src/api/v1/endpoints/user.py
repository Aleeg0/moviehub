from http import HTTPStatus

from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse

from src.core import config
from src.deps import get_user_id_http, get_user_service, get_pdf_service
from src.schemas import GetUserMoviesStatisticRequest
from src.schemas.auth import TokensResponse
from src.schemas.user import UserLogin, UserRegister, UserBase, UserVerifyResetCode, ResetPassword, \
    ResetPasswordToken, LogoutRequest, RefreshRequest, GetUserMoviesResponse, GetUserMoviesRequest, \
    GetUserMoviesStatisticResponse
from src.services import UserService, PdfService

router = APIRouter(prefix="/users")

@router.post("/login", response_model=TokensResponse, status_code=HTTPStatus.OK)
async def login(request: UserLogin, service: UserService = Depends(get_user_service)):
    return await service.login(request)

@router.post("/register", response_model=TokensResponse, status_code=HTTPStatus.OK)
async def register(request: UserRegister, service: UserService = Depends(get_user_service)):
    return await service.register(request)

@router.post("/logout", status_code=HTTPStatus.NO_CONTENT)
async def logout(
    user_id: int = Depends(get_user_id_http),
    service: UserService = Depends(get_user_service)
):
    await service.logout(LogoutRequest(user_id=user_id))

@router.post("/refresh", response_model=TokensResponse, status_code=HTTPStatus.OK)
async def refresh(request: RefreshRequest, service: UserService = Depends(get_user_service)):
    return await service.refresh(request)

@router.delete("/{user_id}", response_model=None, status_code=HTTPStatus.NO_CONTENT)
async def delete_user(user_id: int, service: UserService = Depends(get_user_service)):
    return await service.delete(user_id)

@router.get("/agreement", response_class=FileResponse)
async def get_agreement(service: PdfService = Depends(get_pdf_service)):
    return FileResponse(
        path=service.get_agreement_path(),
        media_type="application/pdf",
        filename="user_agreement.pdf",
        headers={"Cache-Control": f"public, max-age={config.pdf.cache_max_age}"}
    )

@router.post("/reset/mail", response_model=None, status_code=HTTPStatus.NO_CONTENT)
async def reset_mail(request: UserBase, service: UserService = Depends(get_user_service)):
    await service.send_reset_mail(request)

@router.post("/reset/verify", response_model=ResetPasswordToken, status_code=HTTPStatus.OK)
async def reset_verify(request: UserVerifyResetCode, service: UserService = Depends(get_user_service)):
    return await service.verify_reset_code(request)

@router.patch("/reset/password", response_model=None, status_code=HTTPStatus.NO_CONTENT)
async def reset_password(request: ResetPassword, service: UserService = Depends(get_user_service)):
    return await service.change_password(request)

@router.get("/movies", response_model=GetUserMoviesResponse, status_code=HTTPStatus.OK)
async def get_user_movies(user_id: int = Depends(get_user_id_http), service: UserService = Depends(get_user_service)):
    return await service.get_user_movies(GetUserMoviesRequest(user_id=user_id))

@router.get("/movies/statistic", response_model=GetUserMoviesStatisticResponse, status_code=HTTPStatus.OK)
async def get_user_movies_statistic(user_id: int = Depends(get_user_id_http), service: UserService = Depends(get_user_service)):
    return await service.get_user_movies_statistic(GetUserMoviesStatisticRequest(user_id=user_id))