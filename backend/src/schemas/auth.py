from src.schemas.base import BaseSchema

class TokensResponse(BaseSchema):
    access_token: str
    refresh_token: str