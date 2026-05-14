from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import ResourceAlreadyExistsError
from src.domain.models import User


class UserRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, user: User) -> User:
        try:
            self._session.add(user)
            await self._session.flush()
            await self._session.refresh(user)
        except IntegrityError as e:
            raise ResourceAlreadyExistsError(f"{User.__name__} already exists") from e
        return user

    async def update_password(self, email: str, new_password: str) -> None:
        stmt = (
            update(User)
            .where(User.email == email)
            .values(
                hashed_password=new_password
            )
        )
        await self._session.execute(stmt)
        await self._session.flush()