from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class TelegramAuthRequest(BaseModel):
    init_data: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    telegram_id: int
    balance_ov: float
    balance_eur: float


class UserPublic(BaseModel):
    id: int
    telegram_id: int
    username: Optional[str]
    first_name: Optional[str]
    balance_ov: float
    balance_eur: float
    is_premium: bool

    class Config:
        from_attributes = True


class GenerationCreate(BaseModel):
    prompt: str
    content_type: str  # photo, video, comic
    style: Optional[str] = None
    format_: Optional[str] = None


class GenerationOut(BaseModel):
    id: int
    prompt: str
    content_type: str
    status: str
    result_url: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class PostCreate(BaseModel):
    title: str
    description: Optional[str] = None
    media_url: Optional[str] = None
    is_locked: bool = False


class PostOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    media_url: Optional[str]
    votes: int
    author_username: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class DonationCreate(BaseModel):
    to_user_id: int
    post_id: Optional[int] = None
    amount_ov: float = 0.0
    amount_eur: float = 0.0
    currency: str  # "OV" or "EUR"


class ChatMessageCreate(BaseModel):
    message: str
    room: str = "global"
