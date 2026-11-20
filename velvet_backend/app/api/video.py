from fastapi import APIRouter

router = APIRouter()


@router.get("/library")
async def videoteca():
    """RED VELVET // VIDEOTECA REALE 4K (streaming placeholder)."""
    return {
        "node": "VPS NODE ACTIVE",
        "titles": [
            {"id": 1, "title": "Neon Desires: Chapter I", "type": "stream"},
            {"id": 2, "title": "Carne Viva: Orgia", "type": "stream", "age": 18},
            {"id": 3, "title": "Virtual Chambers (VR)", "type": "vr"},
        ],
        "streaming": "diretto tramite proxy protetto E2E",
    }


@router.get("/play/{title_id}")
async def play(title_id: int):
    return {
        "title_id": title_id,
        "stream_url": f"https://stream.ourvelvet.example/hls/{title_id}/index.m3u8",
        "protected": True,
    }
