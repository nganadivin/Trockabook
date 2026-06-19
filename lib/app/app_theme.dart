import 'package:flutter/material.dart';

class AppTheme {
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF146C63),
    onPrimary: Colors.white,
    secondary: Color(0xFFF2A900),
    onSecondary: Color(0xFF1F1F1F),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: Color(0xFFFBFCFA),
    onSurface: Color(0xFF1B1F1D),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7FD8CC),
    onPrimary: Color(0xFF003731),
    secondary: Color(0xFFFFD36A),
    onSecondary: Color(0xFF352900),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF111412),
    onSurface: Color(0xFFE2E4E0),
  );

  static ThemeData get lightTheme {
    return _buildTheme(_lightScheme);
  }

  static ThemeData get darkTheme {
    return _buildTheme(_darkScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.55),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF191D1A) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      buttonTheme: ButtonThemeData(buttonColor: colorScheme.primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1E1B) : const Color(0xFFF3F6F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(color: colorScheme.onSurface),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}
