import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette (Sage Green)
  static const Color primary = Color(0xFF588157); // Sage Green
  static const Color primaryLight = Color(0xFFA3B18A); // Soft Sage Green
  static const Color primaryDark = Color(0xFF3A5A40); // Deep Forest Green

  // Secondary palette (Warm Sand/Clay)
  static const Color secondary = Color(0xFFDDA15E); // Clay/Sand
  static const Color secondaryLight = Color(0xFFE9C46A); // Warm Amber

  // Accent / Warning
  static const Color accent = Color(0xFFE76F51); // Terracotta Orange/Red
  static const Color warning = Color(0xFFF4A261); // Sandy Orange
  static const Color success = Color(0xFF2A9D8F); // Organic Teal Green

  // Dark theme backgrounds (Organic Forest Dark)
  static const Color darkBg = Color(0xFF131A14); // Deep Forest Green/Black
  static const Color darkSurface = Color(0xFF1C251F); // Dark Forest Grey
  static const Color darkCard = Color(0xFF243229); // Dark Greenish Card
  static const Color darkBorder = Color(0xFF324638); // Forest Green Border

  // Light theme backgrounds (Warm Alabaster/Cream)
  static const Color lightBg = Color(0xFFFAF9F6); // Cream Alabaster
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F3EE); // Very light Sage grey-cream card
  static const Color lightBorder = Color(0xFFE1E5DC); // Soft Sage border

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3B18A); // Soft Sage Text for dark mode
  static const Color textMuted = Color(0xFF7B8D7F); // Muted Sage
  static const Color textOnLight = Color(0xFF2F3E32); // Deep forest green/charcoal text
  static const Color textSecondaryOnLight = Color(0xFF58705F); // Medium forest green text

  // Category colors
  static const Color catFood = Color(0xFFDDA15E); // Orange/Clay
  static const Color catTransport = Color(0xFF8AB17D); // Soft Green
  static const Color catShopping = Color(0xFFE9C46A); // Warm Yellow
  static const Color catWork = Color(0xFF2A9D8F); // Organic Teal
  static const Color catHealth = Color(0xFFE76F51); // Terracotta
  static const Color catEntertainment = Color(0xFF9B5DE5); // Lavender/Lilac
  static const Color catOther = Color(0xFF7B8D7F); // Muted Sage
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.accent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.accent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textOnLight,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textOnLight, letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textOnLight, letterSpacing: -0.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textOnLight,
          ),
          headlineMedium: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textOnLight,
          ),
          headlineSmall: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOnLight,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textOnLight,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondaryOnLight,
          ),
          bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryOnLight),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
    );
  }
}
