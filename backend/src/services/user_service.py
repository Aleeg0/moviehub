from src.domain.models import UserMovie, UserMovieStatus
from src.schemas import CreateUserMovieRequest, CreateUserMovieResponse, GetUserMoviesRequest, GetUserMoviesResponse, \
    GetUserMovieResponse, GetUserMoviesStatisticResponse, GetUserMoviesStatisticRequest, UpdateUserMovieRequest, \
    UpdateUserMovieResponse, DeleteUserMovieRequest
from ..domain.repositories import UnitOfWork, UserMovieRepository


class UserService:
    def __init__(
        self,
        uow: UnitOfWork,
        user_movie_repo: UserMovieRepository,
    ):
        self.uow = uow
        self.user_movie_repo = user_movie_repo

    async def create_user_movie(self, request: CreateUserMovieRequest) -> CreateUserMovieResponse:
        user_movie = UserMovie(
            user_id = request.user_id,
            movie_id = request.movie_id,
            status = request.status,
            rating = request.rating,
            comment = request.comment,
        )

        async with self.uow:
            user_movie = await self.user_movie_repo.create(user_movie)
            await self.uow.commit()

        return CreateUserMovieResponse.model_validate(user_movie)


    async def get_user_movies(self, request: GetUserMoviesRequest) -> GetUserMoviesResponse:
        user_movies = await self.user_movie_repo.get_user_movies_by_user_id(request.user_id)

        return GetUserMoviesResponse(
            movies=[
                GetUserMovieResponse(
                    id=movie.id,
                    external_id=movie.external_id,
                    title=movie.title,
                    release_date=movie.release_date,
                    poster_path=movie.poster_path,
                    genre_id=movie.genre_id,
                    vote_average=movie.vote_average,
                    status=user_movie.status,
                    created_at=user_movie.created_at,
                    rating=user_movie.rating,
                    comment=user_movie.comment,
                )
                for user_movie, movie in user_movies
            ]
        )


    async def get_user_movies_statistic(self, request: GetUserMoviesStatisticRequest) -> GetUserMoviesStatisticResponse:
        stats = await self.user_movie_repo.get_user_movie_statistics_by_user_id(request.user_id)

        counts = { status: count for status, count in stats }

        return GetUserMoviesStatisticResponse(
            liked=counts.get(UserMovieStatus.LIKED, 0),
            disliked=counts.get(UserMovieStatus.DISLIKED, 0),
            viewed=counts.get(UserMovieStatus.VIEWED, 0),
        )

    async def update_user_movie(self, request: UpdateUserMovieRequest) -> UpdateUserMovieResponse:
        updated_fields = request.model_dump(exclude={"user_id", "movie_id"}, exclude_none=True)

        if updated_fields.get("status") != UserMovieStatus.VIEWED:
            updated_fields.update({
                "rating": None,
                "comment": None
            })

        async with self.uow:
            user_movie = await self.user_movie_repo.update_user_movie(
                user_id=request.user_id,
                movie_id=request.movie_id,
                updated_field=updated_fields,
            )
            await self.uow.commit()

        return UpdateUserMovieResponse.model_validate(user_movie)

    async def delete_user_movie(self, request: DeleteUserMovieRequest) -> None:
        async with self.uow:
            await self.user_movie_repo.delete(request.user_id, request.movie_id)
            await self.uow.commit()