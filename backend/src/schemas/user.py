from datetime import datetime

from pydantic import EmailStr, Field

from .base import BaseSchema

class UserBase(BaseSchema):
    email: EmailStr

class UserLogin(UserBase):
    password: str = Field(min_length=8, max_length=64)

class UserRegister(UserLogin):
    name: str = Field(min_length=1, max_length=64, json_schema_extra={"example": "John Doe"})

class UserResponse(UserBase):
    id: int
    name: str
    created_at: datetime

class UserAuthResponse(BaseSchema):
    access_token: str
    token_type: str = "Bearer"