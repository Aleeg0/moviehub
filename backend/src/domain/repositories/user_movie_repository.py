from typing import cast

from sqlalchemy import select, func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import ResourceAlreadyExistsError
from src.domain.models import UserMovie, Movie, UserMovieStatus


class UserMovieRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def create(self, user_movie: UserMovie) -> UserMovie:
        try:
            self._session.add(user_movie)
            await self._session.flush()
            await self._session.refresh(user_movie)
        except IntegrityError as e:
            raise ResourceAlreadyExistsError(f"{UserMovie.__name__} already exists") from e

        return user_movie

    async def get_user_movies_by_user_id(self, user_id: int) -> list[tuple[UserMovieStatus, Movie]]:
        stmt = (
            select(UserMovie.status, Movie)
            .join(Movie, UserMovie.movie_id == Movie.id)
            .where(UserMovie.user_id == user_id)
        )

        result = await self._session.execute(stmt)

        return cast(list[tuple[UserMovieStatus, Movie]], result.tuples().all())

    async def get_user_movie_statistics_by_user_id(self, user_id: int) -> list[tuple[UserMovieStatus, int]]:
        stmt = (
            select(UserMovie.status, func.count(UserMovie.status).label("count"))
            .where(UserMovie.user_id == user_id)
            .group_by(UserMovie.status)
        )

        result = await self._session.execute(stmt)
        return cast(list[tuple[UserMovieStatus, int]], result.tuples().all())
