from datetime import datetime, date

from pydantic import EmailStr, Field

from src.domain.models import UserMovieStatus
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

class LogoutRequest(BaseSchema):
    user_id: int

class RefreshRequest(BaseSchema):
    refresh_token: str

class UserAuthResponse(BaseSchema):
    access_token: str

class UserResetPassword(UserBase):
    pass

class UserVerifyResetCode(UserBase):
    code: str

class ResetPasswordToken(BaseSchema):
    reset_token: str

class ResetPassword(UserBase, ResetPasswordToken):
    new_password: str = Field(min_length=8, max_length=64)

# Service
class CreateUserMovieRequest(BaseSchema):
    user_id: int
    movie_id: int
    status: UserMovieStatus

class CreateUserMovieResponse(CreateUserMovieRequest):
    pass

class GetUserMoviesRequest(BaseSchema):
    user_id: int

class GetUserMovieResponse(BaseSchema):
    id: int
    external_id: int
    title: str
    poster_path: str
    release_date: date
    vote_average: float
    genre_id: int | None = None
    status: UserMovieStatus

class GetUserMoviesResponse(BaseSchema):
    movies: list[GetUserMovieResponse]

class GetUserMoviesStatisticRequest(BaseSchema):
    user_id: int

class GetUserMoviesStatisticResponse(BaseSchema):
    liked: int
    disliked: int
    viewed: int