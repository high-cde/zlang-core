from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.models import Match, User
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/scan")
async def radar_scan(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Il Radar della Carne // 1KM MATCHMAKING.
    Placeholder: restituisce utenti vicini (in produzione usa geolocalizzazione).
    """
    result = await db.execute(
        select(User).where(User.id != current_user.id).limit(5)
    )
    nearby = result.scalars().all()

    matches = []
    for u in nearby:
        matches.append({
            "user_id": u.id,
            "username": u.username or u.first_name,
            "distance_km": 0.4,  # placeholder
        })

    return {
        "status": "scan_complete",
        "radius_km": 1,
        "access": "3/3",
        "results": matches,
        "message": "Nessun corpo agganciato." if not matches else f"{len(matches)} corpi rilevati",
    }


@router.get("/matches")
async def my_matches(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Match).where(
            (Match.user_a_id == current_user.id) | (Match.user_b_id == current_user.id)
        )
    )
    return result.scalars().all()
