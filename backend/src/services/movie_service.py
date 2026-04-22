from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import Movie
from src.schemas import UpsertMovieRequest, MovieResponse


class MovieService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def upsert(self, movie: UpsertMovieRequest) -> MovieResponse:
        smtp = insert(Movie).values(
            external_id=movie.external_id,
            title=movie.title,
            genre_id=movie.genre_id,
            poster_path=movie.poster_path,
            release_date=movie.release_date,
            vote_average=movie.vote_average,
        )
        smtp = smtp.on_conflict_do_update(
            index_elements=["external_id"],
            set_={
                "title": movie.title,
                "genre_id": movie.genre_id,
                "poster_path": movie.poster_path,
                "release_date": movie.release_date,
                "vote_average": movie.vote_average,
            }
        ).returning(Movie)

        upsert_movie = await self.session.scalars(smtp)

        return upsert_movie.one()
