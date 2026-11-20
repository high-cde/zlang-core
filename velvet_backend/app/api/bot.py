from fastapi import APIRouter, Request, HTTPException
from aiogram import Bot, Dispatcher, types
from aiogram.filters import CommandStart

from app.core.config import settings

router = APIRouter()

# Bot instance (inizializzato solo se token presente)
bot: Bot | None = None
dp: Dispatcher | None = None

if settings.BOT_TOKEN:
    bot = Bot(token=settings.BOT_TOKEN)
    dp = Dispatcher()

    @dp.message(CommandStart())
    async def cmd_start(message: types.Message):
        await message.answer(
            "Benvenuto in <b>OurVelvet</b>\n"
            "Generazione AGI illimitata, Creator Hub & $OV\n\n"
            "Apri la Mini App per entrare nella griglia.",
            parse_mode="HTML",
        )


@router.post("/webhook")
async def telegram_webhook(request: Request):
    """Webhook Telegram Bot."""
    if not bot or not dp:
        raise HTTPException(status_code=503, detail="Bot not configured")

    update = await request.json()
    telegram_update = types.Update(**update)
    await dp.feed_update(bot, telegram_update)
    return {"ok": True}
