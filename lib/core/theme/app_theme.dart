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
      cardColor: Colors.white,
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

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: cyanAccent,
        surface: const Color(0xFF1E1E1E),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
        bodyLarge: GoogleFonts.inter(color: Colors.white70),
        bodyMedium: GoogleFonts.inter(color: Colors.white70),
        bodySmall: GoogleFonts.inter(color: Colors.white54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
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
      dividerColor: Colors.grey.shade800,
      cardColor: const Color(0xFF1E1E1E),
      useMaterial3: true,
    );
  }
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  Color get surfaceColor => colorScheme.surface;
  Color get scaffoldColor => theme.scaffoldBackgroundColor;
  Color get primaryTextColor => textTheme.bodyLarge?.color ?? Colors.black;
  Color get borderColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get cardColor => theme.cardColor;
  Color get iconColor => theme.iconTheme.color ?? Colors.black;
}
