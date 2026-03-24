from sqlalchemy import BigInteger, String
from sqlalchemy.orm import Mapped, mapped_column, DeclarativeBase


class User(DeclarativeBase):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    hash_password: Mapped[str] = mapped_column(String, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)


