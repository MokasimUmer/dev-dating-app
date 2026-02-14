import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../domain/auth_bloc.dart';
import '../domain/auth_event.dart';
import '../domain/auth_state.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _signUp() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    context.read<AuthBloc>().add(AuthSignUpWithEmailEvent(
          email: email,
          password: password,
          username: username,
          displayName: username,
        ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Fira Code',
            color: TerminalColors.white,
            fontSize: 12,
          ),
        ),
        backgroundColor: TerminalColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Fira Code',
            color: TerminalColors.background,
            fontSize: 12,
          ),
        ),
        backgroundColor: TerminalColors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          _showError(state.message);
        }
        if (state is AuthSignUpSuccessState) {
          _showSuccess('Account created! Check your email to verify.');
          // Navigate back to login after short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _goToLogin();
          });
        }
      },
      child: Scaffold(
        backgroundColor: TerminalColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 44),

                  // ── Logo + Title ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color:
                                TerminalColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: TerminalColors.green
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: TerminalColors.green,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Join DevDate',
                          style: TextStyle(
                            fontFamily: 'Fira Code',
                            color: TerminalColors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Create your developer profile',
                          style: TextStyle(
                            fontFamily: 'Fira Code',
                            color: TerminalColors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Username Field ───────────────────────────
                  const Text(
                    'Username',
                    style: TextStyle(
                      color: TerminalColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _usernameController,
                    hint: 'your_dev_handle',
                    icon: Icons.alternate_email,
                  ),

                  const SizedBox(height: 18),

                  // ── Email Field ──────────────────────────────
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: TerminalColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _emailController,
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  // ── Password Field ───────────────────────────
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: TerminalColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _passwordController,
                    hint: 'Min 6 characters',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TerminalColors.grey,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Confirm Password Field ───────────────────
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: TerminalColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _confirmController,
                    hint: 'Repeat password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TerminalColors.grey,
                        size: 20,
                      ),
                    ),
                    onSubmitted: (_) => _signUp(),
                  ),

                  const SizedBox(height: 28),

                  // ── Sign Up Button ───────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoadingState;
                      return GestureDetector(
                        onTap: isLoading ? null : _signUp,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: TerminalColors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: TerminalColors.green
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: TerminalColors.background,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: TerminalColors.background,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: TerminalColors.surface,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            color: TerminalColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: TerminalColors.surface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── GitHub Button ────────────────────────────
                  GestureDetector(
                    onTap: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthLoginWithGitHubEvent());
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: TerminalColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              TerminalColors.dimGreen.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.code,
                            color: TerminalColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Sign up with GitHub',
                            style: TextStyle(
                              color: TerminalColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Login Link ───────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _goToLogin,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Fira Code',
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Already have an account? ',
                              style:
                                  TextStyle(color: TerminalColors.grey),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: TerminalColors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Input Field Widget ────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TerminalColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TerminalColors.dimGreen.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: TerminalColors.white,
          fontSize: 14,
        ),
        cursorColor: TerminalColors.green,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: TerminalColors.grey.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: TerminalColors.grey, size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 20, minHeight: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
