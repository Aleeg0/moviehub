import pytest_asyncio

from src.domain.models import User, RefreshToken
from src.domain.repositories import TokenRepository, UserRepository


class TestTokenRepository:
    @pytest_asyncio.fixture
    async def existing_user(self, user_repo: UserRepository) -> User:
        user = User(email="tokenuser@test.com", hashed_password="hash", name="Name")
        result = await user_repo.create(user)
        return result

    @pytest_asyncio.fixture
    async def existing_token(self, token_repo: TokenRepository, existing_user: User) -> RefreshToken:
        return await token_repo.upsert(token="test_token", user_id=existing_user.id)

    async def test_upsert_creates_token_if_not_exists(
        self,
        token_repo: TokenRepository,
        existing_user: User,
    ) -> None:
        token_value = "brand_new_token"
        new_token = await token_repo.upsert(token=token_value, user_id=existing_user.id)
        assert new_token is not None
        assert new_token.user_id == existing_user.id
        assert new_token.token == token_value

    async def test_upsert_updates_token_if_already_exists(
        self,
        token_repo: TokenRepository,
        existing_token: RefreshToken,
    ) -> None:
        token_value = "brand_new_token"
        new_token = await token_repo.upsert(token=token_value, user_id=existing_token.user_id)
        assert new_token.user_id == existing_token.user_id
        assert new_token.token == token_value

    async def test_upsert_does_not_create_duplicate_for_same_user(
        self,
        token_repo: TokenRepository,
        existing_user: User,
    ) -> None:
        await token_repo.upsert(token="token_v1", user_id=existing_user.id)
        await token_repo.upsert(token="token_v2", user_id=existing_user.id)

        result = await token_repo.get_by_user_id(existing_user.id)
        assert result.token == "token_v2"

    async def test_get_by_user_id_returns_token(
        self,
        token_repo: TokenRepository,
        existing_token: RefreshToken,
    ) -> None:
        result = await token_repo.get_by_user_id(existing_token.user_id)
        assert result is not None
        assert result.id == existing_token.id

    async def test_get_by_user_id_returns_none_if_not_found(
        self,
        token_repo: TokenRepository,
    ) -> None:
        non_existed_user_id = 9999
        result = await token_repo.get_by_user_id(user_id=non_existed_user_id)
        assert result is None

    async def test_delete_by_user_id_removes_token(
        self,
        token_repo: TokenRepository,
        existing_token: RefreshToken,
    ) -> None:
        await token_repo.delete_by_user_id(user_id=existing_token.user_id)
        result = await token_repo.get_by_user_id(user_id=existing_token.user_id)
        assert result is None

    async def test_delete_by_user_id_returns_true(
        self,
        token_repo: TokenRepository,
        existing_token: RefreshToken,
    ) -> None:
        result = await token_repo.delete_by_user_id(user_id=existing_token.user_id)
        assert result is True

    async def test_delete_by_user_id_does_not_affect_other_users_tokens(
        self,
        token_repo: TokenRepository,
        user_repo: UserRepository,
    ) -> None:
        user1 = await user_repo.create(User(email="u1@test.com", hashed_password="h1", name="U1"))
        user2 = await user_repo.create(User(email="u2@test.com", hashed_password="h2", name="U2"))

        await token_repo.upsert(token="token1", user_id=user1.id)
        user2_token = "token2"
        await token_repo.upsert(token=user2_token, user_id=user2.id)

        await token_repo.delete_by_user_id(user1.id)
        untouched_token = await token_repo.get_by_user_id(user2.id)

        assert untouched_token is not None
        assert untouched_token.token == user2_token
