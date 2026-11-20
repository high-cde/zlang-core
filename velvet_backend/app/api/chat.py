from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.models import ChatMessage, User
from app.schemas.schemas import ChatMessageCreate
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/send")
async def send_message(
    data: ChatMessageCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Palcoscenico & Chat // K.I.R.A. SHIELD"""
    msg = ChatMessage(
        room=data.room,
        user_id=current_user.id,
        message=data.message,
    )
    db.add(msg)
    await db.commit()
    await db.refresh(msg)
    return {"status": "sent", "id": msg.id}


@router.get("/messages")
async def get_messages(
    room: str = "global",
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.room == room)
        .order_by(ChatMessage.created_at.desc())
        .limit(50)
    )
    messages = result.scalars().all()
    return [
        {
            "id": m.id,
            "user_id": m.user_id,
            "message": m.message,
            "is_system": m.is_system,
            "created_at": m.created_at,
        }
        for m in reversed(messages)
    ]


@router.get("/welcome")
async def welcome():
    return {
        "system": "[K.I.R.A.]: Benvenuti nella chat. Libertà totale e perversione protetta.",
        "shield": "ACTIVE",
    }
