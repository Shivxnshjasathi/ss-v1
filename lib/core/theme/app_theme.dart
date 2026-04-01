import 'package:flutter/material.dart';

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
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        displayMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        displaySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        titleSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.black87),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.black87),
        bodySmall: TextStyle(fontFamily: 'Inter', color: Colors.black54),
        labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.black),
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
          textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 16),
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        displayMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        displaySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        titleSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white70),
        bodySmall: TextStyle(fontFamily: 'Inter', color: Colors.white54),
        labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white),
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
          textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 16),
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
  Color get secondaryTextColor => isDarkMode ? Colors.white70 : Colors.black54;
  Color get borderColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get cardColor => theme.cardColor;
  Color get iconColor => theme.iconTheme.color ?? Colors.black;
}
