import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository that wraps all Supabase Auth operations.
class AuthRepository {
  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Current session (null if not logged in).
  Session? get currentSession => _client.auth.currentSession;

  /// Current user (null if not logged in).
  User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isAuthenticated => currentSession != null;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  /// Sign in with GitHub OAuth.
  Future<void> signInWithGitHub() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.supabase.devdate://login-callback/',
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (username != null) 'user_name': username,
        if (displayName != null) 'full_name': displayName,
      },
    );
    return response;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get user metadata from the GitHub OAuth response.
  Map<String, dynamic>? get gitHubUserMeta {
    return currentUser?.userMetadata;
  }
}
