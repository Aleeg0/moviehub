import pytest_asyncio

from src.domain.models import User
from src.domain.repositories import UserRepository, UserMovieServiceRepository


class TestUserMovieServiceRepository:
    @pytest_asyncio.fixture
    async def existing_user(self, user_repo: UserRepository) -> User:
        return await user_repo.create(
            User(email="ums_user@test.com", hashed_password="hash", name="Name")
        )

    async def test_get_by_user_id_returns_empty_list_if_no_services(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        existing_user: User
    ) -> None:
        result = await user_movie_service_repo.get_by_user_id(existing_user.id)
        assert result == []

    async def test_get_by_user_id_returns_services_for_user(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        existing_user: User,
    ) -> None:
        await user_movie_service_repo.upsert(existing_user.id, [1, 2, 3])
        result = await user_movie_service_repo.get_by_user_id(existing_user.id)
        assert len(result) == 3
        assert {r.movie_service_id for r in result} == {1, 2, 3}

    async def test_get_returns_only_own_user_services(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        user_repo: UserRepository
    ) -> None:
        user1 = await user_repo.create(User(email="user1@test.com", hashed_password="hash1", name="Name1"))
        user2 = await user_repo.create(User(email="user2@test.com", hashed_password="hash2", name="Name2"))
        await user_movie_service_repo.upsert(user1.id, [1, 2])
        await user_movie_service_repo.upsert(user2.id, [3, 4])

        result = await user_movie_service_repo.get_by_user_id(user1.id)
        assert {r.movie_service_id for r in result} == {1, 2}

    async def test_upsert_adds_new_services(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        existing_user: User,
    ) -> None:
        await user_movie_service_repo.upsert(existing_user.id, [1, 2, 3])
        result = await user_movie_service_repo.get_by_user_id(existing_user.id)
        assert {r.movie_service_id for r in result} == {1, 2, 3}

    async def test_upsert_with_empty_list_removes_all_services(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        existing_user: User,
    ) -> None:
        await user_movie_service_repo.upsert(existing_user.id, [1, 2, 3])
        await user_movie_service_repo.upsert(existing_user.id, [])
        result = await user_movie_service_repo.get_by_user_id(existing_user.id)
        assert result == []

    async def test_upsert_does_not_affect_other_users(
        self,
        user_movie_service_repo: UserMovieServiceRepository,
        user_repo: UserRepository
    ) -> None:
        user1 = await user_repo.create(User(email="user1@test.com", hashed_password="hash1", name="Name1"))
        user2 = await user_repo.create(User(email="user2@test.com", hashed_password="hash2", name="Name2"))
        await user_movie_service_repo.upsert(user1.id, [1, 2])
        await user_movie_service_repo.upsert(user2.id, [3, 4])

        await user_movie_service_repo.upsert(user1.id, [5])

        other_result = await user_movie_service_repo.get_by_user_id(user2.id)
        assert {r.movie_service_id for r in other_result} == {3, 4}