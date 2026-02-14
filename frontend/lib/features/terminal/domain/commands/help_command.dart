import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';

class HelpCommand implements CommandHandler {
  @override
  Future<List<TerminalLine>> execute(ParsedCommand command) async {
    return const [
      TerminalLine(''),
      TerminalLine('  DevDate v1.0 — Available Commands', type: TerminalLineType.success),
      TerminalLine('  ──────────────────────────────────', type: TerminalLineType.system),
      TerminalLine(''),
      TerminalLine('  auth login --github    Sign in with GitHub', type: TerminalLineType.info),
      TerminalLine('  auth logout            Sign out', type: TerminalLineType.info),
      TerminalLine('  whoami                 Show your profile', type: TerminalLineType.info),
      TerminalLine('  find --tech=<lang>     Discover developers', type: TerminalLineType.info),
      TerminalLine('  find --near            Discover nearby devs', type: TerminalLineType.info),
      TerminalLine('  collab request @user   Send a collab invite', type: TerminalLineType.info),
      TerminalLine('  clear                  Clear the terminal', type: TerminalLineType.info),
      TerminalLine('  help                   Show this message', type: TerminalLineType.info),
      TerminalLine(''),
    ];
  }
}
