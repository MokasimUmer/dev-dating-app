from supabase import create_client, Client
from app.core.config import settings


def get_supabase_client() -> Client:
    """Create and return a Supabase client using the anon key (for user-facing operations)."""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)


def get_supabase_admin_client() -> Client:
    """Create and return a Supabase client using the service role key (for admin operations).
    
    WARNING: This client bypasses Row Level Security.
    Only use for server-side admin tasks (e.g. creating users, managing data).
    """
    if not settings.SUPABASE_SERVICE_KEY:
        raise ValueError("SUPABASE_SERVICE_KEY is not configured in .env")
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)


# Singleton instances (reused across the app)
supabase: Client = get_supabase_client()
