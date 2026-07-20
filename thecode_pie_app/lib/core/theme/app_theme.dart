import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pumpkin,
        secondary: AppColors.sage,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.textOnPumpkin,
        onSecondary: AppColors.textOnLight,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.body,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pumpkin,
          foregroundColor: AppColors.textOnPumpkin,
          textStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
