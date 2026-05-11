from unittest.mock import AsyncMock, MagicMock

import pytest


@pytest.fixture
def user_repo():
    return AsyncMock()

@pytest.fixture
def token_repo():
    return AsyncMock()

@pytest.fixture
def movie_repo() -> AsyncMock:
    return AsyncMock()

@pytest.fixture
def user_movie_repo() -> AsyncMock:
    return AsyncMock()

@pytest.fixture
def user_movie_service_repo() -> AsyncMock:
    return AsyncMock()

@pytest.fixture
def redis():
    return AsyncMock()

@pytest.fixture
def uow():
    uow = MagicMock()
    uow.__aenter__ = AsyncMock(return_value=uow)
    uow.__aexit__ = AsyncMock(return_value=False)
    uow.commit = AsyncMock()
    return uow