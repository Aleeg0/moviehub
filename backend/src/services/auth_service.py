from datetime import datetime, UTC, timedelta

from jose import jwt, JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import config
from src.domain.models.refresh_token import RefreshToken
from src.schemas.auth import TokensResponse


class AuthService:
    def __init__(self, session: AsyncSession):
        self.session = session

    def generate_tokens(self, user_id: int) -> TokensResponse:
        access_token = self._create_access_token(user_id)
        refresh_token = self._create_refresh_token(user_id)

        return TokensResponse(access_token=access_token, refresh_token=refresh_token)

    async def validate_token(self, token: str) -> int | None:
        print(token)
        try:
            payload = jwt.decode(
                token,
                config.auth.secret_key,
                algorithms=[config.auth.algorithm]
            )
        except JWTError as e:
            print(f'JWT Error details: {e}')
            return None

        if payload.get("type") != "refresh":
            return None

        user_id = payload.get("sub")
        if not user_id:
            return None

        result = await self.session.execute(
            select(RefreshToken).where(RefreshToken.user_id == int(user_id))
        )
        db_token = result.scalar_one_or_none()

        if db_token is None or db_token.token != token:
            return None

        return int(user_id)

    async def revoke_token(self, user_id: int) -> None:
        result = await self.session.execute(
            select(RefreshToken).where(RefreshToken.user_id == user_id)
        )

        refresh_token = result.scalar_one_or_none()

        await self.session.delete(refresh_token)
        await self.session.commit()

    async def save_token(self, user_id: int, token: str):
        result = await self.session.execute(
            select(RefreshToken).where(RefreshToken.user_id == user_id)
        )

        refresh_token = result.scalar_one_or_none()

        if refresh_token is None:
            refresh_token = RefreshToken(
                user_id=user_id,
                token=token
            )
            self.session.add(refresh_token)
        else:
            refresh_token.token = token

        await self.session.commit()

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