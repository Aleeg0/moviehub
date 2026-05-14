from pydantic import Field, EmailStr

from src.schemas.base import BaseSchema


# Services
class TokensResponse(BaseSchema):
    access_token: str
    refresh_token: str

class LoginRequest(BaseSchema):
    email: EmailStr
    password: str = Field(min_length=8, max_length=64)

class LoginResponse(TokensResponse):
    name: str
    email: str

class RegisterRequest(LoginRequest):
    name: str = Field(min_length=1, max_length=64)

class LogoutRequest(BaseSchema):
    user_id: int

class RefreshRequest(BaseSchema):
    refresh_token: str

class SendResetMailRequest(BaseSchema):
    email: EmailStr

class VerifyResetCodeRequest(SendResetMailRequest):
    code: str = Field(min_length=5, max_length=5)

class VerifyResetCodeResponse(BaseSchema):
    reset_token: str

class ChangePasswordRequest(SendResetMailRequest, VerifyResetCodeResponse):
    new_password: str = Field(min_length=8, max_length=64)