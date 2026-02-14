"""Profile API routes."""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from app.core.security import get_current_user, get_current_user_id
from app.domain.schemas import ProfileResponse, ProfileUpdateRequest, MessageResponse
from app.services.profile_service import ProfileService

router = APIRouter()


@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(user_id: str = Depends(get_current_user_id)):
    """Get the authenticated user's full profile."""
    profile = await ProfileService.get_profile(user_id)
    if profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return ProfileResponse(**profile)


@router.put("/me", response_model=ProfileResponse)
async def update_my_profile(
    body: ProfileUpdateRequest,
    user_id: str = Depends(get_current_user_id),
):
    """Update the authenticated user's profile."""
    updated = await ProfileService.update_profile(
        user_id=user_id,
        data=body.model_dump(exclude_unset=True),
    )
    if not updated:
        raise HTTPException(status_code=404, detail="Profile not found")
    return ProfileResponse(**updated)


@router.get("/{username}", response_model=ProfileResponse)
async def get_profile_by_username(username: str):
    """Get a public profile by GitHub username."""
    profile = await ProfileService.get_profile_by_username(username)
    if profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return ProfileResponse(**profile)


@router.get("/", response_model=list[ProfileResponse])
async def discover_profiles(
    tech: Optional[str] = Query(default=None, description="Filter by technology"),
    limit: int = Query(default=20, ge=1, le=100),
):
    """Discover developer profiles. Optionally filter by tech stack."""
    profiles = await ProfileService.discover(tech=tech, limit=limit)
    return [ProfileResponse(**p) for p in profiles]


@router.post("/me/enrich", response_model=MessageResponse)
async def enrich_my_profile(
    user: dict = Depends(get_current_user),
    user_id: str = Depends(get_current_user_id),
):
    """Re-fetch GitHub repos and languages to update the profile."""
    meta = user.get("user_metadata", {})
    username = meta.get("user_name")
    if not username:
        raise HTTPException(
            status_code=400,
            detail="GitHub username not found in auth metadata",
        )

    await ProfileService.enrich_from_github(
        user_id=user_id,
        github_username=username,
    )
    return MessageResponse(message=f"Profile enriched from GitHub (@{username})")
