from http import HTTPStatus

from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse

from src.api.v1.dep import get_user_service, get_pdf_service, get_access_token
from src.core import config
from src.schemas.auth import TokensResponse
from src.schemas.user import UserLogin, UserRegister, UserBase, UserVerifyResetCode, ResetPassword, \
    ResetPasswordToken, LogoutRequest, RefreshRequest
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
    token: str = Depends(get_access_token),
    service: UserService = Depends(get_user_service)
):
    await service.logout(LogoutRequest(access_token=token))

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