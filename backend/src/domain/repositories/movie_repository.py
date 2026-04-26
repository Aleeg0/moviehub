from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import Movie


class MovieRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def upsert(self, movie_dict: dict) -> Movie:
        smtp = insert(Movie).values(
            **movie_dict
        ).on_conflict_do_update(
            index_elements=["external_id"],
            set_={
                k: v for k, v in movie_dict.items() if k != "external_id"
            }
        ).returning(Movie)

        return await self._session.scalar(smtp)