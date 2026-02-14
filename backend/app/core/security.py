"""JWT validation and user extraction from Supabase tokens."""

from __future__ import annotations

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.core.config import settings
from app.infrastructure.supabase_client import supabase

# Supabase uses its own JWT secret (the project's JWT secret, not our SECRET_KEY).
# However, we can verify tokens by calling Supabase's auth.get_user(token).
# This is the most reliable approach because it also checks token revocation.

_bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
) -> dict:
    """FastAPI dependency that extracts and validates the Supabase JWT.

    Returns the user dict from Supabase (contains id, email, user_metadata, etc.).
    Raises 401 if the token is missing or invalid.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    try:
        # Ask Supabase to validate the token and return the user.
        # This handles expiration, revocation, etc.
        user_response = supabase.auth.get_user(token)
        user = user_response.user

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        return {
            "id": user.id,
            "email": user.email,
            "user_metadata": user.user_metadata,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token validation failed: {str(e)}",
        )


async def get_current_user_id(
    user: dict = Depends(get_current_user),
) -> str:
    """Convenience dependency that returns just the user UUID string."""
    return user["id"]
