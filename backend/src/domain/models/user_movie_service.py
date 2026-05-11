from sqlalchemy import ForeignKey, Integer
from sqlalchemy.orm import mapped_column, Mapped

from src.core.database import Base


class UserMovieService(Base):
    __tablename__ = "user_movie_services"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", onupdate="CASCADE", ondelete="CASCADE"), primary_key=True
    )
    movie_service_id: Mapped[int] = mapped_column(Integer, primary_key=True)

