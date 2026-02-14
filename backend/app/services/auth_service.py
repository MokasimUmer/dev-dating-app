"""Auth business logic — GitHub OAuth via Supabase."""

from __future__ import annotations

from app.core.config import settings
from app.infrastructure.supabase_client import supabase, get_supabase_admin_client


class AuthService:
    """Handles GitHub OAuth flow through Supabase Auth."""

    @staticmethod
    def get_github_oauth_url(redirect_to: str | None = None) -> str:
        """Return the Supabase-hosted GitHub OAuth URL.

        The client (Flutter app) should open this URL in a browser/WebView.
        After consent, Supabase redirects back with an auth code.
        """
        # Supabase client-side OAuth URL
        base = settings.SUPABASE_URL
        url = (
            f"{base}/auth/v1/authorize"
            f"?provider=github"
            f"&redirect_to={redirect_to or ''}"
        )
        return url

    @staticmethod
    async def exchange_code_for_session(code: str) -> dict:
        """Exchange an OAuth code for a Supabase session (access + refresh tokens).

        This is called when the OAuth redirect sends the code back to the backend.
        """
        try:
            response = supabase.auth.exchange_code_for_session({"auth_code": code})
            session = response.session
            user = response.user

            if session is None or user is None:
                raise ValueError("Failed to exchange code — no session returned")

            return {
                "access_token": session.access_token,
                "refresh_token": session.refresh_token,
                "expires_in": session.expires_in,
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "github_username": user.user_metadata.get("user_name", "unknown"),
                    "display_name": user.user_metadata.get("full_name"),
                    "avatar_url": user.user_metadata.get("avatar_url"),
                },
            }
        except Exception as e:
            raise ValueError(f"Code exchange failed: {str(e)}")

    @staticmethod
    async def get_user_profile(user: dict) -> dict:
        """Get the profile row for the authenticated user."""
        user_id = user["id"]

        result = (
            supabase.table("profiles")
            .select("*")
            .eq("id", user_id)
            .maybe_single()
            .execute()
        )

        if result.data is None:
            # Profile might not exist yet if trigger hasn't fired
            meta = user.get("user_metadata", {})
            return {
                "id": user_id,
                "email": user.get("email"),
                "github_username": meta.get("user_name", "unknown"),
                "avatar_url": meta.get("avatar_url"),
            }

        return result.data

    @staticmethod
    async def sign_out(token: str) -> None:
        """Invalidate a user's session on Supabase side."""
        try:
            admin = get_supabase_admin_client()
            # Sign out via admin to ensure token is revoked
            admin.auth.admin.sign_out(token)
        except Exception:
            # Best-effort; client should also clear local tokens
            pass
