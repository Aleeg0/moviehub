from fastapi import APIRouter, Depends
from starlette import status

from src.schemas import GetUserMoviesStatisticRequest, UpdateUserMovieResponse, UpdateUserMovieRequest
from src.schemas.user import GetUserMoviesResponse, GetUserMoviesRequest, GetUserMoviesStatisticResponse, \
    PatchUserMovieRatingBody, DeleteUserMovieRequest
from src.services import UserService
from src.services.deps import get_user_service
from ..deps import get_user_id_http

router = APIRouter(prefix="/users")

@router.get(
    "/movies",
    response_model=GetUserMoviesResponse,
    status_code=status.HTTP_200_OK
)
async def get_user_movies(user_id: int = Depends(get_user_id_http), service: UserService = Depends(get_user_service)):
    return await service.get_user_movies(GetUserMoviesRequest(user_id=user_id))

@router.get(
    "/movies/statistic",
    response_model=GetUserMoviesStatisticResponse,
    status_code=status.HTTP_200_OK
)
async def get_user_movies_statistic(user_id: int = Depends(get_user_id_http), service: UserService = Depends(get_user_service)):
    return await service.get_user_movies_statistic(GetUserMoviesStatisticRequest(user_id=user_id))

@router.patch(
    "/movies/{movie_id}",
    response_model=UpdateUserMovieResponse,
    status_code=status.HTTP_200_OK
)
async def patch_user_movie(
    movie_id: int,
    request: PatchUserMovieRatingBody,
    user_id: int = Depends(get_user_id_http),
    service: UserService = Depends(get_user_service),
):
    return await service.update_user_movie(
        UpdateUserMovieRequest(
            movie_id=movie_id,
            user_id=user_id,
            status=request.status,
            rating=request.rating,
            comment=request.comment,
        )
    )

@router.delete(
    "/movies/{movie_id}",
    response_model=None,
    status_code=status.HTTP_204_NO_CONTENT
)
async def delete_user_movie(
    movie_id: int,
    user_id: int = Depends(get_user_id_http),
    service: UserService = Depends(get_user_service)
):
    await service.delete_user_movie(
        DeleteUserMovieRequest(
            movie_id=movie_id,
            user_id=user_id
        )
    )