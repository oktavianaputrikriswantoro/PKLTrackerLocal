import 'package:flutter/material.dart';

class AppTheme {
  static const cream = Color(0xFFF8F1E8);
  static const beige = Color(0xFFE8D8C5);
  static const latte = Color(0xFFC8A98C);
  static const mocha = Color(0xFFA47C61);
  static const cocoa = Color(0xFF795943);
  static const darkBrown = Color(0xFF513B2D);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mocha,
      primary: cocoa,
      secondary: latte,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: darkBrown,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: beige),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: mocha, width: 1.5),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mocha,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF171411),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF171411),
      foregroundColor: Color(0xFFF8F1E8),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF28221D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cocoa),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: latte, width: 1.5),
      ),
    ),
  );
}
