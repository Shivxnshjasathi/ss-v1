import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E60FF);
  static const Color cyanAccent = Color(0xFF00D1FF);
  static const Color navyDark = Color(0xFF001F3F);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: cyanAccent,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
        bodyLarge: GoogleFonts.inter(color: Colors.black87),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme => lightTheme; // For consistency in this specific high-end aesthetic
}
