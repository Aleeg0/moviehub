from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    id: int

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=64)
    name: str = Field(min_length=1, max_length=64)

class UserResponse(UserBase,UserCreate):
    pass