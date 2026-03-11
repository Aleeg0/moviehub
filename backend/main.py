from contextlib import asynccontextmanager

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from src.api.v1.healtcheck import hc_router
from src.core import connect_to_db, close_db


@asynccontextmanager
async def lifespan(_: FastAPI):
    await connect_to_db()

    try:
        yield
    finally:
        await close_db()


app = FastAPI(title="Moviehub_core", version="1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(hc_router, prefix="/health")