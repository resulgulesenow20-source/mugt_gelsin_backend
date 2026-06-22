import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    
    // ðŸ–‹ï¸ GLOBAL TYPOGRAPHY
    textTheme: GoogleFonts.interTextTheme(const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textTitle, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 0),
      headlineMedium: TextStyle(color: AppColors.textTitle, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 0),
      titleLarge: TextStyle(color: AppColors.textTitle, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    )),

    // ðŸ“± APP BAR THEME
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textTitle,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textTitle, size: 24),
    ),

    // ðŸ’³ CARD THEME
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
    ),

    // ðŸ”˜ BUTTON THEMES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),

    // ðŸ“ INPUT THEME
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}

