from datetime import date, datetime
from typing import Annotated

from pydantic import Field

from src.domain.models import UserMovieStatus
from .base import BaseSchema

Rating = Annotated[int, Field(ge=0, le=5)]
Comment = Annotated[str, Field(min_length=1, max_length=120)]

# Request
class PatchUserMovieRatingBody(BaseSchema):
    status: UserMovieStatus | None
    rating: Rating | None = None
    comment: Comment | None = None

# Service
class CreateUserMovieRequest(BaseSchema):
    user_id: int
    movie_id: int
    status: UserMovieStatus
    rating: Rating | None = None
    comment: Comment | None = None

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
    created_at: datetime
    rating: Rating | None = None
    comment: Comment | None = None

class GetUserMoviesResponse(BaseSchema):
    movies: list[GetUserMovieResponse]

class GetUserMoviesStatisticRequest(BaseSchema):
    user_id: int

class GetUserMoviesStatisticResponse(BaseSchema):
    liked: int
    disliked: int
    viewed: int

class UpdateUserMovieRequest(PatchUserMovieRatingBody):
    user_id: int
    movie_id: int

class UpdateUserMovieResponse(BaseSchema):
    user_id: int
    movie_id: int
    created_at: datetime
    status: UserMovieStatus
    rating: Rating | None = None
    comment: Comment | None = None

class DeleteUserMovieRequest(BaseSchema):
    user_id: int
    movie_id: int

class GetUserMovieServicesRequest(BaseSchema):
    user_id: int

class GetUserMovieServicesResponse(BaseSchema):
    movie_ids: list[int]

class UpsertUserMovieServicesBody(BaseSchema):
    movie_ids: list[int]

class UpsertUserMovieServicesRequest(UpsertUserMovieServicesBody):
    user_id: int