from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.models import User, Post, Donation
from app.schemas.schemas import PostCreate, PostOut, DonationCreate
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/posts", response_model=PostOut)
async def create_post(
    data: PostCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = Post(
        author_id=current_user.id,
        title=data.title,
        description=data.description,
        media_url=data.media_url,
        is_locked=data.is_locked,
    )
    db.add(post)
    await db.commit()
    await db.refresh(post)
    return post


@router.get("/posts", response_model=list[PostOut])
async def list_posts(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Post).order_by(Post.created_at.desc()).limit(50)
    )
    return result.scalars().all()


@router.post("/donate")
async def donate(
    data: DonationCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Donazione in $OV (primaria) o EUR."""
    if data.currency not in ("OV", "EUR"):
        raise HTTPException(status_code=400, detail="Currency must be OV or EUR")

    result = await db.execute(select(User).where(User.id == data.to_user_id))
    receiver = result.scalar_one_or_none()
    if not receiver:
        raise HTTPException(status_code=404, detail="Receiver not found")

    if data.currency == "OV":
        if current_user.balance_ov < data.amount_ov:
            raise HTTPException(status_code=400, detail="Insufficient $OV balance")
        current_user.balance_ov -= data.amount_ov
        receiver.balance_ov += data.amount_ov
        amount_ov, amount_eur = data.amount_ov, 0.0
    else:
        if current_user.balance_eur < data.amount_eur:
            raise HTTPException(status_code=400, detail="Insufficient EUR balance")
        current_user.balance_eur -= data.amount_eur
        receiver.balance_eur += data.amount_eur
        amount_ov, amount_eur = 0.0, data.amount_eur

    donation = Donation(
        from_user_id=current_user.id,
        to_user_id=data.to_user_id,
        post_id=data.post_id,
        amount_ov=amount_ov,
        amount_eur=amount_eur,
        currency=data.currency,
    )
    db.add(donation)
    await db.commit()

    return {
        "status": "success",
        "currency": data.currency,
        "amount_ov": amount_ov,
        "amount_eur": amount_eur,
        "message": f"Donazione di {amount_ov or amount_eur} {data.currency} completata",
    }
