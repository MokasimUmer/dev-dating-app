import '../command_parser.dart';
import '../models/terminal_line.dart';

/// Base interface that every terminal command must implement.
abstract class CommandHandler {
  /// Execute the command and return output lines.
  Future<List<TerminalLine>> execute(ParsedCommand command);
}
