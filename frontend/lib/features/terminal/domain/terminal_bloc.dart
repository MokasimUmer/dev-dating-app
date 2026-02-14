import 'package:flutter_bloc/flutter_bloc.dart';
import 'command_parser.dart';
import 'commands/command_handler.dart';
import 'commands/auth_command.dart';
import 'commands/clear_command.dart';
import 'commands/collab_command.dart';
import 'commands/find_command.dart';
import 'commands/help_command.dart';
import 'commands/whoami_command.dart';
import 'models/terminal_line.dart';
import 'terminal_event.dart';
import 'terminal_state.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../connections/data/connection_repository.dart';

/// Core BLoC that manages the terminal output buffer and command dispatch.
class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  TerminalBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required ConnectionRepository connectionRepository,
  }) : super(const TerminalState()) {
    // Register command handlers
    _handlers = {
      'help': HelpCommand(),
      'auth': AuthCommand(authRepository: authRepository),
      'whoami': WhoamiCommand(
        authRepository: authRepository,
        profileRepository: profileRepository,
      ),
      'find': FindCommand(
        authRepository: authRepository,
        profileRepository: profileRepository,
      ),
      'collab': CollabCommand(
        authRepository: authRepository,
        connectionRepository: connectionRepository,
      ),
      'clear': ClearCommand(),
    };

    on<TerminalCommandSubmittedEvent>(_onCommandSubmitted);
    on<TerminalOutputAddedEvent>(_onOutputAdded);
    on<TerminalClearEvent>(_onClear);
  }

  late final Map<String, CommandHandler> _handlers;

  Future<void> _onCommandSubmitted(
    TerminalCommandSubmittedEvent event,
    Emitter<TerminalState> emit,
  ) async {
    final raw = event.rawInput.trim();
    if (raw.isEmpty) return;

    // Echo the command
    final updated = List<TerminalLine>.from(state.lines)
      ..add(TerminalLine('> $raw', type: TerminalLineType.command));

    emit(state.copyWith(lines: updated, isProcessing: true));

    final parsed = parseCommand(raw);

    // Handle clear separately — it wipes the buffer
    if (parsed.name == 'clear') {
      emit(const TerminalState());
      return;
    }

    final handler = _handlers[parsed.name];

    if (handler == null) {
      final errorLines = List<TerminalLine>.from(updated)
        ..add(TerminalLine(
          'Command not found: ${parsed.name}. Type "help" for available commands.',
          type: TerminalLineType.error,
        ));
      emit(state.copyWith(lines: errorLines, isProcessing: false));
      return;
    }

    try {
      final output = await handler.execute(parsed);
      final newLines = List<TerminalLine>.from(updated)..addAll(output);
      emit(state.copyWith(lines: newLines, isProcessing: false));
    } catch (e) {
      final errLines = List<TerminalLine>.from(updated)
        ..add(TerminalLine('FATAL: $e', type: TerminalLineType.error));
      emit(state.copyWith(lines: errLines, isProcessing: false));
    }
  }

  void _onOutputAdded(
    TerminalOutputAddedEvent event,
    Emitter<TerminalState> emit,
  ) {
    final newLines = List<TerminalLine>.from(state.lines)
      ..addAll(event.lines.cast<TerminalLine>());
    emit(state.copyWith(lines: newLines));
  }

  void _onClear(
    TerminalClearEvent event,
    Emitter<TerminalState> emit,
  ) {
    emit(const TerminalState());
  }
}
