from http import HTTPStatus

from fastapi import APIRouter, Depends
from watchfiles import awatch

from src.api.v1.dep import get_user_service
from src.schemas.user import UserResponse, UserCreate
from src.services import UserService

router = APIRouter(prefix="/users")

@router.get("/{user_id}", response_model=UserResponse, status_code=HTTPStatus.OK)
async def get_user(user_id: int, service: UserService = Depends(get_user_service)):
    return await service.get_one(user_id)

@router.post("", response_model=None, status_code=HTTPStatus.CREATED)
async def create_user(request: UserCreate, service: UserService = Depends(get_user_service)):
    return await service.create(request)

@router.delete("/{user_id}", response_model=None, status_code=HTTPStatus.NO_CONTENT)
async def delete_user(user_id: int, service: UserService = Depends(get_user_service)):
    return await service.delete(user_id)