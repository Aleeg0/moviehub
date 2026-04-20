from fastapi.params import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.services import MovieService


def get_movie_service(session: AsyncSession = Depends(get_db)) -> MovieService:
    return MovieService(
        session=session
    )