import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color background = Color(0xFF111A1E);
  static const Color panel = Color(0xFF223138);
  static const Color panelLight = Color(0xFF30454E);
  static const Color accent = Color(0xFFF2B63D);
  static const Color danger = Color(0xFFE65A4F);
  static const Color success = Color(0xFF5FC48D);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: panel,
        ),
        scaffoldBackgroundColor: background,
        useMaterial3: true,
        cardTheme: const CardThemeData(
          color: panel,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: const Color(0xFF172126),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
}
