from sqlalchemy import select, delete
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models import RefreshToken


class TokenRepository:
    def __init__(self, session: AsyncSession):
        self._session = session

    async def upsert(self, token: str, user_id: int) -> RefreshToken:
        stmt = (
            insert(RefreshToken)
            .values(token=token, user_id=user_id)
        ).on_conflict_do_update(
            index_elements=["user_id"],
            set_={
                "token": token,
            }
        ).returning(RefreshToken)


        result = await self._session.scalar(stmt)
        await self._session.refresh(result)
        await self._session.flush()
        return result

    async def get_by_user_id(self, user_id: int) -> RefreshToken | None:
        stmt = (
            select(RefreshToken)
            .where(RefreshToken.user_id == user_id)
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def delete_by_user_id(self, user_id: int) -> bool:
        stmt = delete(RefreshToken).where(RefreshToken.user_id == user_id)
        await self._session.execute(stmt)
        await self._session.flush()
        return True
