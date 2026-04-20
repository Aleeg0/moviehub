from datetime import date

from src.schemas.base import BaseSchema


# Service
class UpsertMovieRequest(BaseSchema):
    external_id: int
    title: str
    poster_path: str
    release_date: date
    vote_average: float
    genre_id: int | None = None

class MovieResponse(BaseSchema):
    id: int
    external_id: int
    title: str
    poster_path: str
    release_date: date
    vote_average: float
    genre_id: int | None = None
