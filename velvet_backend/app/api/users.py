from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.models import User
from app.schemas.schemas import UserPublic
from app.api.deps import get_current_user

router = APIRouter()


@router.get("/me", response_model=UserPublic)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/balance")
async def get_balance(current_user: User = Depends(get_current_user)):
    """Saldi: $OV (primaria) + EUR."""
    return {
        "primary_currency": "OV",
        "balance_ov": current_user.balance_ov,
        "balance_eur": current_user.balance_eur,
        "symbol": "$OV",
    }
