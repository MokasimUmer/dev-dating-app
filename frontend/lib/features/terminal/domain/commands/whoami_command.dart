import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../profile/data/profile_repository.dart';

class WhoamiCommand implements CommandHandler {
  WhoamiCommand({
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

    try {
      final profile = await _profileRepository.getMyProfile();
      final meta = _authRepository.gitHubUserMeta;

      final username = profile?.githubUsername ??
          meta?['user_name'] ??
          'unknown';
      final name = profile?.displayName ??
          meta?['full_name'] ??
          username;
      final bio = profile?.bio ?? meta?['bio'] ?? 'No bio set';
      final stack = profile?.techStack ?? [];
      final xp = profile?.xp ?? 0;
      final rank = profile?.rank ?? 'Intern';

      return [
        const TerminalLine(''),
        TerminalLine('  @$username', type: TerminalLineType.success),
        TerminalLine('  $name', type: TerminalLineType.info),
        TerminalLine('  "$bio"', type: TerminalLineType.system),
        const TerminalLine('  ─────────────────────', type: TerminalLineType.system),
        TerminalLine(
          '  Tech  : ${stack.isEmpty ? "not set" : stack.join(", ")}',
          type: TerminalLineType.info,
        ),
        TerminalLine('  XP    : $xp', type: TerminalLineType.info),
        TerminalLine('  Rank  : $rank', type: TerminalLineType.info),
        const TerminalLine(''),
      ];
    } catch (e) {
      return [
        TerminalLine('Error fetching profile: $e', type: TerminalLineType.error),
      ];
    }
  }
}
