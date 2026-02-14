import 'package:get_it/get_it.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_bloc.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/profile_bloc.dart';
import '../../features/connections/data/connection_repository.dart';
import '../../features/home/domain/home_bloc.dart';
import '../../features/discover/domain/discover_bloc.dart';
import '../../features/terminal/domain/terminal_bloc.dart';

final getIt = GetIt.instance;

/// Register all dependencies. Call once before `runApp`.
void configureDependencies() {
  // ── Repositories ──────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());
  getIt.registerLazySingleton<ConnectionRepository>(
      () => ConnectionRepository());

  // ── BLoCs ─────────────────────────────────────────────────
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<TerminalBloc>(
    () => TerminalBloc(
      authRepository: getIt<AuthRepository>(),
      profileRepository: getIt<ProfileRepository>(),
      connectionRepository: getIt<ConnectionRepository>(),
    ),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      profileRepository: getIt<ProfileRepository>(),
      connectionRepository: getIt<ConnectionRepository>(),
    ),
  );

  getIt.registerFactory<DiscoverBloc>(
    () => DiscoverBloc(
      profileRepository: getIt<ProfileRepository>(),
      connectionRepository: getIt<ConnectionRepository>(),
    ),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      profileRepository: getIt<ProfileRepository>(),
      connectionRepository: getIt<ConnectionRepository>(),
    ),
  );
}
