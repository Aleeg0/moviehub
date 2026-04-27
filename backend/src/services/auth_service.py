import secrets
from datetime import datetime, UTC, timedelta

import bcrypt
import jwt
from redis.asyncio import Redis

from src.core import config
from src.core.enums import RedisKeys
from src.core.errors import ResourceAlreadyExistsError, InvalidCredentialsError, UnauthorizedError, \
    ResourceNotFoundError
from src.domain.models import User
from src.domain.repositories import TokenRepository, UserRepository, UnitOfWork
from src.schemas import RegisterRequest, TokensResponse, LoginRequest, LogoutRequest, RefreshRequest, \
    SendResetMailRequest, VerifyResetCodeRequest, VerifyResetCodeResponse, ChangePasswordRequest, LoginResponse
from .mail_service import MailService


class AuthService:
    def __init__(
        self,
        uow: UnitOfWork,
        toke_repo: TokenRepository,
        user_repo: UserRepository,
        mail_service: MailService,
        redis: Redis,
    ):
        self.uow = uow
        self.token_repo = toke_repo
        self.user_repo = user_repo
        self.mail_service = mail_service
        self.redis = redis

    async def register(self, request: RegisterRequest) -> TokensResponse:
        async with self.uow:
            user = await self.user_repo.get_by_email(request.email)

            if user:
                raise ResourceAlreadyExistsError("User already exists")

            user = User(
                email=request.email,
                hashed_password=self._get_password_hash(request.password),
                name=request.name,
            )
            user = await self.user_repo.create(user)

            tokens = self._generate_tokens(user.id)
            await self.token_repo.upsert(
                token=tokens.refresh_token,
                user_id=user.id)

            await self.uow.commit()

        return tokens


    async def login(self, request: LoginRequest) -> LoginResponse:
        async with self.uow:
            user = await self.user_repo.get_by_email(request.email)

            if user is None:
                raise InvalidCredentialsError("Incorrect email")

            if not self._verify_password(request.password, user.hashed_password):
                raise InvalidCredentialsError("Incorrect password")

            tokens = self._generate_tokens(user.id)
            await self.token_repo.upsert(
                token=tokens.refresh_token,
                user_id=user.id
            )
            await self.uow.commit()

        return LoginResponse(
            access_token=tokens.access_token,
            refresh_token=tokens.refresh_token,
            name=user.name,
            email=user.email
        )


    async def logout(self, request: LogoutRequest) -> None:
        async with self.uow:
            await self.token_repo.delete(request.user_id)
            await self.uow.commit()


    async def refresh(self, request: RefreshRequest) -> TokensResponse:
        async with self.uow:
            user_id = await self._validate_token(request.refresh_token, "refresh")
            if not user_id:
                raise UnauthorizedError("User unauthorized")

            user_token = await self.token_repo.get_by_user_id(user_id)
            if user_token.token != request.refresh_token:
                raise UnauthorizedError("User unauthorized")

            tokens = self._generate_tokens(user_id)
            await self.token_repo.upsert(
                token=tokens.refresh_token,
                user_id=user_id
            )

            await self.uow.commit()

        return tokens


    async def send_reset_mail(self, request: SendResetMailRequest) -> None:
        user = await self.user_repo.get_by_email(request.email)

        if not user:
            raise ResourceNotFoundError("User with email does not exist")

        reset_code = self._create_reset_code()

        await self.mail_service.send_reset_mail(
            email=user.email,
            reset_code=reset_code
        )

        await self.redis.set(
            name=RedisKeys.USER_RESET_CODE.format(email=user.email),
            value=reset_code,
            ex=3600
        )


    async def verify_reset_code(self, request: VerifyResetCodeRequest) -> VerifyResetCodeResponse:
        reset_code_key = RedisKeys.USER_RESET_CODE.format(email=request.email)
        code = await self.redis.get(reset_code_key)
        if not code:
            raise InvalidCredentialsError("Reset code expired or not found")

        if request.code != code:
            raise InvalidCredentialsError("Invalid reset code")

        await self.redis.delete(reset_code_key)

        reset_token = secrets.token_urlsafe(32)

        await self.redis.set(
            name=RedisKeys.USER_RESET_TOKEN.format(email=request.email),
            value=reset_token,
            ex=900
        )

        return VerifyResetCodeResponse(
            reset_token=reset_token
        )


    async def change_password(self, request: ChangePasswordRequest) -> None:
        token_key = RedisKeys.USER_RESET_TOKEN.format(email=request.email)
        token = await self.redis.get(token_key)

        if not token:
            raise InvalidCredentialsError("Reset token expired or not found")

        if request.reset_token != token:
            raise InvalidCredentialsError("Invalid reset token")

        async with self.uow:
            await self.user_repo.update_password(
                email=request.email,
                new_password=self._get_password_hash(request.new_password)
            )
            await self.redis.delete(token_key)
            await self.uow.commit()

        return None

    async def validate_access_token(self, token: str) -> int | None:
        return await self._validate_token(token, "access")

    async def validate_refresh_token(self, token: str) -> int | None:
        return await self._validate_token(token, "refresh")

    @staticmethod
    async def _validate_token(token: str, token_type: str) -> int | None:
        try:
            payload = jwt.decode(
                token,
                config.auth.secret_key,
                algorithms=[config.auth.algorithm]
            )
        except jwt.InvalidTokenError:
            return None

        if payload.get("type") != token_type:
            return None

        user_id = payload.get("sub")

        if not user_id:
            return None

        return int(user_id)

    @staticmethod
    def _generate_tokens(user_id: int) -> TokensResponse:
        access_token = AuthService._create_access_token(user_id)
        refresh_token = AuthService._create_refresh_token(user_id)
        return TokensResponse(
            access_token=access_token,
            refresh_token=refresh_token
        )

    @staticmethod
    def _create_access_token(user_id: int) -> str:
        expire = datetime.now(UTC) + timedelta(seconds=config.auth.access_token_expire)
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "type": "access"
        }

        return jwt.encode(
            to_encode,
            config.auth.secret_key,
            algorithm=config.auth.algorithm
        )

    @staticmethod
    def _create_refresh_token(user_id: int) -> str:
        expire = datetime.now(UTC) + timedelta(seconds=config.auth.refresh_token_expire)
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "type": "refresh"
        }

        return jwt.encode(
            to_encode,
            config.auth.secret_key,
            algorithm=config.auth.algorithm
        )

    @staticmethod
    def _verify_password(plain_password: str, hashed_password: str) -> bool:
        password_bytes = plain_password.encode('utf-8')
        hash_bytes = hashed_password.encode('utf-8')

        return bcrypt.checkpw(password_bytes, hash_bytes)

    @staticmethod
    def _get_password_hash(password: str) -> str:
        password_bytes = password.encode('utf-8')
        salt = bcrypt.gensalt()
        hashed_bytes = bcrypt.hashpw(password_bytes, salt)

        return hashed_bytes.decode('utf-8')

    @staticmethod
    def _create_reset_code() -> str:
        return "".join(str(secrets.randbelow(10)) for _ in range(5))
