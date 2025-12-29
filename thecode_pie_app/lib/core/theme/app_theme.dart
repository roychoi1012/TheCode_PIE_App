import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

/// 앱 테마 설정
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.pressStart2pTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentOrange,
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
      ),
      useMaterial3: true,
    );
  }
}
