from datetime import date

import pytest
import pytest_asyncio

from src.core.errors import ResourceAlreadyExistsError, ResourceNotFoundError
from src.domain.models import UserMovie, User, Movie, UserMovieStatus
from src.domain.repositories import UserRepository, MovieRepository, UserMovieRepository


def make_movie_dict(**overrides) -> dict:
    base = {
        "external_id": 1,
        "title": "Test Movie",
        "genre_id": 1,
        "poster_path": "/poster.jpg",
        "release_date": date(2024, 1, 1),
        "vote_average": 7.5,
    }
    return {**base, **overrides}

class TestUserMovieRepository:
    @pytest_asyncio.fixture
    async def existing_user(self, user_repo: UserRepository) -> User:
        return await user_repo.create(
            User(email="um_user@test.com", hashed_password="hash", name="Name")
        )

    @pytest_asyncio.fixture
    async def existing_movie(self, movie_repo: MovieRepository) -> Movie:
        return await movie_repo.upsert(make_movie_dict(external_id=100))

    @pytest_asyncio.fixture
    async def existing_user_movie(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_movie: Movie,
    ) -> UserMovie:
        return await user_movie_repo.create(
            UserMovie(
                user_id=existing_user.id,
                movie_id=existing_movie.id,
                status=UserMovieStatus.VIEWED,
            )
        )

    async def test_create_returns_user_movie(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_movie: Movie,
    ) -> None:
        user_movie = UserMovie(
            user_id=existing_user.id,
            movie_id=existing_movie.id,
            status=UserMovieStatus.LIKED,
        )
        result = await user_movie_repo.create(user_movie)
        assert result.user_id == existing_user.id
        assert result.movie_id == existing_movie.id
        assert result.status == UserMovieStatus.LIKED

    async def test_create_raises_if_already_exists(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user_movie: UserMovie,
    ) -> None:
        duplicate = UserMovie(
            user_id=existing_user_movie.user_id,
            movie_id=existing_user_movie.movie_id,
            status=UserMovieStatus.VIEWED,
        )
        with pytest.raises(ResourceAlreadyExistsError):
            await user_movie_repo.create(duplicate)

    async def test_get_user_movies_returns_empty_list_if_none(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
    ) -> None:
        result = await user_movie_repo.get_user_movies_by_user_id(existing_user.id)
        assert result == []

    async def test_get_user_movies_returns_correct_pair(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_movie: Movie,
        existing_user_movie: UserMovie,
    ) -> None:
        result = await user_movie_repo.get_user_movies_by_user_id(existing_user.id)
        assert len(result) == 1
        user_movie, movie = result[0]
        assert user_movie.user_id == existing_user.id
        assert movie.id == existing_movie.id

    async def test_get_user_movies_returns_only_own_movies(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_user_movie: UserMovie,
        user_repo: UserRepository,
    ) -> None:
        other_user = await user_repo.create(
            User(email="other_um@test.com", hashed_password="hash", name="Other")
        )
        result = await user_movie_repo.get_user_movies_by_user_id(other_user.id)
        assert result == []

    async def test_statistics_returns_empty_if_no_movies(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
    ) -> None:
        result = await user_movie_repo.get_user_movie_statistics_by_user_id(existing_user.id)
        assert result == []

    async def test_statistics_counts_correctly(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        movie_repo: MovieRepository,
    ) -> None:
        movie2 = await movie_repo.upsert(make_movie_dict(external_id=201))
        movie3 = await movie_repo.upsert(make_movie_dict(external_id=202))

        await user_movie_repo.create(UserMovie(user_id=existing_user.id, movie_id=movie2.id, status=UserMovieStatus.LIKED))
        await user_movie_repo.create(UserMovie(user_id=existing_user.id, movie_id=movie3.id, status=UserMovieStatus.LIKED))

        result = await user_movie_repo.get_user_movie_statistics_by_user_id(existing_user.id)
        stats = {status: count for status, count in result}
        assert stats[UserMovieStatus.LIKED] == 2

    async def test_update_changes_status(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user_movie: UserMovie,
    ) -> None:
        result = await user_movie_repo.update_user_movie(
            existing_user_movie.user_id,
            existing_user_movie.movie_id,
            {"status": UserMovieStatus.LIKED},
        )
        assert result.status == UserMovieStatus.LIKED

    async def test_update_changes_rating(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user_movie: UserMovie,
    ) -> None:
        result = await user_movie_repo.update_user_movie(
            existing_user_movie.user_id,
            existing_user_movie.movie_id,
            {"rating": 4},
        )
        assert result.rating == 4

    async def test_update_raises_if_not_found(
        self,
        user_movie_repo: UserMovieRepository,
    ) -> None:
        with pytest.raises(ResourceNotFoundError):
            await user_movie_repo.update_user_movie(
                user_id=999999,
                movie_id=999999,
                updated_field={"status": UserMovieStatus.VIEWED},
            )

    async def test_update_raises_on_rating_above_5(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user_movie: UserMovie,
    ) -> None:
        with pytest.raises(Exception):
            await user_movie_repo.update_user_movie(
                existing_user_movie.user_id,
                existing_user_movie.movie_id,
                {"rating": 6},
            )

    async def test_delete_removes_user_movie(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_user_movie: UserMovie,
    ) -> None:
        await user_movie_repo.delete(existing_user_movie.user_id, existing_user_movie.movie_id)
        result = await user_movie_repo.get_user_movies_by_user_id(existing_user.id)
        assert result == []

    async def test_delete_does_nothing_if_not_found(
        self,
        user_movie_repo: UserMovieRepository,
    ) -> None:
        await user_movie_repo.delete(user_id=999999, movie_id=999999)

    async def test_delete_does_not_affect_other_user_movies(
        self,
        user_movie_repo: UserMovieRepository,
        existing_user: User,
        existing_user_movie: UserMovie,
        user_repo: UserRepository,
        movie_repo: MovieRepository,
    ) -> None:
        other_user = await user_repo.create(
            User(email="other_del@test.com", hashed_password="hash", name="Other")
        )
        other_movie = await movie_repo.upsert(make_movie_dict(external_id=301))
        await user_movie_repo.create(
            UserMovie(user_id=other_user.id, movie_id=other_movie.id, status=UserMovieStatus.VIEWED)
        )

        await user_movie_repo.delete(existing_user_movie.user_id, existing_user_movie.movie_id)

        other_result = await user_movie_repo.get_user_movies_by_user_id(other_user.id)
        assert len(other_result) == 1