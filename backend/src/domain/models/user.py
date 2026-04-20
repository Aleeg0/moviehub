from datetime import datetime
from enum import Enum

from sqlalchemy import BigInteger, String, DateTime, func, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from src.core.database import Base


class UserMovieStatus(str, Enum):
    LIKED = "liked"
    DISLIKED = "disliked"
    VIEWED = "viewed"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, server_default=func.now())


class UserMovie(Base):
    __tablename__ = "user_movies"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    movie_id: Mapped[int] = mapped_column(
        ForeignKey("movies.id", ondelete="CASCADE"), primary_key=True
    )
    status: Mapped[UserMovieStatus] = mapped_column(nullable=False)