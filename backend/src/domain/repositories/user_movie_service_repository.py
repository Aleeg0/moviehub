from typing import cast

from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import UserMovieService


class UserMovieServiceRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_user_movie_services_by_id(self, user_id: int) -> list[UserMovieService]:
        stmt = select(UserMovieService).where(UserMovieService.user_id == user_id)
        result = await self.session.scalars(stmt)
        return cast(list[UserMovieService], result.all())

    async def upsert_user_movie_services(self, user_id: int, movie_service_ids: list[int]) -> None:
        current_user_movie_services = await self.get_user_movie_services_by_id(user_id)

        stmt = (
            delete(UserMovieService)
            .where(
                UserMovieService.user_id == user_id,
                UserMovieService.movie_service_id.notin_(movie_service_ids)
            )
        )
        await self.session.execute(stmt)
        to_add_ids = set(movie_service_ids) - {
            user_movie_service.movie_service_id for user_movie_service in current_user_movie_services
        }
        new_user_movie_services = [
            UserMovieService(
                user_id=user_id,
                movie_service_id=movie_service_id
            )
            for movie_service_id in to_add_ids
        ]
        self.session.add_all(new_user_movie_services)
        await self.session.flush()