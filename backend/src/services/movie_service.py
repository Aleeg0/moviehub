from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import Movie
from src.schemas import UpsertMovieRequest, UpsertMovieResponse


class MovieService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def upsert(self, request: UpsertMovieRequest) -> UpsertMovieResponse:
        smtp = insert(Movie).values(
            external_id=request.external_id,
            title=request.title,
            genre_id=request.genre_id,
            poster_path=request.poster_path,
            release_date=request.release_date,
            vote_average=request.vote_average,
        )
        smtp = smtp.on_conflict_do_update(
            index_elements=["external_id"],
            set_={
                "title": request.title,
                "genre_id": request.genre_id,
                "poster_path": request.poster_path,
                "release_date": request.release_date,
                "vote_average": request.vote_average,
            }
        ).returning(Movie)

        upsert_movie = await self.session.scalars(smtp)

        return upsert_movie.one()