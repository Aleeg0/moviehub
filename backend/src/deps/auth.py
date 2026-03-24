import bcrypt
from datetime import datetime, timedelta, UTC
from jose import jwt

from src.core import config

def verify_password(plain_password: str, hashed_password: str) -> bool:
    password_bytes = plain_password.encode('utf-8')
    hash_bytes = hashed_password.encode('utf-8')

    return bcrypt.checkpw(password_bytes, hash_bytes)

def get_password_hash(password: str) -> str:
    password_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_bytes = bcrypt.hashpw(password_bytes, salt)

    return hashed_bytes.decode('utf-8')

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(UTC) + timedelta(seconds=config.auth.access_token_expire)
    to_encode.update({"exp": expire})

    return jwt.encode(
        to_encode,
        config.auth.secret_key,
        algorithm=config.auth.algorithm
    )


def create_reset_token(email: str) -> str:
    expire = datetime.now(UTC) + timedelta(seconds=config.auth.reset_token_expire)
    to_encode = {
        "sub": email,
        "exp": expire,
        "type": "reset"
    }

    return jwt.encode(
        to_encode,
        config.auth.secret_key,
        algorithm=config.auth.algorithm
    )