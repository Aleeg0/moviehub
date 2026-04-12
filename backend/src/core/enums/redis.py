from enum import StrEnum


class RedisKeys(StrEnum):
    USER_RESET_CODE = 'user:{email}:reset_code'
    USER_RESET_TOKEN = 'user:{email}:reset_token'
