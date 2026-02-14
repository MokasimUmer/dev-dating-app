/// The visual type of a terminal output line, used for styling.
enum TerminalLineType {
  /// Standard informational output.
  info,

  /// User-typed command (echoed back).
  command,

  /// Successful result / positive feedback.
  success,

  /// Warning.
  warning,

  /// Error message.
  error,

  /// System/boot message (dimmer).
  system,

  /// ASCII art or decorative text.
  ascii,
}

/// A single line of terminal output.
class TerminalLine {
  const TerminalLine(this.text, {this.type = TerminalLineType.info});

  final String text;
  final TerminalLineType type;
}
