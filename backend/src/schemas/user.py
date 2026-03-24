from datetime import datetime

from pydantic import BaseModel, EmailStr, Field, ConfigDict
from pydantic.alias_generators import to_camel


class UserBase(BaseModel):
    id: int

    model_config = ConfigDict(from_attributes=True, alias_generator=to_camel, validate_by_name=True)

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=64)
    name: str = Field(min_length=1, max_length=64)

class UserResponse(UserBase):
    email: EmailStr
    name: str = Field(min_length=1, max_length=64)
    created_at: datetime