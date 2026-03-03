import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      secondary: AppColors.brandLight,
      surface: AppColors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.dark,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
    ),
  );
}
