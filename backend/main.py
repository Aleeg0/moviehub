from contextlib import asynccontextmanager

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from src.api.v1 import hc_router, router, ws_router
from src.core import connect_to_db, close_db, config, connect_to_redis, close_redis, init_mail
from src.core.errors import register_error_handlers


@asynccontextmanager
async def lifespan(_: FastAPI):
    await connect_to_db()
    await connect_to_redis()
    init_mail()

    try:
        yield
    finally:
        await close_db()
        await close_redis()


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
app.include_router(ws_router, prefix="/ws")
app.include_router(hc_router, prefix="/health")
