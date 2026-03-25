from sqlalchemy.ext.asyncio import AsyncSession

from src.deps.auth import get_password_hash
from src.domain.models import User
from src.domain.repositories import UserRepository
from src.schemas.user import UserResponse, UserCreate


class UserService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)

    async def get_one(self, entity_id: int) -> UserResponse:
        user = await self.user_repo.get_one(entity_id)
        return UserResponse.model_validate(user)

    async def create(self, user_model: UserCreate) -> UserResponse:
        hashed_password = get_password_hash(user_model.password)

        created_user: User = User(
            email=user_model.email,
            hashed_password=hashed_password,
            name=user_model.name,
        )

        await self.user_repo.create(created_user)
        await self.session.commit()

        return UserResponse.model_validate(created_user)

    async def delete(self, user_id: int) -> None:
        await self.user_repo.delete(user_id)
        await self.session.commit()