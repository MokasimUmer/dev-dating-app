import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview/device_preview.dart';

import 'core/config.dart';
import 'core/di/injection.dart';
import 'core/theme/terminal_theme.dart';
import 'features/auth/domain/auth_bloc.dart';
import 'features/auth/domain/auth_event.dart';
import 'features/navigation/presentation/main_navigation.dart';
import 'features/terminal/domain/terminal_bloc.dart';
import 'features/home/domain/home_bloc.dart';
import 'features/discover/domain/discover_bloc.dart';
import 'features/profile/domain/profile_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  configureDependencies();

  runApp(
    DevicePreview(
      enabled: kIsWeb || kDebugMode,
      backgroundColor: const Color(0xFF120A10),
      builder: (context) => const DevDateApp(),
    ),
  );
}

class DevDateApp extends StatelessWidget {
  const DevDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              getIt<AuthBloc>()..add(const AuthCheckRequestedEvent()),
        ),
        BlocProvider<TerminalBloc>(
          create: (_) => getIt<TerminalBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>(),
        ),
        BlocProvider<DiscoverBloc>(
          create: (_) => getIt<DiscoverBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'DevDate',
        debugShowCheckedModeBanner: false,
        theme: terminalTheme(),
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        // ── Entry Point: Main Navigation ────────────────
        home: const MainNavigation(),
      ),
    );
  }
}
