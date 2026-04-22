from fastapi.params import Depends

from src.deps import get_user_service
from src.deps.movie import get_movie_service
from src.services import WSService, MovieService, UserService


def get_ws_service(
    movie_service: MovieService = Depends(get_movie_service),
    user_service: UserService = Depends(get_user_service)
) -> WSService:
    return WSService(
        movie_service=movie_service,
        user_service=user_service,
    )