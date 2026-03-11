from fastapi import APIRouter, status
from starlette.responses import JSONResponse

hc_router = APIRouter()

@hc_router.get("/check")
async def healthcheck():
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content={}
    )