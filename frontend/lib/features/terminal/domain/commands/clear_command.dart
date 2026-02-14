import '../command_parser.dart';
import '../models/terminal_line.dart';
import 'command_handler.dart';

/// Sentinel command — the BLoC checks for this and clears the buffer.
/// Returns empty list because the BLoC handles the clear action directly.
class ClearCommand implements CommandHandler {
  @override
  Future<List<TerminalLine>> execute(ParsedCommand command) async {
    // The TerminalBloc recognises "clear" and wipes the line buffer.
    return const [];
  }
}
