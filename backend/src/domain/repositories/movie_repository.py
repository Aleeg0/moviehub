from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import Movie


class MovieRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def upsert(self, movie_dict: dict) -> Movie:
        stmt = insert(Movie).values(
            **movie_dict
        ).on_conflict_do_update(
            index_elements=["external_id"],
            set_={
                k: v for k, v in movie_dict.items() if k != "external_id"
            }
        ).returning(Movie)

        result = await self._session.scalar(stmt)
        await self._session.refresh(result)
        return result

    async def get_by_id(self, movie_id: int) -> Movie | None:
        stmt = (
            select(Movie)
            .where(Movie.id == movie_id)
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()