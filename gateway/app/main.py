from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/v1/notify")
async def notify(payload: dict):
    return {"ok": True}
