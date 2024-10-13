import hashlib

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException, Request, Response, Header
from fastapi.staticfiles import StaticFiles
import aiohttp
import asyncio

class CustomMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # Add custom request processing logic here
        print(f"Incoming request: {request.url}")
        
        # Example: Hashing a part of the URL for some reason
        # url_hash = hashlib.sha256(str(request.url).encode()).hexdigest()
        # print(f"URL Hash: {url_hash}")

        response = await call_next(request)

        # Add custom response processing logic here
        # response.headers["X-URL-Hash"] = url_hash
        return response
    
app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this to your needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Add the custom middleware to the app
app.add_middleware(CustomMiddleware)

# Serve static files (e.g., JupyterLite)
app.mount("/", StaticFiles(directory="_output/", html=True), name="jupyterlite")

# Run the FastAPI server
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)