"""Pydantic request / response models for the DevDate API."""

from __future__ import annotations

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


# ═══════════════════════════════════════════════════════════════
#  AUTH
# ═══════════════════════════════════════════════════════════════

class GitHubOAuthURLResponse(BaseModel):
    """Returned by POST /auth/github — the URL the client opens."""
    url: str


class AuthCallbackRequest(BaseModel):
    """The code sent from the OAuth redirect."""
    code: str


class TokenResponse(BaseModel):
    """JWT pair returned after successful auth."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: ProfileResponse


class AuthMeResponse(BaseModel):
    """Returned by GET /auth/me."""
    id: str
    email: Optional[str] = None
    github_username: str
    avatar_url: Optional[str] = None


# ═══════════════════════════════════════════════════════════════
#  PROFILES
# ═══════════════════════════════════════════════════════════════

class ProfileResponse(BaseModel):
    """Public-facing profile representation."""
    id: str
    github_username: str
    display_name: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    tech_stack: list[str] = Field(default_factory=list)
    github_repos: list[dict] = Field(default_factory=list)
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    xp: int = 0
    rank: str = "Intern"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ProfileUpdateRequest(BaseModel):
    """Fields the user can update on their own profile."""
    display_name: Optional[str] = None
    bio: Optional[str] = None
    tech_stack: Optional[list[str]] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None


# ═══════════════════════════════════════════════════════════════
#  CONNECTIONS
# ═══════════════════════════════════════════════════════════════

class ConnectionCreateRequest(BaseModel):
    """Send a collab request to another developer."""
    target_username: str
    project_name: Optional[str] = None


class ConnectionUpdateRequest(BaseModel):
    """Accept or reject a connection."""
    status: str = Field(..., pattern="^(accepted|rejected)$")


class ConnectionResponse(BaseModel):
    """A connection between two developers."""
    id: str
    requester_id: str
    target_id: str
    status: str
    project_id: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


# ═══════════════════════════════════════════════════════════════
#  PROJECTS (placeholder for Phase 2+)
# ═══════════════════════════════════════════════════════════════

class ProjectResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    creator_id: str
    partner_id: Optional[str] = None
    status: str = "active"
    stars_count: int = 0
    published: bool = False
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


# ═══════════════════════════════════════════════════════════════
#  GENERIC
# ═══════════════════════════════════════════════════════════════

class MessageResponse(BaseModel):
    """Simple message wrapper."""
    message: str
