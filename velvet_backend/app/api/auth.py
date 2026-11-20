from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import verify_telegram_init_data, create_access_token
from app.models.models import User
from app.schemas.schemas import TelegramAuthRequest, TokenResponse

router = APIRouter()


@router.post("/telegram", response_model=TokenResponse)
async def auth_telegram(
    payload: TelegramAuthRequest,
    db: AsyncSession = Depends(get_db)
):
    """Autentica tramite Telegram WebApp initData e restituisce JWT + saldi $OV."""
    user_data = verify_telegram_init_data(payload.init_data)

    telegram_id = user_data.get("id")
    if not telegram_id:
        raise HTTPException(status_code=400, detail="Invalid user data")

    result = await db.execute(select(User).where(User.telegram_id == telegram_id))
    user = result.scalar_one_or_none()

    if not user:
        user = User(
            telegram_id=telegram_id,
            username=user_data.get("username"),
            first_name=user_data.get("first_name"),
            language_code=user_data.get("language_code", "it"),
            is_premium=user_data.get("is_premium", False),
            balance_ov=0.0,
            balance_eur=0.0,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

    token = create_access_token({"sub": str(user.id), "tg": telegram_id})

    return TokenResponse(
        access_token=token,
        user_id=user.id,
        telegram_id=user.telegram_id,
        balance_ov=user.balance_ov,
        balance_eur=user.balance_eur,
    )
