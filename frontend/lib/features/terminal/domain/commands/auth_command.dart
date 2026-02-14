import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';
import '../../../auth/data/auth_repository.dart';

class AuthCommand implements CommandHandler {
  AuthCommand({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Future<List<TerminalLine>> execute(ParsedCommand command) async {
    switch (command.subcommand) {
      case 'login':
        return _login(command);
      case 'logout':
        return _logout();
      default:
        return const [
          TerminalLine(
            'Usage: auth <login|logout> [--github]',
            type: TerminalLineType.warning,
          ),
        ];
    }
  }

  Future<List<TerminalLine>> _login(ParsedCommand command) async {
    if (_authRepository.isAuthenticated) {
      final name =
          _authRepository.gitHubUserMeta?['user_name'] ?? 'unknown';
      return [
        TerminalLine(
          'Already authenticated as @$name',
          type: TerminalLineType.warning,
        ),
      ];
    }

    final hasGitHub = command.flags.containsKey('github');
    if (!hasGitHub) {
      return const [
        TerminalLine(
          'Usage: auth login --github',
          type: TerminalLineType.warning,
        ),
      ];
    }

    try {
      await _authRepository.signInWithGitHub();
      return const [
        TerminalLine(
          'Opening GitHub authorization...',
          type: TerminalLineType.system,
        ),
        TerminalLine(
          'Waiting for callback...',
          type: TerminalLineType.system,
        ),
      ];
    } catch (e) {
      return [
        TerminalLine(
          'AUTH ERROR: $e',
          type: TerminalLineType.error,
        ),
      ];
    }
  }

  Future<List<TerminalLine>> _logout() async {
    if (!_authRepository.isAuthenticated) {
      return const [
        TerminalLine(
          'Not currently authenticated.',
          type: TerminalLineType.warning,
        ),
      ];
    }

    try {
      await _authRepository.signOut();
      return const [
        TerminalLine('Signed out successfully.', type: TerminalLineType.success),
      ];
    } catch (e) {
      return [
        TerminalLine('LOGOUT ERROR: $e', type: TerminalLineType.error),
      ];
    }
  }
}
