import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Premium Color Palette
class AppColors {
  static const primary = Color(0xFF984722); // Rust
  static const primaryVariant = Color(0xFF6D3014);
  static const secondary = Color(0xFF9DB8B7); // Muted Teal
  static const tertiary = Color(0xFFEAE0C7); // Beige
  static const accent = Color(0xFFEAE0C7);

  static const surface = Colors.white;
  static const background = Color(0xFFFAFAF9); // Stone 50 (Warm white)
  static const error = Color(0xFFBA1A1A);

  static const textPrimary = Color(0xFF292524); // Stone 800
  static const textSecondary = Color(0xFF57534E); // Stone 500
}

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    surfaceContainerHighest: const Color(0xFFF5F5F4), // Stone 100
    outlineVariant: const Color(0xFFE7E5E4), // Stone 200
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
      side: const BorderSide(color: Color(0xFFF5F5F4), width: 1),
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
      textStyle: TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: Color(0xFFE7E5E4)),
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
    hintStyle: GoogleFonts.inter(color: const Color(0xFFA8A29E)), // Stone 400
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
    primary: AppColors.tertiary, // Beige is high contrast on dark
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.secondary,
    onSecondary: Colors.black,
    tertiary: AppColors.primary,
    onTertiary: Colors.white,
    surface: const Color(0xFF292524), // Stone 800
    onSurface: const Color(0xFFFAFAF9), // Stone 50
    error: const Color(0xFFCF6679),
    surfaceContainerHighest: const Color(0xFF44403C), // Stone 700
    outlineVariant: const Color(0xFF57534E), // Stone 600
  ),
  scaffoldBackgroundColor: const Color(0xFF1C1917), // Stone 900

  textTheme: TextTheme(
    displayLarge: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    displayMedium: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    displaySmall: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    headlineLarge: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    headlineMedium: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    headlineSmall: GoogleFonts.outfit(color: const Color(0xFFFAFAF9)),
    titleLarge: GoogleFonts.inter(color: const Color(0xFFFAFAF9)),
    titleMedium: GoogleFonts.inter(color: const Color(0xFFFAFAF9)),
    titleSmall: GoogleFonts.inter(color: const Color(0xFFFAFAF9)),
    bodyLarge: GoogleFonts.inter(color: const Color(0xFFE7E5E4)),
    bodyMedium: GoogleFonts.inter(color: const Color(0xFFE7E5E4)),
    bodySmall: GoogleFonts.inter(color: const Color(0xFFA8A29E)),
    labelLarge: GoogleFonts.inter(color: const Color(0xFFFAFAF9)),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF292524),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide.none,
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1C1917),
    foregroundColor: Color(0xFFFAFAF9),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.tertiary,
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      textStyle: TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.tertiary,
      side: const BorderSide(color: Color(0xFF57534E)),
      minimumSize: const Size(100, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF292524),
    indicatorColor: AppColors.tertiary.withOpacity(0.2),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.tertiary);
      }
      return const IconThemeData(color: Color(0xFFA8A29E));
    }),
  ),
);
