import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../profile/data/profile_repository.dart';

class FindCommand implements CommandHandler {
  FindCommand({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _authRepository = authRepository,
       _profileRepository = profileRepository;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

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

    final tech = command.flags['tech'];
    final isNear = command.flags.containsKey('near');

    final lines = <TerminalLine>[
      const TerminalLine(''),
      TerminalLine(
        '  Searching for developers${tech != null ? " (tech=$tech)" : ""}${isNear ? " nearby" : ""}...',
        type: TerminalLineType.system,
      ),
    ];

    try {
      final profiles = await _profileRepository.discoverNearby(
        tech: tech,
        // TODO: pass real lat/lng from device location when --near is used
      );

      if (profiles.isEmpty) {
        lines.add(const TerminalLine(
          '  No developers found. Try different filters.',
          type: TerminalLineType.warning,
        ));
      } else {
        lines.add(const TerminalLine(
          '  ─────────────────────────────────────',
          type: TerminalLineType.system,
        ));

        for (final p in profiles) {
          final stack =
              p.techStack.isNotEmpty ? p.techStack.join(', ') : '—';
          lines.add(TerminalLine(
            '  @${p.githubUsername.padRight(18)} $stack',
            type: TerminalLineType.info,
          ));
        }

        lines.add(const TerminalLine(''));
        lines.add(TerminalLine(
          '  ${profiles.length} developer(s) found. Use: collab request @username',
          type: TerminalLineType.success,
        ));
      }

      lines.add(const TerminalLine(''));
      return lines;
    } catch (e) {
      return [
        TerminalLine('Search error: $e', type: TerminalLineType.error),
      ];
    }
  }
}
