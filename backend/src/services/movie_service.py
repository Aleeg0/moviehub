from src.domain.repositories import UnitOfWork, MovieRepository
from src.schemas import UpsertMovieRequest, UpsertMovieResponse


class MovieService:
    def __init__(
        self,
        uof: UnitOfWork,
        movie_repo: MovieRepository,
    ):
        self.uof = uof
        self.movie_repo = movie_repo

    async def upsert_movie(self, request: UpsertMovieRequest) -> UpsertMovieResponse:
        async with self.uof:
            movie = await self.movie_repo.upsert(request.model_dump())
            await self.uof.commit()

        return UpsertMovieResponse.model_validate(movie)
