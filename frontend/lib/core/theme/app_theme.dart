import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppGlass {
  AppGlass._();

  static const double blurStrong = 8;
  static const double blurMedium = 5;
  static const double radiusLarge = 28;

  static const Color darkBg = Color(0xFF032343);
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteCupertino
        : Typography.blackCupertino;
    return GoogleFonts.interTextTheme(base).copyWith(
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4A7BA7),
      onPrimary: Colors.white,
      secondary: Color(0xFF6BA3C1),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFF5F7FA),
      onSurface: Color(0xFF1A2332),
      tertiary: Color(0xFF5B8FA3),
      onTertiary: Color(0xFF1A2332),
      outline: Color(0x404A7BA7),
      shadow: Color(0x22000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A2332),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.60),
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.radiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.70),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onPrimary,
              size: 22,
            );
          }

          return IconThemeData(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            size: 21,
          );
        }),
        labelTextStyle: WidgetStateProperty.all(
          _textTheme(Brightness.light).labelMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withValues(alpha: 0.88),
        contentTextStyle: _textTheme(Brightness.light).bodyMedium,
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF8DB5D1),
      onPrimary: Color(0xFF032343),
      secondary: Color(0xFF7FA3B5),
      onSecondary: Colors.white,
      error: Color(0xFFC47D7D),
      onError: Color(0xFF2B0F0E),
      surface: Color(0xFF0A1520),
      onSurface: Color(0xFFE8EDE8),
      tertiary: Color(0xFF6BA3C1),
      onTertiary: Color(0xFFE8EDE8),
      outline: Color(0x26FFFFFF),
      shadow: Color(0x88000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppGlass.darkBg,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE6EBFF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        shadowColor: Colors.black.withValues(alpha: 0.30),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.radiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F1B2E).withValues(alpha: 0.90),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onPrimary,
              size: 22,
            );
          }

          return IconThemeData(
            color: colorScheme.onSurface.withValues(alpha: 0.82),
            size: 21,
          );
        }),
        labelTextStyle: WidgetStateProperty.all(
          _textTheme(Brightness.dark).labelMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10172E).withValues(alpha: 0.92),
        contentTextStyle: _textTheme(Brightness.dark).bodyMedium,
      ),
    );
  }
}

class AppBackground {
  AppBackground._();

  static List<Color> colors(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        AppGlass.darkBg,
        Color(0xFF0F1B2E),
        Color(0xFF0A1520),
        Color(0xFF051221),
      ];
    }

    return const [
      Color(0xFFF5F7FA),
      Color(0xFFF8FAFC),
      Color(0xFFF1F3F5),
      Color(0xFFFCFDFE),
    ];
  }
}
