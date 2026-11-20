"""Servizio AGI – elaborazione generazioni in background."""
from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.models.models import Generation


async def process_agi_generation(generation_id: int):
    """Placeholder: in produzione chiama l'API AGI esterna (uncensored)."""
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(Generation).where(Generation.id == generation_id)
        )
        gen = result.scalar_one_or_none()
        if not gen:
            return

        # Simula chiamata AGI
        gen.status = "processing"
        await db.commit()

        # Risultato finale (sostituisci con chiamata reale)
        gen.status = "completed"
        gen.result_url = f"https://cdn.ourvelvet.example/gen/{generation_id}.jpg"
        await db.commit()
