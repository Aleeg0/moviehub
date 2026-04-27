from fastapi.params import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core import get_db
from src.domain.repositories import TokenRepository, UnitOfWork, UserRepository, MovieRepository, UserMovieRepository


def get_unit_of_work(session: AsyncSession = Depends(get_db)) -> UnitOfWork:
    return UnitOfWork(session=session)

def get_token_repository(session: AsyncSession = Depends(get_db)) -> TokenRepository:
    return TokenRepository(session=session)

def get_user_repository(session: AsyncSession = Depends(get_db)) -> UserRepository:
    return UserRepository(session=session)

def get_movie_repository(session: AsyncSession = Depends(get_db)) -> MovieRepository:
    return MovieRepository(session=session)

def get_user_movie_repository(session: AsyncSession = Depends(get_db)) -> UserMovieRepository:
    return UserMovieRepository(session=session)