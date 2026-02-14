import 'package:equatable/equatable.dart';

/// Events that can be dispatched to [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if a session already exists (on app startup).
class AuthCheckRequestedEvent extends AuthEvent {
  const AuthCheckRequestedEvent();
}

/// User initiated GitHub OAuth login.
class AuthLoginWithGitHubEvent extends AuthEvent {
  const AuthLoginWithGitHubEvent();
}

/// User initiated email + password login.
class AuthLoginWithEmailEvent extends AuthEvent {
  const AuthLoginWithEmailEvent({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// User initiated email + password sign up.
class AuthSignUpWithEmailEvent extends AuthEvent {
  const AuthSignUpWithEmailEvent({
    required this.email,
    required this.password,
    this.username,
    this.displayName,
  });

  final String email;
  final String password;
  final String? username;
  final String? displayName;

  @override
  List<Object?> get props => [email, password, username, displayName];
}

/// User requested logout.
class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

/// Auth state changed externally (e.g. OAuth callback received).
class AuthStateChangedEvent extends AuthEvent {
  const AuthStateChangedEvent({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}
