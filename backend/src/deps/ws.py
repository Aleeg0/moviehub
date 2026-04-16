from fastapi.params import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.services import WSService


def get_ws_service(session: AsyncSession = Depends(get_db)) -> WSService:
    return WSService(
        session=session
    )