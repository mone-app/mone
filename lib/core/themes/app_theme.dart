// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color.fromARGB(255, 0, 200, 255);
  static const Color _primaryColorLight = Color.fromARGB(255, 24, 90, 219);

  // Light Theme
  static ThemeData get lightTheme {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColorLight,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      brightness: Brightness.light,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      brightness: Brightness.dark,
    );
  }
}
