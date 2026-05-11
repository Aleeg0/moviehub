import pytest
import pytest_asyncio
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession, AsyncEngine

from src.core.database import Base
from src.domain.repositories import UserRepository, TokenRepository, MovieRepository, UserMovieServiceRepository, \
    UserMovieRepository
from tests.configs import test_db_config


@pytest_asyncio.fixture(scope="session")
async def db_engine():
    engine = create_async_engine(
        test_db_config.get_database_url,
        echo=False,
        future=True,
    )
    yield engine
    await engine.dispose()

@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_db(db_engine: AsyncEngine):
    async with db_engine.connect() as conn:
        async with conn.begin():
            await conn.run_sync(Base.metadata.create_all)
    yield
    async with db_engine.connect() as conn:
        async with conn.begin():
            await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def db_session(db_engine):
    async_session_factory = async_sessionmaker(
        bind=db_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async with async_session_factory() as session:
        yield session
        await session.rollback()

@pytest.fixture
def user_repo(db_session: AsyncSession) -> UserRepository:
    return UserRepository(db_session)

@pytest.fixture
def token_repo(db_session: AsyncSession) -> TokenRepository:
    return TokenRepository(db_session)

@pytest.fixture
def movie_repo(db_session: AsyncSession) -> MovieRepository:
    return MovieRepository(db_session)

@pytest.fixture
def user_movie_service_repo(db_session: AsyncSession) -> UserMovieServiceRepository:
    return UserMovieServiceRepository(db_session)

@pytest.fixture
def user_movie_repo(db_session: AsyncSession) -> UserMovieRepository:
    return UserMovieRepository(db_session)