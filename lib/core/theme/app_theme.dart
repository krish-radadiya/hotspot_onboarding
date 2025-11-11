import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: const Color(0xFF0A84FF),
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF0A84FF),
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }
}
