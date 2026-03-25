from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors.errors import ResourceNotFoundError, ResourceAlreadyExistsError
from src.domain.models import User


class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_one(self, entity_id: int) -> User:
        result = await self.session.execute(
            select(User).where(User.id == entity_id))

        entity = result.scalar_one_or_none()

        if not entity:
            raise ResourceNotFoundError(f"{User.__name__} with id {entity_id} not found")

        return entity


    async def create(self, user: User) -> User:
        try:
            self.session.add(user)
            await self.session.flush()
            await self.session.refresh(user)
        except IntegrityError as e:
            await self.session.rollback()
            raise ResourceAlreadyExistsError(f"{User.__name__} already exists") from e
        return user

    async def delete(self, user_id: int):
        deleted_user = await self.get_one(user_id)
        await self.session.delete(deleted_user)
        await self.session.flush()