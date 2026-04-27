from datetime import date, datetime
from typing import Annotated

from pydantic import Field

from src.domain.models import UserMovieStatus
from .base import BaseSchema

Rating = Annotated[int, Field(ge=0, le=5)]
Comment = Annotated[str, Field(min_length=1, max_length=120)]

# Request
class PatchUserMovieRatingBody(BaseSchema):
    rating: Rating
    comment: Comment | None = None

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
    created_at: datetime

class GetUserMoviesResponse(BaseSchema):
    movies: list[GetUserMovieResponse]

class GetUserMoviesStatisticRequest(BaseSchema):
    user_id: int

class GetUserMoviesStatisticResponse(BaseSchema):
    liked: int
    disliked: int
    viewed: int

class UpdateUserMovieRatingRequest(BaseSchema):
    user_id: int
    movie_id: int
    rating: Rating
    comment: Comment | None = None

class UpdateUserMovieRatingResponse(BaseSchema):
    user_id: int
    movie_id: int
    status: UserMovieStatus
    rating: Rating
    created_at: datetime
    comment: Comment | None = None