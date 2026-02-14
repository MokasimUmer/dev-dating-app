import 'package:equatable/equatable.dart';
import 'models/terminal_line.dart';

class TerminalState extends Equatable {
  const TerminalState({
    this.lines = const [],
    this.isProcessing = false,
  });

  /// All output lines currently visible in the terminal.
  final List<TerminalLine> lines;

  /// Whether a command is currently being processed.
  final bool isProcessing;

  TerminalState copyWith({
    List<TerminalLine>? lines,
    bool? isProcessing,
  }) {
    return TerminalState(
      lines: lines ?? this.lines,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [lines, isProcessing];
}
