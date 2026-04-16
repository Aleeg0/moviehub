import secrets

from redis.asyncio import Redis
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.enums import RedisKeys
from src.core.errors import ResourceAlreadyExistsError, InvalidCredentialsError, ResourceNotFoundError, \
    UnauthorizedError
from src.domain.models import User
from src.schemas.auth import TokensResponse
from src.schemas.user import UserLogin, UserRegister, UserVerifyResetCode, ResetPasswordToken, UserBase, ResetPassword, \
    LogoutRequest, RefreshRequest
from .auth_service import AuthService
from .mail_service import MailService


class UserService:
    def __init__(
        self,
        session: AsyncSession,
        mail_service: MailService,
        auth_service: AuthService,
        redis: Redis
    ):
        self.session = session
        self.mail_service = mail_service
        self.auth_service = auth_service
        self.redis = redis


    async def register(self, payload: UserRegister) -> TokensResponse:
        hashed_password = self.auth_service.get_password_hash(payload.password)

        user: User = User(
            email=payload.email,
            hashed_password=hashed_password,
            name=payload.name,
        )

        try:
            self.session.add(user)
            await self.session.flush()
            await self.session.refresh(user)
        except IntegrityError as e:
            await self.session.rollback()
            raise ResourceAlreadyExistsError(f"{User.__name__} already exists") from e

        await self.session.commit()

        tokens = self.auth_service.generate_tokens(user.id)
        await self.auth_service.save_token(user.id, tokens.refresh_token)

        return tokens


    async def login(self, payload: UserLogin) -> TokensResponse:
        result = await self.session.execute(select(User).where(User.email == payload.email))

        user = result.scalar_one_or_none()

        if not user:
            raise InvalidCredentialsError("Incorrect email or password")

        if not self.auth_service.verify_password(payload.password, user.hashed_password):
            raise InvalidCredentialsError("Incorrect email or password")

        tokens = self.auth_service.generate_tokens(user.id)
        await self.auth_service.save_token(user.id, tokens.refresh_token)

        return tokens


    async def logout(self, payload: LogoutRequest) -> None:
        await self.auth_service.revoke_token(payload.user_id)

    async def refresh(self, payload: RefreshRequest) -> TokensResponse:
        user_id = await self.auth_service.validate_refresh_token(payload.refresh_token)
        if not user_id:
            raise UnauthorizedError("User unauthorized")

        tokens = self.auth_service.generate_tokens(user_id)
        await self.auth_service.save_token(user_id, tokens.refresh_token)

        return tokens


    async def send_reset_mail(self, payload: UserBase) -> None:
        result = await self.session.execute(select(User).where(User.email == payload.email))
        user = result.scalar_one_or_none()

        if not user:
            raise ResourceNotFoundError("User with email does not exist")

        reset_code = "".join(str(secrets.randbelow(10)) for _ in range(5))

        await self.mail_service.send_reset_mail(user.email, reset_code)

        await self.redis.set(
            name=RedisKeys.USER_RESET_CODE.format(email=payload.email),
            value=reset_code,
            ex=3600
        )


    async def verify_reset_code(self, payload: UserVerifyResetCode) -> ResetPasswordToken:
        reset_code_key = RedisKeys.USER_RESET_CODE.format(email=payload.email)
        code = await self.redis.get(reset_code_key)
        if not code:
            raise InvalidCredentialsError("Reset code expired or not found")

        if payload.code != code:
            raise InvalidCredentialsError("Invalid reset code")

        await self.redis.delete(reset_code_key)

        reset_token = secrets.token_urlsafe(32)

        await self.redis.set(
            name=RedisKeys.USER_RESET_TOKEN.format(email=payload.email),
            value=reset_token,
            ex=900
        )

        return ResetPasswordToken(reset_token=reset_token)


    async def change_password(self, payload: ResetPassword) -> None:
        token_key = RedisKeys.USER_RESET_TOKEN.format(email=payload.email)
        token = await self.redis.get(token_key)

        if not token:
            raise InvalidCredentialsError("Reset token expired or not found")

        if payload.reset_token != token:
            raise InvalidCredentialsError("Invalid reset token")

        result = await self.session.execute(select(User).where(User.email == payload.email))
        user = result.scalar_one_or_none()

        if not user:
            raise ResourceNotFoundError("User no longer exists")

        user.hashed_password = self.auth_service.get_password_hash(payload.new_password)
        await self.session.commit()

        await self.redis.delete(token_key)

        return None


    async def delete(self, user_id: int) -> None:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        await self.session.delete(user)
        await self.session.commit()