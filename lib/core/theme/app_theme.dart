import 'package:flutter/material.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1765FE); // Slightly more vibrant electric blue
  static const Color primaryGradientStart = Color(0xFF1765FE);
  static const Color primaryGradientEnd = Color(0xFF00D1FF);
  static const Color cyanAccent = Color(0xFF00D1FF);
  
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: surfaceLight,
      cardColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: cyanAccent,
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -1.5),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -1.0),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.black),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.black),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.black),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18.sp),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16.sp),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.black, fontSize: 14.sp),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 16.sp, height: 1.5),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: Colors.black87, fontSize: 14.sp, height: 1.5),
        bodySmall: TextStyle(fontFamily: 'Poppins', color: Colors.black54, fontSize: 12.sp, height: 1.4),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black, size: 24),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.w),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          textStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 16.sp, letterSpacing: 0.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surfaceDark,
      cardColor: const Color(0xFF1E293B),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: cyanAccent,
        surface: const Color(0xFF1E293B),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1.0),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18.sp),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16.sp),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.sp),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16.sp, height: 1.5),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 14.sp, height: 1.5),
        bodySmall: TextStyle(fontFamily: 'Poppins', color: Colors.white54, fontSize: 12.sp, height: 1.4),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.w),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        color: const Color(0xFF1E293B),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          textStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 0.5),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.1),
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
  Color get primaryTextColor => theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
  Color get secondaryTextColor => theme.brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get borderColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get cardColor => theme.cardColor;
  Color get iconColor => theme.iconTheme.color ?? Colors.black;
}
