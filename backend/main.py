from contextlib import asynccontextmanager

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from src.api.v1.router import router
from src.api.v1.healtcheck import hc_router
from src.core import connect_to_db, close_db, config
from src.core.database import init_db
from src.core.errors import register_error_handlers


@asynccontextmanager
async def lifespan(_: FastAPI):
    #TODO change to connect_db when apply migrations
    await init_db()

    try:
        yield
    finally:
        await close_db()


app = FastAPI(title="Moviehub_core", version="1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[config.cors.split(",")],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_error_handlers(app)

app.include_router(router, prefix="/api")
app.include_router(hc_router, prefix="/health")
