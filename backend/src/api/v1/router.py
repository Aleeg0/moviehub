from fastapi import APIRouter

from .endpoints import user
from .ws import movie

router = APIRouter(prefix="/v1")
router.include_router(user.router, tags=["users"])

ws_router = APIRouter(prefix="/v1")
ws_router.include_router(movie.router, tags=["movies"])