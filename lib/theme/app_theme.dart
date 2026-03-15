import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Turkuaz Palet ──
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color darkTeal = Color(0xFF00897B);
  static const Color lightTeal = Color(0xFF64FFDA);
  static const Color surface = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E2C);
  static const Color cardLight = Color(0xFF2A2A3C);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color gold = Color(0xFFFFD54F);

  // ── Bulunan kelimelerin renkleri ──
  static const List<Color> wordColors = [
    Color(0xFF00BFA5),
    Color(0xFFFF7043),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFFEF5350),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
    Color(0xFF7E57C2),
    Color(0xFF9CCC65),
    Color(0xFFFF8A65),
    Color(0xFF5C6BC0),
    Color(0xFFD4E157),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: lightTeal,
        surface: cardDark,
        error: errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
