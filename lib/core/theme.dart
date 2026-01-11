import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.light,
  cardTheme: const CardThemeData(
    elevation: 1.5,
    surfaceTintColor: Colors.transparent,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.dark,
  cardTheme: const CardThemeData(
    elevation: 1.5,
    surfaceTintColor: Colors.transparent,
  ),
);
