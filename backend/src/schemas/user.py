from datetime import date

from src.domain.models import UserMovieStatus
from .base import BaseSchema


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