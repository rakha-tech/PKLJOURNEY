import 'package:flutter/material.dart';

abstract final class AppColors {
  static const maroon = Color(0xFF6B0D0D);
  static const maroonDark = Color(0xFF4C0808);
  static const cream = Color(0xFFE9DCC9);
  static const paper = Color(0xFFFAF8F4);
  static const ink = Color(0xFF282421);
  static const muted = Color(0xFF827A72);
  static const taupe = Color(0xFF76695C);
  static const line = Color(0xFFEAE4DB);
  static const green = Color(0xFF327A56);
  static const paleGreen = Color(0xFFEAF4ED);
  static const amber = Color(0xFFAE7628);
  static const paleAmber = Color(0xFFFBF1DF);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.maroon,
      primary: AppColors.maroon,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      splashColor: AppColors.maroon.withOpacity(0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.16,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dividerColor: AppColors.line,
    );
  }
}