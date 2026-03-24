import os

import httpx
from fastapi import FastAPI

app = FastAPI()

NTFY_BASE_URL = os.getenv("NTFY_BASE_URL", "http://ntfy")
DEFAULT_TENANT_ID = os.getenv("DEFAULT_TENANT_ID", "default")


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/v1/notify")
async def notify(payload: dict):
    audience = payload.get("audience") or {}
    audience_type = audience.get("type")
    audience_id = audience.get("id")
    message = payload.get("message") or ""

    topic = f"t_{DEFAULT_TENANT_ID}.{audience_type}.{audience_id}"
    url = f"{NTFY_BASE_URL.rstrip('/')}/{topic}"

    async with httpx.AsyncClient(timeout=10) as client:
        r = await client.post(url, content=message.encode("utf-8"))

    return {"ok": r.is_success, "topic": topic, "published": r.is_success}
