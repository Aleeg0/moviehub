from src.core.errors import ResourceAlreadyExistsError
from src.schemas import HandleSeenMovieRequest, WSRes, WSStatus, UpsertMovieRequest, CreateUserMovieRequest
from src.services import UserService, MovieService


class WSService:
    def __init__(self, movie_service: MovieService, user_service: UserService):
        self.movie_service = movie_service
        self.user_service = user_service

    async def handle_ping_msg(self) -> WSRes:
        return WSRes(
            status=WSStatus.PONG,
            message="PONG"
        )

    async def handle_seen_movie_msg(self, payload: HandleSeenMovieRequest) -> WSRes:
        try:
            row_movie = UpsertMovieRequest.model_validate(payload.movie)
            movie = await self.movie_service.upsert(row_movie)

            row_view_movie = CreateUserMovieRequest(
                user_id=payload.user_id,
                movie_id=movie.id,
                status=payload.status,
            )
            await self.user_service.create_user_movie(row_view_movie)
        except ResourceAlreadyExistsError as e:
            return WSRes(
                status=WSStatus.MOVIE_ERROR,
                message=str(e)
            )
        except:
            return WSRes(status=WSStatus.MOVIE_ERROR)
        return WSRes(status=WSStatus.MOVIE_WROTE, message="OK")