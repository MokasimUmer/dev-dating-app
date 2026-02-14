import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Manages authentication lifecycle.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitialState()) {
    on<AuthCheckRequestedEvent>(_onCheckRequested);
    on<AuthLoginWithGitHubEvent>(_onLoginWithGitHub);
    on<AuthLoginWithEmailEvent>(_onLoginWithEmail);
    on<AuthSignUpWithEmailEvent>(_onSignUpWithEmail);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthStateChangedEvent>(_onAuthStateChanged);

    // Listen to Supabase auth stream and forward events.
    _authSubscription = _authRepository.onAuthStateChange.listen((data) {
      final session = data.session;
      add(AuthStateChangedEvent(isAuthenticated: session != null));
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<supa.AuthState> _authSubscription;

  Future<void> _onCheckRequested(
    AuthCheckRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      if (_authRepository.isAuthenticated) {
        final meta = _authRepository.gitHubUserMeta;
        emit(AuthAuthenticatedState(
          username: meta?['user_name'] ?? meta?['email'] ?? 'dev',
          avatarUrl: meta?['avatar_url'],
        ));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoginWithGitHub(
    AuthLoginWithGitHubEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      await _authRepository.signInWithGitHub();
      // The result comes asynchronously via the auth state stream.
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoginWithEmail(
    AuthLoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final response = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (response.session != null) {
        final user = response.user;
        final meta = user?.userMetadata;
        emit(AuthAuthenticatedState(
          username: meta?['user_name'] ?? user?.email ?? 'dev',
          avatarUrl: meta?['avatar_url'],
        ));
      } else {
        emit(const AuthErrorState(message: 'Login failed. Check your credentials.'));
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('Invalid login credentials')) {
        message = 'Invalid email or password';
      } else if (message.contains('Email not confirmed')) {
        message = 'Please verify your email first';
      }
      emit(AuthErrorState(message: message));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final response = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        username: event.username,
        displayName: event.displayName,
      );

      if (response.user != null) {
        if (response.session != null) {
          // Auto-confirmed — go straight to authenticated
          final meta = response.user!.userMetadata;
          emit(AuthAuthenticatedState(
            username: meta?['user_name'] ?? event.username ?? 'dev',
            avatarUrl: meta?['avatar_url'],
          ));
        } else {
          // Needs email confirmation
          emit(const AuthSignUpSuccessState());
        }
      } else {
        emit(const AuthErrorState(message: 'Sign up failed. Please try again.'));
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('already registered')) {
        message = 'This email is already registered';
      } else if (message.contains('Password should be')) {
        message = 'Password must be at least 6 characters';
      }
      emit(AuthErrorState(message: message));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  void _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    if (event.isAuthenticated) {
      final meta = _authRepository.gitHubUserMeta;
      emit(AuthAuthenticatedState(
        username: meta?['user_name'] ?? 'dev',
        avatarUrl: meta?['avatar_url'],
      ));
    } else {
      emit(const AuthUnauthenticatedState());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
