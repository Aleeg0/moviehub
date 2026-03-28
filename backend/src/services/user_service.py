from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import ResourceAlreadyExistsError, InvalidCredentialsError, ResourceNotFoundError
from src.deps.auth import get_password_hash, verify_password
from src.domain.models import User
from src.schemas.auth import TokensResponse
from src.schemas.user import UserLogin, UserRegister
from .auth_service import AuthService
from .mail_service import MailService


class UserService:
    def __init__(
        self,
        session: AsyncSession,
        mail_service: MailService,
        auth_service: AuthService
    ):
        self.session = session
        self.mail_service = mail_service
        self.auth_service = auth_service

    async def register(self, user_dto: UserRegister) -> TokensResponse:
        hashed_password = get_password_hash(user_dto.password)

        user: User = User(
            email=user_dto.email,
            hashed_password=hashed_password,
            name=user_dto.name,
        )

        try:
            self.session.add(user)
            await self.session.flush()
            await self.session.refresh(user)
        except IntegrityError as e:
            await self.session.rollback()
            raise ResourceAlreadyExistsError(f"{User.__name__} already exists") from e

        await self.session.commit()

        # TODO add link
        await self.mail_service.send_activation_mail()

        tokens = self.auth_service.generate_tokens(user.id)
        await self.auth_service.save_token(user.id, tokens.refresh_token)

        return tokens

    async def login(self, user_dto: UserLogin) -> TokensResponse:
        result = await self.session.execute(select(User).where(User.email == user_dto.email))

        user = result.scalar_one_or_none()

        if not user:
            raise InvalidCredentialsError("Incorrect email or password")

        if not verify_password(user_dto.password, user.hashed_password):
            raise InvalidCredentialsError("Incorrect email or password")

        tokens = self.auth_service.generate_tokens(user.id)
        await self.auth_service.save_token(user.id, tokens.refresh_token)

        return tokens

    async def logout(self, refresh_token: str) -> None:
        user_id = await self.auth_service.validate_token(refresh_token)
        if not user_id:
            raise ResourceNotFoundError("Incorrect refresh token")

        await self.auth_service.revoke_token(user_id)

    async def delete(self, user_id: int) -> None:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        await self.session.delete(user)
        await self.session.commit()