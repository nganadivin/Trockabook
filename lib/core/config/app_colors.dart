import 'package:flutter/material.dart';

class AppColors {
  // Bleus modernes (remplaçant le rouge)
  static const Color primaryBlue = Color(0xFF2196F3); // Bleu Royal
  static const Color lightBlue = Color(0xFFE3F2FD); // Bleu très clair
  static const Color darkBlue = Color(0xFF1565C0); // Bleu foncé
  static const Color accentBlue = Color(0xFF03A9F4); // Bleu accent

  // Neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFB0BEC5);
  static const Color darkGray = Color(0xFF37474F);
  static const Color black = Color(0xFF000000);

  // États
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Ombres
  static const BoxShadow lightShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x29000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}

// ThemeData personnalisé
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.mediumGray,
      elevation: 8,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
    ),
  );
}
