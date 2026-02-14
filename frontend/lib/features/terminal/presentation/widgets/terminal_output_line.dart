import 'package:flutter/material.dart';
import '../../domain/models/terminal_line.dart';
import '../../../../core/theme/terminal_theme.dart';

/// Renders a single [TerminalLine] with the appropriate color and style.
class TerminalOutputLineWidget extends StatelessWidget {
  const TerminalOutputLineWidget({super.key, required this.line});

  final TerminalLine line;

  Color _color() {
    switch (line.type) {
      case TerminalLineType.command:
        return TerminalColors.white;
      case TerminalLineType.success:
        return TerminalColors.green;
      case TerminalLineType.warning:
        return TerminalColors.yellow;
      case TerminalLineType.error:
        return TerminalColors.red;
      case TerminalLineType.system:
        return TerminalColors.grey;
      case TerminalLineType.ascii:
        return TerminalColors.cyan;
      case TerminalLineType.info:
        return TerminalColors.dimGreen;
    }
  }

  FontWeight _weight() {
    switch (line.type) {
      case TerminalLineType.command:
      case TerminalLineType.success:
        return FontWeight.bold;
      case TerminalLineType.info:
      case TerminalLineType.warning:
      case TerminalLineType.error:
      case TerminalLineType.system:
      case TerminalLineType.ascii:
        return FontWeight.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Text(
        line.text,
        style: TextStyle(
          fontFamily: 'Fira Code',
          fontSize: 13,
          color: _color(),
          fontWeight: _weight(),
          height: 1.5,
        ),
      ),
    );
  }
}
