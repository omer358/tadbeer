import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Premium Color Palette
class AppColors {
  static const primary = Color(0xFF0F172A); // Slate 900
  static const primaryVariant = Color(0xFF334155); // Slate 700
  static const secondary = Color(0xFF10B981); // Emerald 500
  static const accent = Color(0xFFF59E0B); // Amber 500

  static const surface = Colors.white;
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const error = Color(0xFFEF4444); // Red 500

  static const textPrimary = Color(0xFF1E293B); // Slate 800
  static const textSecondary = Color(0xFF64748B); // Slate 500
}

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    surfaceContainerHighest: const Color(0xFFF1F5F9), // Slate 100
    outlineVariant: const Color(0xFFE2E8F0), // Slate 200
  ),
  scaffoldBackgroundColor: AppColors.background,

  // Typography
  textTheme: TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),

  // Component Themes
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
    ),
    margin: const EdgeInsets.only(bottom: 12),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primaryVariant),
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    indicatorColor: AppColors.primary.withOpacity(0.1),
    labelTextStyle: WidgetStateProperty.all(
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primary);
      }
      return const IconThemeData(color: AppColors.textSecondary);
    }),
  ),
);

// We can define a simplified dark theme or just reuse light for now as MVP.
// Let's create a proper Dark Mode for "Premium" feel.
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.white, // In dark mode, primary text/action is white
    onPrimary: Colors.black,
    secondary: AppColors.secondary,
    surface: const Color(0xFF1E293B), // Slate 800
    onSurface: const Color(0xFFF8FAFC), // Slate 50
    surfaceContainerHighest: const Color(0xFF334155), // Slate 700
    outlineVariant: const Color(0xFF475569), // Slate 600
  ),
  scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900

  textTheme: TextTheme(
    displayLarge: GoogleFonts.outfit(color: Colors.white),
    titleLarge: GoogleFonts.inter(color: Colors.white),
    bodyLarge: GoogleFonts.inter(color: const Color(0xFFE2E8F0)),
    bodySmall: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E293B),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide.none,
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F172A),
    foregroundColor: Colors.white,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1E293B),
    indicatorColor: Colors.white.withOpacity(0.1),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: Colors.white);
      }
      return const IconThemeData(color: Color(0xFF94A3B8));
    }),
  ),
);
