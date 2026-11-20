# VelvetHub / OurVelvet Backend

Backend FastAPI per il bot Telegram + Mini App **OurVelvet**.

## Moneta primaria
**$OV** è la moneta primaria dell'ecosistema (saldi, donazioni, Creator Hub).  
EUR è supportata come secondaria.

## Funzionalità
- Auth Telegram WebApp (`initData` → JWT)
- Saldi `$OV` / EUR
- AGI Generator (foto / video / fumetti) – placeholder per API esterna uncensored
- Creator & Fan Hub + donazioni in `$OV`
- Feed Notizie al Femminile
- Radar della Carne (1 km matchmaking)
- Safe Chat / K.I.R.A. Shield
- Videoteca Reale 4K

## Integrità referenziale
- FK con `ON DELETE CASCADE` (user → posts, generations, donations, matches, chat)
- FK `ON DELETE SET NULL` per `donations.post_id`
- Check: saldi `$OV`/EUR ≥ 0, importi ≥ 0, moneta singola
- Unique su coppie match (`user_a_id < user_b_id`)
- Indici su tutte le colonne FK

## Migrazioni Alembic
```bash
# Applica schema iniziale
alembic upgrade head

# Nuova revisione dopo modifiche ai modelli
alembic revision --autogenerate -m "descrizione"
alembic upgrade head
```

## Avvio locale
```bash
cd velvet_backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# .env
echo "BOT_TOKEN=your_bot_token" > .env
echo "DATABASE_URL=postgresql+asyncpg://velvet:velvet@localhost:5432/velvetdb" >> .env

uvicorn app.main:app --reload
```

## Endpoint principali
- `POST /api/auth/telegram` – login Mini App
- `GET  /api/users/me` – profilo + saldi `$OV`
- `POST /api/agi/generate` – genera contenuto
- `POST /api/hub/donate` – dona in `$OV` o EUR
- `POST /api/radar/scan` – radar 1 km
- `POST /api/chat/send` – chat protetta
- `POST /api/bot/webhook` – webhook Telegram Bot

Tutto innestato: auth, wallet $OV, AGI service, hub, radar, chat, videoteca e bot webhook.
