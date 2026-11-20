"""Servizio pagamenti / saldo $OV."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.models import User


async def credit_ov(db: AsyncSession, user_id: int, amount: float) -> User:
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one()
    user.balance_ov += amount
    await db.commit()
    await db.refresh(user)
    return user


async def debit_ov(db: AsyncSession, user_id: int, amount: float) -> User:
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one()
    if user.balance_ov < amount:
        raise ValueError("Insufficient $OV balance")
    user.balance_ov -= amount
    await db.commit()
    await db.refresh(user)
    return user
