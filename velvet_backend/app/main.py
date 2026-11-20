"""
VelvetHub / OurVelvet Backend
Telegram Mini App + Bot support
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager
import os

from app.core.config import settings
from app.core.database import engine, Base
# Models registered via Alembic env.py; tables managed by migrations
from app.api import auth, users, agi, hub, feed, radar, chat, video, bot


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Tables managed by Alembic migrations (alembic upgrade head)
    yield
    await engine.dispose()


app = FastAPI(
    title="VelvetHub Backend",
    description="Backend for OurVelvet AGI Creator Hub & Telegram Mini App",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(agi.router, prefix="/api/agi", tags=["agi"])
app.include_router(hub.router, prefix="/api/hub", tags=["hub"])
app.include_router(feed.router, prefix="/api/feed", tags=["feed"])
app.include_router(radar.router, prefix="/api/radar", tags=["radar"])
app.include_router(chat.router, prefix="/api/chat", tags=["chat"])
app.include_router(video.router, prefix="/api/video", tags=["video"])
app.include_router(bot.router, prefix="/api/bot", tags=["bot"])

# Serve Mini App
miniapp_path = os.path.join(os.path.dirname(__file__), "..", "miniapp")
if os.path.isdir(miniapp_path):
    app.mount("/miniapp", StaticFiles(directory=miniapp_path, html=True), name="miniapp")

@app.get("/app")
async def miniapp_redirect():
    return FileResponse(os.path.join(miniapp_path, "index.html"))


@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "VelvetHub",
        "message": "OurVelvet AGI Creator Hub // $OV Ecosystem",
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}
