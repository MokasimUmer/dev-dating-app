"""Auth API routes — GitHub OAuth via Supabase."""

from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.security import get_current_user
from app.domain.schemas import (
    AuthCallbackRequest,
    AuthMeResponse,
    GitHubOAuthURLResponse,
    MessageResponse,
    TokenResponse,
)
from app.services.auth_service import AuthService
from app.services.profile_service import ProfileService

router = APIRouter()


@router.post("/github", response_model=GitHubOAuthURLResponse)
async def github_oauth_url(redirect_to: str = Query(default="")):
    """Return the Supabase GitHub OAuth URL.

    The mobile/web client opens this in a browser. After the user
    authorizes on GitHub, Supabase redirects back with a code.
    """
    url = AuthService.get_github_oauth_url(redirect_to=redirect_to)
    return GitHubOAuthURLResponse(url=url)


@router.post("/callback")
async def auth_callback(body: AuthCallbackRequest):
    """Exchange an OAuth code for a Supabase session.

    Called after the GitHub OAuth redirect delivers the code.
    Returns JWT access/refresh tokens and the user's profile.
    """
    try:
        session_data = await AuthService.exchange_code_for_session(body.code)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Kick off GitHub enrichment in the background (non-blocking best-effort)
    user_info = session_data["user"]
    try:
        await ProfileService.enrich_from_github(
            user_id=user_info["id"],
            github_username=user_info["github_username"],
        )
    except Exception:
        pass  # Non-critical: enrichment can retry later

    return session_data


@router.get("/me", response_model=AuthMeResponse)
async def get_me(user: dict = Depends(get_current_user)):
    """Return the authenticated user's basic info."""
    profile = await AuthService.get_user_profile(user)
    return AuthMeResponse(
        id=profile.get("id", user["id"]),
        email=user.get("email"),
        github_username=profile.get("github_username", "unknown"),
        avatar_url=profile.get("avatar_url"),
    )


@router.post("/logout", response_model=MessageResponse)
async def logout(user: dict = Depends(get_current_user)):
    """Sign out the current user (invalidate session on Supabase)."""
    # We don't have the raw token easily here, but the client should
    # clear its local tokens. This endpoint confirms intent.
    return MessageResponse(message="Logged out successfully")
