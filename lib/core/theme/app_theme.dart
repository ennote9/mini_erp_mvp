import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_text_theme.dart';

/// App theme. Dark-first, light-ready. No runtime switch in Phase 1.
/// Docs: 09_Navigation_and_App_Shell_v1.md, 22_UI_Consistency_Rules_v1.md
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final textTheme = AppTextTheme.build(
      AppColorTokens.textPrimaryDark,
      AppColorTokens.textSecondaryDark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: AppColorTokens.surfaceDark,
        onSurface: AppColorTokens.textPrimaryDark,
        primary: AppColorTokens.sidebarActiveDark,
        onPrimary: Colors.white,
        outline: AppColorTokens.borderDark,
      ),
      scaffoldBackgroundColor: AppColorTokens.surfaceDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorTokens.surfaceElevatedDark,
        foregroundColor: AppColorTokens.textPrimaryDark,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium,
      ),
      dividerColor: AppColorTokens.dividerDark,
      cardTheme: CardThemeData(
        color: AppColorTokens.surfaceElevatedDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColorTokens.borderDark),
        ),
      ),
    );
  }

  static ThemeData get light {
    final textTheme = AppTextTheme.build(
      AppColorTokens.textPrimaryLight,
      AppColorTokens.textSecondaryLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColorTokens.surfaceLight,
        onSurface: AppColorTokens.textPrimaryLight,
        primary: AppColorTokens.sidebarActiveLight,
        onPrimary: Colors.white,
        outline: AppColorTokens.borderLight,
      ),
      scaffoldBackgroundColor: AppColorTokens.surfaceLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorTokens.surfaceElevatedLight,
        foregroundColor: AppColorTokens.textPrimaryLight,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium,
      ),
      dividerColor: AppColorTokens.dividerLight,
      cardTheme: CardThemeData(
        color: AppColorTokens.surfaceElevatedLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColorTokens.borderLight),
        ),
      ),
    );
  }
}
