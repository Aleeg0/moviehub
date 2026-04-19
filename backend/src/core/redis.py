from redis.asyncio import Redis, from_url

from src.core import config

redis_client: Redis | None = None

async def connect_to_redis():
    global redis_client
    redis_client = from_url(config.redis.get_connection_url, decode_responses=True)
    await redis_client.ping()


async def close_redis():
    global redis_client
    if redis_client is not None:
        await redis_client.aclose()
        redis_client = None

def get_redis() -> Redis:
    return redis_client