import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../domain/auth_bloc.dart';
import '../domain/auth_state.dart';
import 'login_screen.dart';
import '../../navigation/presentation/main_navigation.dart';

/// Animated splash screen — the app's entry point.
///
/// Flow: Logo animation -> auth check -> routes to Login or Main app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool _showTagline = false;
  bool _showDots = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // Content animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: Logo appears
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Phase 2: Title + tagline slide in
    _contentController.forward();
    setState(() => _showTagline = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Phase 3: Show loading indicator
    setState(() => _showDots = true);

    // Phase 4: Wait for auth check, then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    if (_navigated) return;
    _navigated = true;

    final authState = context.read<AuthBloc>().state;
    final Widget destination;

    if (authState is AuthAuthenticatedState) {
      destination = const MainNavigation();
    } else {
      destination = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // If auth check finishes while splash is showing, navigate
        if (_showDots &&
            !_navigated &&
            (state is AuthAuthenticatedState ||
                state is AuthUnauthenticatedState)) {
          Future.delayed(const Duration(milliseconds: 300), _navigate);
        }
      },
      child: Scaffold(
        backgroundColor: TerminalColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated Logo ───────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TerminalColors.green.withValues(alpha: 0.2),
                          TerminalColors.dimGreen.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: TerminalColors.green.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              TerminalColors.green.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: TerminalColors.green,
                      size: 44,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title + Tagline ─────────────────────────
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      const Text(
                        'DevDate',
                        style: TextStyle(
                          fontFamily: 'Fira Code',
                          color: TerminalColors.green,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _showTagline ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: const Text(
                          'Find your perfect merge conflict.',
                          style: TextStyle(
                            fontFamily: 'Fira Code',
                            color: TerminalColors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Loading Indicator ───────────────────────
              AnimatedOpacity(
                opacity: _showDots ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TerminalColors.green.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
