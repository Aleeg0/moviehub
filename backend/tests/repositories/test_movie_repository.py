from datetime import date

import pytest_asyncio

from src.domain.models import Movie
from src.domain.repositories import MovieRepository

def make_movie_dict(**overrides) -> dict:
    base = {
        "external_id": 1,
        "title": "Test Movie",
        "genre_id": 1,
        "poster_path": "/poster.jpg",
        "release_date": date(2026, 1, 1),
        "vote_average": 7.5,
    }
    return {**base, **overrides}

class TestMovieRepository:
    @pytest_asyncio.fixture
    async def existing_movie(
        self,
        movie_repo: MovieRepository,
    ) -> Movie:
        return await movie_repo.upsert(make_movie_dict())

    async def test_get_by_id_returns_movie(
        self,
        movie_repo: MovieRepository,
        existing_movie: Movie
    ) -> None:
        result = await movie_repo.get_by_id(existing_movie.id)
        assert result is not None
        assert result.id == existing_movie.id

    async def test_get_by_id_returns_none_if_not_found(
        self,
        movie_repo: MovieRepository,
    ) -> None:
        result = await movie_repo.get_by_id(movie_id=999)
        assert result is None

    async def test_upsert_creates_movie_if_not_exists(
        self,
        movie_repo: MovieRepository,
    ) -> None:
        external_id = 1
        movie_dict = make_movie_dict(external_id=external_id)
        result = await movie_repo.upsert(movie_dict)
        assert result is not None
        assert result.external_id == external_id
        assert result.title == movie_dict["title"]

    async def test_upsert_updates_movie_if_already_exists(
        self,
        movie_repo: MovieRepository,
        existing_movie: Movie
    ) -> None:
        updated_vote_average = round((existing_movie.vote_average - 1 + 10) % 10, 1)
        result = await movie_repo.upsert(
            make_movie_dict(
                external_id=existing_movie.external_id,
                vote_average=updated_vote_average
            )
        )
        assert result.external_id == existing_movie.external_id
        assert result.vote_average == updated_vote_average

    async def test_upsert_does_not_create_duplicate_for_same_user(
        self,
        movie_repo: MovieRepository
    ) -> None:
        movie2_title = "movie 2"
        movie1 = await movie_repo.upsert(make_movie_dict(title="movie 1"))
        movie2 = await movie_repo.upsert(make_movie_dict(title=movie2_title))

        last_movie = await movie_repo.get_by_id(movie2.id)
        assert last_movie.id == movie2.id
        assert last_movie.id == movie1.id
        assert last_movie.title == movie2_title


