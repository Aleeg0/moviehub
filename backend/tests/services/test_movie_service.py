from datetime import date
from unittest.mock import MagicMock, AsyncMock

import pytest

from src.domain.models import Movie
from src.schemas import UpsertMovieRequest, UpsertMovieResponse
from src.services import MovieService


def make_upsert_request(**overrides) -> UpsertMovieRequest:
    base = {
        "external_id": 1,
        "title": "Test Movie",
        "poster_path": "/poster.jpg",
        "release_date": date(2024, 1, 1),
        "vote_average": 7.5,
        "genre_id": 1,
    }
    return UpsertMovieRequest(**{**base, **overrides})


def make_movie(**overrides) -> Movie:
    base = {
        "id": 1,
        "external_id": 1,
        "title": "Test Movie",
        "poster_path": "/poster.jpg",
        "release_date": date(2024, 1, 1),
        "vote_average": 7.5,
        "genre_id": 1,
    }
    return Movie(**{**base, **overrides})

class TestMovieService:
    @pytest.fixture
    def movie_service(
        self,
        uow: MagicMock,
        movie_repo: AsyncMock
    ) -> MovieService:
        return MovieService(uof=uow, movie_repo=movie_repo)

    async def test_upsert_movie_returns_response(
        self,
        movie_service: MovieService,
        movie_repo: AsyncMock,
    ) -> None:
        movie_repo.upsert.return_value = make_movie()
        result = await movie_service.upsert_movie(make_upsert_request())
        assert isinstance(result, UpsertMovieResponse)

    async def test_upsert_movie_returns_correct_data(
        self,
        movie_service: MovieService,
        movie_repo: AsyncMock,
    ) -> None:
        movie = make_movie(title="Inception", external_id=42)
        movie_repo.upsert.return_value = movie
        result = await movie_service.upsert_movie(make_upsert_request(title="Inception", external_id=42))
        assert result.title == "Inception"
        assert result.external_id == 42

    async def test_upsert_movie_calls_repo_with_correct_data(
        self,
        movie_service: MovieService,
        movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        movie_repo.upsert.return_value = make_movie()
        request = make_upsert_request()
        await movie_service.upsert_movie(request)
        movie_repo.upsert.assert_called_once_with(request.model_dump())

    async def test_upsert_movie_commits(
        self,
        movie_service: MovieService,
        movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        movie_repo.upsert.return_value = make_movie()
        await movie_service.upsert_movie(make_upsert_request())
        uow.commit.assert_called_once()

    async def test_upsert_movie_without_genre(
        self,
        movie_service: MovieService,
        movie_repo: AsyncMock,
    ) -> None:
        movie_repo.upsert.return_value = make_movie(genre_id=None)
        result = await movie_service.upsert_movie(make_upsert_request(genre_id=None))
        assert result.genre_id is None