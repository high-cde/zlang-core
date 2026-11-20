from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db, AsyncSessionLocal
from app.models.models import Generation, User, ContentType
from app.schemas.schemas import GenerationCreate, GenerationOut
from app.api.deps import get_current_user
from app.services.agi_service import process_agi_generation

router = APIRouter()


@router.post("/generate", response_model=GenerationOut)
async def generate(
    data: GenerationCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Genera contenuto con OurVelvet AGI (foto / video / fumetti)."""
    try:
        ctype = ContentType(data.content_type.upper())
    except ValueError:
        ctype = ContentType.PHOTO

    gen = Generation(
        user_id=current_user.id,
        prompt=data.prompt,
        content_type=ctype,
        style=data.style,
        format_=data.format_,
        status="pending",
    )
    db.add(gen)
    await db.commit()
    await db.refresh(gen)

    # Avvia elaborazione in background con sessione dedicata
    background_tasks.add_task(process_agi_generation, gen.id)

    return gen


@router.get("/generations", response_model=list[GenerationOut])
async def my_generations(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Generation)
        .where(Generation.user_id == current_user.id)
        .order_by(Generation.created_at.desc())
        .limit(30)
    )
    return result.scalars().all()
