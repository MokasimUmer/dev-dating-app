"""Profile business logic — CRUD and GitHub enrichment."""

from __future__ import annotations

from app.infrastructure.supabase_client import supabase
from app.infrastructure.github_client import GitHubClient


class ProfileService:
    """Handles profile reads, updates, and GitHub data enrichment."""

    @staticmethod
    async def get_profile(user_id: str) -> dict | None:
        """Fetch a profile by user ID."""
        result = (
            supabase.table("profiles")
            .select("*")
            .eq("id", user_id)
            .maybe_single()
            .execute()
        )
        return result.data

    @staticmethod
    async def get_profile_by_username(username: str) -> dict | None:
        """Fetch a profile by GitHub username."""
        result = (
            supabase.table("profiles")
            .select("*")
            .eq("github_username", username)
            .maybe_single()
            .execute()
        )
        return result.data

    @staticmethod
    async def update_profile(user_id: str, data: dict) -> dict:
        """Update fields on the current user's profile."""
        # Filter out None values
        update_data = {k: v for k, v in data.items() if v is not None}
        if not update_data:
            # Nothing to update, just return current
            return await ProfileService.get_profile(user_id)  # type: ignore

        result = (
            supabase.table("profiles")
            .update(update_data)
            .eq("id", user_id)
            .execute()
        )
        return result.data[0] if result.data else {}

    @staticmethod
    async def enrich_from_github(user_id: str, github_username: str) -> dict:
        """Pull repos and languages from GitHub and save to profile.

        Called after first OAuth login to populate tech_stack and github_repos.
        """
        gh = GitHubClient()

        try:
            repos = await gh.get_user_repos(github_username, limit=10)
            languages = await gh.get_user_languages(github_username)
        except Exception:
            # GitHub API might rate-limit or fail — non-critical
            return {}

        update_data = {
            "github_repos": repos,
            "tech_stack": languages,
        }

        result = (
            supabase.table("profiles")
            .update(update_data)
            .eq("id", user_id)
            .execute()
        )
        return result.data[0] if result.data else {}

    @staticmethod
    async def discover(
        tech: str | None = None,
        limit: int = 20,
    ) -> list[dict]:
        """Discover developer profiles, optionally filtered by tech stack."""
        query = supabase.table("profiles").select("*")

        if tech:
            query = query.contains("tech_stack", [tech])

        query = query.limit(limit)
        result = query.execute()
        return result.data or []
