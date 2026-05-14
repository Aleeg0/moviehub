import pytest
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock

from src.core.errors import ResourceAlreadyExistsError, ResourceNotFoundError
from src.domain.models import UserMovie, UserMovieStatus, UserMovieService
from src.schemas import (
    CreateUserMovieRequest,
    CreateUserMovieResponse,
    GetUserMoviesRequest,
    GetUserMoviesStatisticRequest,
    UpdateUserMovieRequest,
    DeleteUserMovieRequest,
    GetUserMovieServicesRequest,
    UpsertUserMovieServicesRequest,
)
from src.services import UserService


def make_user_movie(**overrides) -> UserMovie:
    base = {
        "user_id": 1,
        "movie_id": 1,
        "status": UserMovieStatus.VIEWED,
        "rating": None,
        "comment": None,
        "created_at": datetime.now(),
    }
    return UserMovie(**{**base, **overrides})


def make_movie_mock(**overrides):
    movie = MagicMock()
    movie.id = overrides.get("id", 1)
    movie.external_id = overrides.get("external_id", 100)
    movie.title = overrides.get("title", "Test Movie")
    movie.poster_path = overrides.get("poster_path", "/poster.jpg")
    movie.release_date = overrides.get("release_date", date(2024, 1, 1))
    movie.vote_average = overrides.get("vote_average", 7.5)
    movie.genre_id = overrides.get("genre_id", 1)
    return movie


class TestUserService:
    @pytest.fixture
    def user_service(
        self,
        uow: MagicMock,
        user_movie_repo: AsyncMock,
        user_movie_service_repo: AsyncMock,
    ) -> UserService:
        return UserService(
            uow=uow,
            user_movie_repo=user_movie_repo,
            user_movie_service_repo=user_movie_service_repo,
        )

    async def test_create_user_movie_returns_response(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.create.return_value = make_user_movie()
        result = await user_service.create_user_movie(
            CreateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.VIEWED
            )
        )
        assert isinstance(result, CreateUserMovieResponse)
        assert result.user_id == 1
        assert result.movie_id == 1

    async def test_create_user_movie_calls_repo_and_commits(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.create.return_value = make_user_movie()
        await user_service.create_user_movie(
            CreateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.VIEWED
            )
        )
        user_movie_repo.create.assert_called_once()
        uow.commit.assert_called_once()

    async def test_create_user_movie_raises_if_already_exists(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.create.side_effect = ResourceAlreadyExistsError("UserMovie already exists")
        with pytest.raises(ResourceAlreadyExistsError):
            await user_service.create_user_movie(
                CreateUserMovieRequest(
                    user_id=1,
                    movie_id=1,
                    status=UserMovieStatus.VIEWED
                )
            )

    async def test_get_user_movies_returns_empty_list(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.get_user_movies_by_user_id.return_value = []
        result = await user_service.get_user_movies(
            GetUserMoviesRequest(
                user_id=1
            )
        )
        assert result.movies == []

    async def test_get_user_movies_returns_correct_data(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie = make_user_movie(
            status=UserMovieStatus.LIKED,
            rating=4
        )
        movie = make_movie_mock(
            title="Inception"
        )
        user_movie_repo.get_user_movies_by_user_id.return_value = [(user_movie, movie)]

        result = await user_service.get_user_movies(
            GetUserMoviesRequest(
                user_id=1
            )
        )

        assert len(result.movies) == 1
        assert result.movies[0].title == "Inception"
        assert result.movies[0].status == UserMovieStatus.LIKED
        assert result.movies[0].rating == 4

    async def test_get_user_movies_calls_repo_with_correct_user_id(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.get_user_movies_by_user_id.return_value = []
        await user_service.get_user_movies(
            GetUserMoviesRequest(
                user_id=42
            )
        )
        user_movie_repo.get_user_movies_by_user_id.assert_called_once_with(42)


    async def test_get_statistic_returns_zeros_if_no_movies(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.get_user_movie_statistics_by_user_id.return_value = []
        result = await user_service.get_user_movies_statistic(
            GetUserMoviesStatisticRequest(
                user_id=1
            )
        )
        assert result.liked == 0
        assert result.disliked == 0
        assert result.viewed == 0

    async def test_get_statistic_counts_correctly(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.get_user_movie_statistics_by_user_id.return_value = [
            (UserMovieStatus.LIKED, 3),
            (UserMovieStatus.VIEWED, 5),
        ]
        result = await user_service.get_user_movies_statistic(
            GetUserMoviesStatisticRequest(
                user_id=1
            )
        )
        assert result.liked == 3
        assert result.viewed == 5
        assert result.disliked == 0

    async def test_update_user_movie_returns_response(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.update_user_movie.return_value = make_user_movie(status=UserMovieStatus.LIKED)
        result = await user_service.update_user_movie(
            UpdateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.LIKED
            )
        )
        assert result.status == UserMovieStatus.LIKED

    async def test_update_clears_rating_and_comment_if_status_not_viewed(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.update_user_movie.return_value = make_user_movie(
            status=UserMovieStatus.LIKED,
            rating=None,
            comment=None
        )
        await user_service.update_user_movie(
            UpdateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.LIKED,
                rating=4,
                comment="Great",
            )
        )
        call_kwargs = user_movie_repo.update_user_movie.call_args.kwargs
        assert call_kwargs["updated_field"]["rating"] is None
        assert call_kwargs["updated_field"]["comment"] is None

    async def test_update_keeps_rating_and_comment_if_status_viewed(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.update_user_movie.return_value = make_user_movie(
            status=UserMovieStatus.VIEWED,
            rating=4,
            comment="Great"
        )
        await user_service.update_user_movie(
            UpdateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.VIEWED,
                rating=4,
                comment="Great",
            )
        )
        call_kwargs = user_movie_repo.update_user_movie.call_args.kwargs
        assert call_kwargs["updated_field"].get("rating") == 4
        assert call_kwargs["updated_field"].get("comment") == "Great"

    async def test_update_raises_if_not_found(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
    ) -> None:
        user_movie_repo.update_user_movie.side_effect = ResourceNotFoundError("UserMovie not found")
        with pytest.raises(ResourceNotFoundError):
            await user_service.update_user_movie(
                UpdateUserMovieRequest(
                    user_id=999,
                    movie_id=999,
                    status=UserMovieStatus.VIEWED
                )
            )

    async def test_update_commits(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        user_movie_repo.update_user_movie.return_value = make_user_movie()
        await user_service.update_user_movie(
            UpdateUserMovieRequest(
                user_id=1,
                movie_id=1,
                status=UserMovieStatus.VIEWED
            )
        )
        uow.commit.assert_called_once()

    async def test_delete_calls_repo_and_commits(
        self,
        user_service: UserService,
        user_movie_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        await user_service.delete_user_movie(DeleteUserMovieRequest(
            user_id=1,
            movie_id=1)
        )
        user_movie_repo.delete.assert_called_once_with(1, 1)
        uow.commit.assert_called_once()

    async def test_get_user_movie_services_returns_empty_list(
        self,
        user_service: UserService,
        user_movie_service_repo: AsyncMock,
    ) -> None:
        user_movie_service_repo.get_by_user_id.return_value = []
        result = await user_service.get_user_movie_services(
            GetUserMovieServicesRequest(
                user_id=1
            )
        )
        assert result.movie_ids == []

    async def test_get_user_movie_services_returns_correct_ids(
        self,
        user_service: UserService,
        user_movie_service_repo: AsyncMock,
    ) -> None:
        services = [
            UserMovieService(user_id=1, movie_service_id=10),
            UserMovieService(user_id=1, movie_service_id=20),
        ]
        user_movie_service_repo.get_by_user_id.return_value = services
        result = await user_service.get_user_movie_services(
            GetUserMovieServicesRequest(user_id=1)
        )
        assert result.movie_ids == [10, 20]

    async def test_upsert_user_movie_services_calls_repo_and_commits(
        self,
        user_service: UserService,
        user_movie_service_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        await user_service.upsert_user_movie_services(
            UpsertUserMovieServicesRequest(user_id=1, movie_ids=[1, 2, 3])
        )
        user_movie_service_repo.upsert.assert_called_once_with(1, [1, 2, 3])
        uow.commit.assert_called_once()

    async def test_upsert_user_movie_services_with_empty_list(
        self,
        user_service: UserService,
        user_movie_service_repo: AsyncMock,
        uow: MagicMock,
    ) -> None:
        await user_service.upsert_user_movie_services(
            UpsertUserMovieServicesRequest(user_id=1, movie_ids=[])
        )
        user_movie_service_repo.upsert.assert_called_once_with(1, [])
        uow.commit.assert_called_once()