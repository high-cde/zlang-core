from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.models import Post
from app.schemas.schemas import PostOut

router = APIRouter()


@router.get("/news", response_model=list[PostOut])
async def news_feed(db: AsyncSession = Depends(get_db)):
    """Feed Notizie al Femminile (placeholder: usa post pubblici)."""
    result = await db.execute(
        select(Post).order_by(Post.created_at.desc()).limit(20)
    )
    return result.scalars().all()


@router.get("/articles")
async def articles():
    """Articoli statici / dinamici (make-up, sociologia, pornografia estrema, ecc.)."""
    return [
        {
            "category": "MAKE-UP & ESTETICA",
            "title": "Cyber-Gothic Makeup: Tendenze e Lavorazioni in Latta",
            "excerpt": "Come ridefinire i tratti del viso con pigmenti riflettenti...",
        },
        {
            "category": "SOCIOLOGIA & POTERE",
            "title": "Femminismo Radicale e Piacere Autonomo nel 2026",
            "excerpt": "Perché le donne stanno riprendendo il controllo totale...",
        },
        {
            "category": "PORNOGRAFIA ESTREMA",
            "title": "L'Evoluzione del Porn Glamour verso il BDSM Immersivo",
            "excerpt": "Un'analisi senza censure sulla transizione...",
        },
    ]
