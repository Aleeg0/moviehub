from fastapi import APIRouter, Depends
from starlette import status
from starlette.responses import FileResponse

from src.core import config
from src.schemas import LoginRequest, TokensResponse, RegisterRequest, LogoutRequest, RefreshRequest, \
    SendResetMailRequest, VerifyResetCodeRequest, VerifyResetCodeResponse, ChangePasswordRequest, LoginResponse
from src.services import AuthService, PdfService
from src.services.deps import get_auth_service, get_pdf_service
from ..deps import get_user_id_http

router = APIRouter(prefix="/auth")

@router.post(
    "/login",
    response_model=LoginResponse,
    status_code=status.HTTP_200_OK
)
async def login(request: LoginRequest, service: AuthService = Depends(get_auth_service)):
    return await service.login(request)

@router.post(
    "/register",
    response_model=TokensResponse,
    status_code=status.HTTP_201_CREATED
)
async def register(request: RegisterRequest, service: AuthService = Depends(get_auth_service)):
    return await service.register(request)

@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT
)
async def logout(
    user_id: int = Depends(get_user_id_http),
    service: AuthService = Depends(get_auth_service)
):
    await service.logout(LogoutRequest(user_id=user_id))

@router.post(
    "/refresh",
    response_model=TokensResponse,
    status_code=status.HTTP_200_OK
)
async def refresh(
    request: RefreshRequest,
    service: AuthService = Depends(get_auth_service)
):
    return await service.refresh(request)

@router.post(
    "/reset/mail",
    status_code=status.HTTP_204_NO_CONTENT
)
async def reset_mail(
    request: SendResetMailRequest,
    service: AuthService = Depends(get_auth_service)
):
    await service.send_reset_mail(request)

@router.post(
    "/reset/verify",
    response_model=VerifyResetCodeResponse,
    status_code=status.HTTP_200_OK
)
async def reset_verify(
    request: VerifyResetCodeRequest,
    service: AuthService = Depends(get_auth_service)
):
    return await service.verify_reset_code(request)

@router.patch(
    "/reset/password",
    status_code=status.HTTP_204_NO_CONTENT
)
async def reset_password(
    request: ChangePasswordRequest,
    service: AuthService = Depends(get_auth_service)
):
    return await service.change_password(request)

@router.get(
    "/agreement",
    response_class=FileResponse
)
async def get_agreement(service: PdfService = Depends(get_pdf_service)):
    return FileResponse(
        path=service.get_agreement_path(),
        media_type="application/pdf",
        filename="user_agreement.pdf",
        headers={"Cache-Control": f"public, max-age={config.pdf.cache_max_age}"}
    )

