import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Genera un ThemeData reactivo adaptado al color primario del Tenant actual
  static ThemeData getTheme({
    required Color primaryColor,
    bool isDarkMode = false,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      surface: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
    );

    final textTheme = GoogleFonts.outfitTextTheme(
      isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).copyWith(
      // Tamaños generosos para alta legibilidad en adultos y tercera edad
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14.5,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(
          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 15,
        ),
        hintStyle: TextStyle(
          color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.7),
          fontSize: 14.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
