import os
from fastapi import FastAPI

app = FastAPI()

NTFY_BASE_URL = os.getenv("NTFY_BASE_URL")
DEFAULT_TENANT_ID = os.getenv("DEFAULT_TENANT_ID", "default")


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/v1/notify")
async def notify(payload: dict):
    audience = payload.get("audience") or {}
    audience_type = audience.get("type")
    audience_id = audience.get("id")
    message = payload.get("message")

    topic = f"t_{DEFAULT_TENANT_ID}.{audience_type}.{audience_id}"

    return {"ok": True, "topic": topic, "message": message, "published": False}
