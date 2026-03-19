import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4E6BFF),
      onPrimary: Colors.white,
      secondary: Color(0xFF8B9DFF),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFF8FAFF),
      onSurface: Color(0xFF111827),
      tertiary: Color(0xFFB7C4FF),
      onTertiary: Color(0xFF111827),
      outline: Color(0x335B6B9A),
      shadow: Color(0x22000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF2F5FF),
      textTheme: Typography.blackCupertino,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.20),
        shadowColor: const Color(0x330F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9AADFF),
      onPrimary: Color(0xFF0B1024),
      secondary: Color(0xFF7C8EF8),
      onSecondary: Colors.white,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF0F1326),
      onSurface: Color(0xFFE6EBFF),
      tertiary: Color(0xFF4A5BB6),
      onTertiary: Color(0xFFE6EBFF),
      outline: Color(0x44A4B4FF),
      shadow: Color(0x88000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF060A18),
      textTheme: Typography.whiteCupertino,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE6EBFF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        shadowColor: const Color(0x66000000),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
    );
  }
}

class AppBackground {
  AppBackground._();

  static List<Color> colors(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        Color(0xFF0B1024),
        Color(0xFF1B1F3A),
        Color(0xFF0A1020),
      ];
    }

    return const [
      Color(0xFFEAF0FF),
      Color(0xFFDCE8FF),
      Color(0xFFF2F7FF),
    ];
  }
}
