import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../connections/data/connection_repository.dart';

class CollabCommand implements CommandHandler {
  CollabCommand({
    required AuthRepository authRepository,
    required ConnectionRepository connectionRepository,
  })  : _authRepository = authRepository,
        _connectionRepository = connectionRepository;

  final AuthRepository _authRepository;
  final ConnectionRepository _connectionRepository;

  @override
  Future<List<TerminalLine>> execute(ParsedCommand command) async {
    if (!_authRepository.isAuthenticated) {
      return const [
        TerminalLine(
          'Not authenticated. Run: auth login --github',
          type: TerminalLineType.error,
        ),
      ];
    }

    if (command.subcommand != 'request') {
      return const [
        TerminalLine(
          'Usage: collab request @username [--project=name]',
          type: TerminalLineType.warning,
        ),
      ];
    }

    // Find the @username arg
    final targetUser = command.positionalArgs
        .where((a) => a.startsWith('@'))
        .map((a) => a.substring(1))
        .firstOrNull;

    if (targetUser == null || targetUser.isEmpty) {
      return const [
        TerminalLine(
          'Missing target. Usage: collab request @username',
          type: TerminalLineType.warning,
        ),
      ];
    }

    final project = command.flags['project'] ?? 'untitled';

    try {
      await _connectionRepository.sendRequestByUsername(
        username: targetUser,
        projectName: project,
      );

      return [
        const TerminalLine(''),
        TerminalLine(
          '  Collab request sent to @$targetUser',
          type: TerminalLineType.success,
        ),
        TerminalLine(
          '  Project: $project',
          type: TerminalLineType.info,
        ),
        const TerminalLine(
          '  Waiting for acceptance...',
          type: TerminalLineType.system,
        ),
        const TerminalLine(''),
      ];
    } catch (e) {
      return [
        TerminalLine(
          'COLLAB ERROR: $e',
          type: TerminalLineType.error,
        ),
      ];
    }
  }
}
