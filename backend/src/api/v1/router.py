from fastapi import APIRouter

from .endpoints import user, auth
from .ws import movie

router = APIRouter(prefix="/v1")
router.include_router(user.router, tags=["users"])
router.include_router(auth.router, tags=["auth"])

ws_router = APIRouter(prefix="/v1")
ws_router.include_router(movie.router, tags=["movies"])