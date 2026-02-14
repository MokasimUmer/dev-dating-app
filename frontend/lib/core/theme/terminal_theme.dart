import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DevDate Valentine's Day color palette.
class TerminalColors {
  TerminalColors._();

  // Backgrounds — warm dark tones
  static const Color background = Color(0xFF120A10);
  static const Color surface = Color(0xFF1E1219);
  static const Color inputBar = Color(0xFF261620);

  // Primary accent — rose / red
  static const Color green = Color(0xFFFF4D6D); // rose-red (primary accent)
  static const Color dimGreen = Color(0xFFC9184A); // deep rose

  // Text
  static const Color white = Color(0xFFF2E6EC);
  static const Color grey = Color(0xFF9E8B93);
  static const Color yellow = Color(0xFFFFB3C1); // soft pink
  static const Color red = Color(0xFFFF0A54); // vivid red
  static const Color cyan = Color(0xFFFF85A1); // light rose
  static const Color blue = Color(0xFFE05780); // warm pink
  static const Color purple = Color(0xFFFFCCD5); // blush

  // Cursor
  static const Color cursor = green;
}

/// The terminal-inspired ThemeData for DevDate.
ThemeData terminalTheme() {
  final monoFont = GoogleFonts.firaCodeTextTheme();

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TerminalColors.background,
    colorScheme: const ColorScheme.dark(
      primary: TerminalColors.green,
      secondary: TerminalColors.cyan,
      surface: TerminalColors.surface,
      error: TerminalColors.red,
      onPrimary: TerminalColors.white,
      onSecondary: TerminalColors.white,
      onSurface: TerminalColors.white,
      onError: TerminalColors.white,
    ),
    textTheme: monoFont.copyWith(
      bodyLarge: monoFont.bodyLarge?.copyWith(
        color: TerminalColors.green,
        fontSize: 14,
      ),
      bodyMedium: monoFont.bodyMedium?.copyWith(
        color: TerminalColors.green,
        fontSize: 13,
      ),
      bodySmall: monoFont.bodySmall?.copyWith(
        color: TerminalColors.grey,
        fontSize: 12,
      ),
      titleLarge: monoFont.titleLarge?.copyWith(
        color: TerminalColors.green,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: monoFont.labelMedium?.copyWith(
        color: TerminalColors.dimGreen,
        fontSize: 12,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: TerminalColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: TerminalColors.green,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Fira Code',
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: TerminalColors.inputBar,
      border: InputBorder.none,
      hintStyle: TextStyle(color: TerminalColors.grey),
    ),
    useMaterial3: true,
  );
}
