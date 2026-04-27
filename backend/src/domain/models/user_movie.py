from enum import Enum

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from src.core.database import Base


class UserMovieStatus(str, Enum):
    LIKED = "liked"
    DISLIKED = "disliked"
    VIEWED = "viewed"

class UserMovie(Base):
    __tablename__ = "user_movies"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    movie_id: Mapped[int] = mapped_column(
        ForeignKey("movies.id", ondelete="CASCADE"), primary_key=True
    )
    status: Mapped[UserMovieStatus] = mapped_column(nullable=False)