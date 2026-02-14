import 'package:equatable/equatable.dart';

/// Possible states emitted by [AuthBloc].
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — haven't checked auth yet.
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// Checking stored session.
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// User is authenticated.
class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState({
    required this.username,
    this.avatarUrl,
  });

  final String username;
  final String? avatarUrl;

  @override
  List<Object?> get props => [username, avatarUrl];
}

/// User is not authenticated.
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

/// Sign up succeeded — user needs to verify email.
class AuthSignUpSuccessState extends AuthState {
  const AuthSignUpSuccessState();
}

/// Auth operation failed.
class AuthErrorState extends AuthState {
  const AuthErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
