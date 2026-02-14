"""GitHub API client for fetching user data after OAuth."""

from __future__ import annotations

import httpx

GITHUB_API = "https://api.github.com"


class GitHubClient:
    """Lightweight async client for the GitHub REST API."""

    def __init__(self, access_token: str | None = None):
        self._headers = {
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }
        if access_token:
            self._headers["Authorization"] = f"Bearer {access_token}"

    async def get_user(self, username: str) -> dict:
        """Fetch a GitHub user's public profile."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{GITHUB_API}/users/{username}",
                headers=self._headers,
            )
            resp.raise_for_status()
            return resp.json()

    async def get_user_repos(
        self, username: str, limit: int = 10
    ) -> list[dict]:
        """Fetch a user's public repos sorted by most recently pushed."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{GITHUB_API}/users/{username}/repos",
                headers=self._headers,
                params={
                    "sort": "pushed",
                    "direction": "desc",
                    "per_page": limit,
                    "type": "owner",
                },
            )
            resp.raise_for_status()
            repos = resp.json()

        return [
            {
                "name": r["name"],
                "full_name": r["full_name"],
                "description": r["description"],
                "language": r["language"],
                "stars": r["stargazers_count"],
                "url": r["html_url"],
                "updated_at": r["pushed_at"],
            }
            for r in repos
        ]

    async def get_user_languages(self, username: str) -> list[str]:
        """Extract unique languages from a user's top repos."""
        repos = await self.get_user_repos(username, limit=20)
        languages = {r["language"] for r in repos if r["language"]}
        return sorted(languages)
