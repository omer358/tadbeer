import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFEAE0C7),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFFEAE0C7),
        secondary: const Color(0xFF9DB8B7),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  cardTheme: const CardThemeData(
    color: Color(0xFFEAE0C7),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.only(bottom: 16),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF9DB8B7),
      foregroundColor: Colors.black,
      minimumSize: const Size(100, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black),
      minimumSize: const Size(100, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF9DB8B7),
    linearTrackColor: Color(0xFFE0E0E0),
    linearMinHeight: 6,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFEAE0C7),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFFEAE0C7),
        secondary: const Color(0xFF9DB8B7),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        // onSurface: Colors.white, // Default for dark mode is usually fine
      ),
  cardTheme: const CardThemeData(
    elevation: 1.5,
    surfaceTintColor: Colors.transparent,
  ),
);
