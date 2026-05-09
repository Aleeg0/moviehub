from typing import cast

from sqlalchemy import select, func, update, delete
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import ResourceAlreadyExistsError, ResourceNotFoundError
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

    async def get_user_movies_by_user_id(self, user_id: int) -> list[tuple[UserMovie, Movie]]:
        stmt = (
            select(UserMovie, Movie)
            .join(Movie, UserMovie.movie_id == Movie.id)
            .where(UserMovie.user_id == user_id)
            .order_by(UserMovie.created_at.desc())
        )

        result = await self._session.execute(stmt)

        return cast(list[tuple[UserMovie, Movie]], result.tuples().all())

    async def get_user_movie_statistics_by_user_id(self, user_id: int) -> list[tuple[UserMovieStatus, int]]:
        stmt = (
            select(UserMovie.status, func.count(UserMovie.status).label("count"))
            .where(UserMovie.user_id == user_id)
            .group_by(UserMovie.status)
        )

        result = await self._session.execute(stmt)
        return cast(list[tuple[UserMovieStatus, int]], result.tuples().all())

    async def update_user_movie(self, user_id: int, movie_id: int, updated_field: dict) -> UserMovie:
        stmt = (
            update(UserMovie)
            .where(
                UserMovie.user_id == user_id,
                UserMovie.movie_id == movie_id
            )
            .values(**updated_field)
            .returning(UserMovie)
        )
        result = await self._session.scalar(stmt)
        if result is None:
            raise ResourceNotFoundError(f"UserMovie with user_id {user_id} not found")

        await self._session.flush()
        return result

    async def delete(self, user_id: int, movie_id: int) -> None:
        user_movie = await self._session.get(UserMovie, (user_id, movie_id))

        if user_movie:
            await self._session.delete(user_movie)
            await self._session.flush()
