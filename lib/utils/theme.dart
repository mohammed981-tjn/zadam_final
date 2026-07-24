import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFE63946);
  static const dark = Color(0xFF1D3557);
  static const secondary = Color(0xFF457B9D);
  static const success = Color(0xFF2DC653);
  static const warning = Color(0xFFF4A261);
  static const surface = Color(0xFFF8F9FA);
  static const textDark = Color(0xFF1D3557);
  static const textGray = Color(0xFF6C757D);
  static const divider = Color(0xFFDEE2E6);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary,
        secondary: AppColors.secondary, surface: AppColors.surface),
    textTheme: GoogleFonts.cairoTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    cardTheme: CardThemeData(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    scaffoldBackgroundColor: AppColors.surface,
  );
}
