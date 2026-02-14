import 'package:equatable/equatable.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted a raw command string from the input field.
class TerminalCommandSubmittedEvent extends TerminalEvent {
  const TerminalCommandSubmittedEvent(this.rawInput);
  final String rawInput;

  @override
  List<Object?> get props => [rawInput];
}

/// Append output lines programmatically (e.g. boot sequence, auth callback).
class TerminalOutputAddedEvent extends TerminalEvent {
  const TerminalOutputAddedEvent(this.lines);
  final List<dynamic> lines; // List<TerminalLine>

  @override
  List<Object?> get props => [lines];
}

/// Clear the terminal output buffer.
class TerminalClearEvent extends TerminalEvent {
  const TerminalClearEvent();
}
