import pytest
import pytest_asyncio

from src.core.errors import ResourceAlreadyExistsError
from src.domain.models import User
from src.domain.repositories import UserRepository


class TestUserRepository:
    @pytest_asyncio.fixture
    async def existing_user(self, user_repo: UserRepository) -> User:
        user = User(email="existing@test.com", hashed_password="hash123", name="Name")
        result = await user_repo.create(user)
        return result

    async def test_create_returns_user_with_id(
        self,
        user_repo: UserRepository
    ) -> None:
        user = User(
            email="new@test.com",
            hashed_password="hash",
            name="Name"
        )
        result = await user_repo.create(user)
        assert result.id is not None
        assert result.email == user.email

    async def test_create_raises_if_email_already_exists(
        self,
        user_repo: UserRepository,
        existing_user: User
    ) -> None:
        duplicate_user = User(email=existing_user.email, hashed_password="hash", name="Name")
        with pytest.raises(ResourceAlreadyExistsError):
            await user_repo.create(duplicate_user)

    async def test_get_by_email_returns_existing_user(
        self,
        user_repo: UserRepository,
        existing_user: User
    ) -> None:
        found_user = await user_repo.get_by_email(existing_user.email)
        assert found_user is not None
        assert found_user.id == existing_user.id

    async def test_get_by_email_returns_none_if_not_found(
        self,
        user_repo: UserRepository,
    ) -> None:
        found_user = await user_repo.get_by_email("ghost@test.com")
        assert found_user is None

    async def test_update_password_returns_updated_user_hashed_password(
        self,
        user_repo: UserRepository,
        existing_user: User
    ) -> None:
        new_hashed_password = "newHash123"
        await user_repo.update_password(existing_user.email, new_hashed_password)
        updated_user = await user_repo.get_by_email(existing_user.email)
        assert updated_user.hashed_password == new_hashed_password

    async def test_update_password_does_not_affect_other_users(
        self,
        user_repo: UserRepository,
    ):
        user1 = await user_repo.create(User(email="user1@test.com", hashed_password="hash123", name="Name1"))
        user2 = await user_repo.create(User(email="user2@test.com", hashed_password="hash223", name="Name2"))

        user1_new_hashed_password = "newHash123"
        await user_repo.update_password(user1.email, user1_new_hashed_password)

        untouched_user = await user_repo.get_by_email(user2.email)
        assert untouched_user.hashed_password != user1_new_hashed_password