import hashlib
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
import aiohttp
import asyncio

from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

# Serve static files (e.g., JupyterLite)
app.mount("/", StaticFiles(directory="_output/", html=True), name="jupyterlite")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this to your needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Run the FastAPI server
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8001, reload=True)