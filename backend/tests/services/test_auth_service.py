from datetime import datetime
from unittest.mock import AsyncMock, MagicMock

import pytest

from src.core.errors import ResourceAlreadyExistsError, InvalidCredentialsError, UnauthorizedError, \
    ResourceNotFoundError
from src.domain.models import User, RefreshToken
from src.schemas import RegisterRequest, LoginRequest, LogoutRequest, RefreshRequest, SendResetMailRequest, \
    VerifyResetCodeRequest, ChangePasswordRequest
from src.services import AuthService


class TestAuthService:
    @pytest.fixture
    def mail_service(self):
        return AsyncMock()

    @pytest.fixture
    def auth_service(self, uow, token_repo, user_repo, mail_service, redis):
        return AuthService(
            uow=uow,
            toke_repo=token_repo,
            user_repo=user_repo,
            mail_service=mail_service,
            redis=redis,
        )

    @pytest.fixture
    def user(
        self,
        auth_service: AuthService,
    ) -> User:
        return  User(
            id=1,
            email="new@test.com",
            hashed_password=auth_service._get_password_hash("password"),
            name="Name",
            created_at=datetime.now(),
        )

    async def test_register_raises_if_user_already_exists(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
    ) -> None:
        user_repo.get_by_email.return_value = User(
            email="exists@test.com", hashed_password="hash", name="Name"
        )
        with pytest.raises(ResourceAlreadyExistsError):
            await auth_service.register(
                RegisterRequest(
                    email="exists@test.com",
                    password="password",
                    name="Name",
                )
            )

    async def test_register_creates_user_and_returns_tokens(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
        token_repo: AsyncMock,
        uow: MagicMock,
        user: User
    ) -> None:
        user_repo.get_by_email.return_value = None
        user_repo.create.return_value = user
        result = await auth_service.register(
            RegisterRequest(
                email=user.email,
                password="password",
                name=user.name,
            )
        )
        assert result.access_token is not None
        assert result.refresh_token is not None
        user_repo.create.assert_called_once()
        token_repo.upsert.assert_called_once()
        uow.commit.assert_called_once()

    async def test_login_raises_if_user_not_found(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
    ) -> None:
        user_repo.get_by_email.return_value = None
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.login(
                LoginRequest(
                    email="mail@test.com",
                    password="password"
                )
            )
        assert str(exc_info.value) == "Incorrect email"

    async def test_login_raises_if_password_incorrect(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
        user: User
    ) -> None:
        user_password = "password"
        user.hashed_password = auth_service._get_password_hash(user_password)
        user_repo.get_by_email.return_value = user
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.login(
                LoginRequest(
                    email="mail@test.com",
                    password=user_password + "incorrectPart"
                )
            )

        assert str(exc_info.value) == "Incorrect password"

    async def test_login_returns_tokens_and_user_info(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
        token_repo: AsyncMock,
        uow: MagicMock,
        user: User
    ) -> None:
        user_password = "password"
        user.hashed_password = auth_service._get_password_hash(user_password)
        user_repo.get_by_email.return_value = user
        result = await auth_service.login(
            LoginRequest(
                email=user.email,
                password=user_password
            )
        )
        assert result.access_token is not None
        assert result.refresh_token is not None
        assert result.name == user.name
        assert result.email == user.email
        token_repo.upsert.assert_called_once()
        uow.commit.assert_called_once()

    async def test_logout_deletes_token(
        self,
        auth_service: AuthService,
        token_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        await auth_service.logout(
            LogoutRequest(
                user_id=1
            )
        )
        token_repo.delete_by_user_id.assert_called_once_with(1)
        uow.commit.assert_called_once()

    async def test_refresh_raises_if_token_invalid(
        self,
        auth_service: AuthService,
    ) -> None:
        with pytest.raises(UnauthorizedError):
            await auth_service.refresh(
                RefreshRequest(
                    refresh_token="invalid_token"
                )
            )

    async def test_refresh_raises_if_token_not_match_stored(
        self,
        auth_service: AuthService,
        token_repo: AsyncMock,
    ) -> None:
        tokens = auth_service._generate_tokens(1)
        token_repo.get_by_user_id.return_value = RefreshToken(token="other_token", user_id=1)

        with pytest.raises(UnauthorizedError):
            await auth_service.refresh(
                RefreshRequest(
                    refresh_token=tokens.refresh_token
                )
            )

    async def test_refresh_returns_new_tokens(
        self,
        auth_service: AuthService,
        token_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        tokens = auth_service._generate_tokens(1)
        token_repo.get_by_user_id.return_value = RefreshToken(
            token=tokens.refresh_token, user_id=1
        )

        result = await auth_service.refresh(
            RefreshRequest(
                refresh_token=tokens.refresh_token
            )
        )
        assert result.access_token is not None
        assert result.refresh_token is not None
        token_repo.upsert.assert_called_once()
        uow.commit.assert_called_once()

    async def test_send_reset_mail_raises_if_user_not_found(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
    ) -> None:
        user_repo.get_by_email.return_value = None
        with pytest.raises(ResourceNotFoundError):
            await auth_service.send_reset_mail(
                SendResetMailRequest(
                    email="ghost@test.com"
                )
            )

    async def test_send_reset_mail_sends_mail_and_saves_code_to_redis(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
        mail_service: AsyncMock,
        redis: AsyncMock,
        user: User,
    ) -> None:
        user_repo.get_by_email.return_value = user
        await auth_service.send_reset_mail(
            SendResetMailRequest(
                email=user.email
            )
        )
        mail_service.send_reset_mail.assert_called_once()
        redis.set.assert_called_once()

    async def test_verify_reset_code_raises_if_code_not_found_in_redis(
        self,
        auth_service: AuthService,
        redis: AsyncMock,
    ) -> None:
        redis.get.return_value = None
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.verify_reset_code(
                VerifyResetCodeRequest(
                    email="random@test.com",
                    code="12345"
                )
            )
        assert str(exc_info.value) == "Reset code expired or not found"

    async def test_verify_reset_code_raises_if_code_incorrect(
        self,
        auth_service: AuthService,
        redis: AsyncMock,
    ) -> None:
        redis.get.return_value = "54321"
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.verify_reset_code(
                VerifyResetCodeRequest(
                    email="random@test.com",
                    code="12345"
                )
            )
        assert str(exc_info.value) == "Invalid reset code"

    async def test_verify_reset_code_returns_reset_token(
        self,
        auth_service: AuthService,
        redis: AsyncMock,
    ) -> None:
        redis.get.return_value = "12345"
        result = await auth_service.verify_reset_code(
            VerifyResetCodeRequest(
                email="random@test.com",
                code="12345"
            )
        )
        assert result.reset_token is not None
        redis.delete.assert_called_once()
        redis.set.assert_called_once()

    async def test_change_password_raises_if_reset_token_not_found(
        self,
        auth_service: AuthService,
        redis: AsyncMock,
    ) -> None:
        redis.get.return_value = None
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.change_password(
                ChangePasswordRequest(
                    email="test@test.com",
                    reset_token="token",
                    new_password="new_password"
                )
            )
        assert str(exc_info.value) == "Reset token expired or not found"

    async def test_change_password_raises_if_reset_token_invalid(
        self,
        auth_service: AuthService,
        redis: AsyncMock,
    ) -> None:
        redis.get.return_value = "valid_token"
        with pytest.raises(InvalidCredentialsError) as exc_info:
            await auth_service.change_password(
                ChangePasswordRequest(
                    email="test@test.com",
                    reset_token="wrong_token",
                    new_password="new_password"
                )
            )
        assert str(exc_info.value) == "Invalid reset token"

    async def test_change_password_updates_password_and_deletes_token(
        self,
        auth_service: AuthService,
        user_repo: AsyncMock,
        redis: AsyncMock,
        uow: MagicMock,
    ) -> None:
        redis.get.return_value = "valid_token"
        await auth_service.change_password(
            ChangePasswordRequest(
                email="test@test.com",
                reset_token="valid_token",
                new_password="new_pass"
            )
        )
        user_repo.update_password.assert_called_once()
        redis.delete.assert_called_once()
        uow.commit.assert_called_once()
