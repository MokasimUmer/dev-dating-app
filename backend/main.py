from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import auth, matches, chat, profiles
from app.infrastructure.supabase_client import supabase

app = FastAPI(
    title="Dev Dating API",
    description="Backend API for developer dating app",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(profiles.router, prefix="/api/v1/profiles", tags=["profiles"])
app.include_router(matches.router, prefix="/api/v1/matches", tags=["matches"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["chat"])


@app.get("/")
async def root():
    return {"message": "Dev Dating API is running"}


@app.get("/health")
async def health_check():
    """Health check that also verifies the Supabase connection."""
    try:
        # Try a lightweight query to confirm Supabase is reachable
        result = supabase.table("_health_check").select("*").limit(1).execute()
        supabase_status = "connected"
    except Exception as e:
        # Even if the table doesn't exist, a 404/relation error means Supabase IS reachable
        error_msg = str(e)
        if "relation" in error_msg or "does not exist" in error_msg:
            supabase_status = "connected"
        else:
            supabase_status = f"error: {error_msg}"
    return {"status": "healthy", "supabase": supabase_status}
