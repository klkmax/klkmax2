import 'package:flutter/material.dart';

class AppTheme {
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color electricMagenta = Color(0xFFFF00A8);
  static const Color limePunch = Color(0xFFB8FF00);
  static const Color deepPurple = Color(0xFF1A0033);
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color cardBg = Color(0xFF1A1A2E);

  static List<BoxShadow> neonShadow(Color color, {double blur = 16}) => [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: blur,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration premiumCard({Color? borderColor}) => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (borderColor ?? neonCyan).withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: neonShadow(borderColor ?? neonCyan, blur: 12),
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonOrange,
      colorScheme: const ColorScheme.dark(
        primary: neonOrange,
        secondary: neonCyan,
        tertiary: electricMagenta,
        surface: cardBg,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepPurple,
        foregroundColor: neonCyan,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: neonCyan,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonOrange,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonCyan,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonCyan, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: neonCyan),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: neonCyan,
          letterSpacing: 1.1,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(color: Colors.white70),
      ),
    );
  }
}
