from datetime import date

from sqlalchemy import BigInteger, String, Numeric, CheckConstraint, Date, Integer
from sqlalchemy.orm import mapped_column, Mapped

from src.core.database import Base


class Movie(Base):
    __tablename__ = "movies"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)

    external_id: Mapped[int] = mapped_column(BigInteger, nullable=False, unique=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    genre_id: Mapped[int] = mapped_column(Integer, nullable=True)
    poster_path: Mapped[str] = mapped_column(String, nullable=False)
    release_date: Mapped[date] = mapped_column(Date, nullable=False)
    vote_average: Mapped[float] = mapped_column(Numeric(3, 1),nullable=False)

    __table_args__ = (
        CheckConstraint(
            "vote_average >= 0.0 AND vote_average <= 10.0",
            name="ck_movies_vote_average_range"
        ),
    )