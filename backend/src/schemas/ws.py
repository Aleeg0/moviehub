from enum import Enum
from typing import Union, Literal, Annotated

from pydantic import Field

from src.domain.models import UserMovieStatus
from src.schemas.base import BaseSchema
from src.schemas.movie import UpsertMovieRequest


# Enums
class ActionType(str, Enum):
    PING = "ping"
    MOVIE = "movie"

class WSStatus(int, Enum):
    PONG = 10101
    BAD_MSG = 10400
    UNKNOWN_ACTION = 10404
    MOVIE_NOT_FOUND = 10106
    MOVIE_WROTE = 10002
    MOVIE_ERROR = 10003

# Requests
class PingMsg(BaseSchema):
    action: Literal[ActionType.PING] = ActionType.PING

class SeenMovieMsg(BaseSchema):
    action: Literal[ActionType.MOVIE] = ActionType.MOVIE
    movie: UpsertMovieRequest
    status: UserMovieStatus

WSMsg = Annotated[
    Union[PingMsg, SeenMovieMsg],
    Field(discriminator='action')
]

# Response
class WSRes(BaseSchema):
    status: WSStatus
    message: str = "Unexpected error"



# Service
class HandleSeenMovieRequest(BaseSchema):
    user_id: int
    movie: UpsertMovieRequest
    status: UserMovieStatus