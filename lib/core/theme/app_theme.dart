import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_text_theme.dart';

/// App theme. Calm steel/graphite dark palette, light-ready.
/// Docs: 09_Navigation_and_App_Shell_v1.md, 22_UI_Consistency_Rules_v1.md
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final textTheme = AppTextTheme.build(
      AppColorTokens.textPrimaryDark,
      AppColorTokens.textSecondaryDark,
    );
    final colorScheme = ColorScheme.dark(
      surface: AppColorTokens.mainSurfaceDark,
      onSurface: AppColorTokens.textPrimaryDark,
      primary: AppColorTokens.primaryDark,
      onPrimary: Colors.white,
      tertiary: AppColorTokens.linkDark,
      onTertiary: AppColorTokens.textPrimaryDark,
      outline: AppColorTokens.borderDark,
      error: AppColorTokens.errorDark,
      onError: Colors.white,
    ).copyWith(
      surfaceContainerHighest: AppColorTokens.surfaceHoverDark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorTokens.appBackgroundDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorTokens.mainSurfaceDark,
        foregroundColor: AppColorTokens.textPrimaryDark,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium,
      ),
      dividerColor: AppColorTokens.dividerDark,
      cardTheme: CardThemeData(
        color: AppColorTokens.cardSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColorTokens.borderDark),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 40,
        horizontalMargin: 16,
        columnSpacing: 16,
        decoration: const BoxDecoration(
          color: AppColorTokens.cardSurfaceDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColorTokens.inputSurfaceDark,
        focusColor: AppColorTokens.focusRingDark,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorTokens.errorDark),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColorTokens.primaryDark,
          foregroundColor: Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorTokens.switchActiveDark;
          }
          return AppColorTokens.switchInactiveTrackDark;
        }),
        thumbColor: WidgetStateProperty.all(AppColorTokens.switchThumbDark),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColorTokens.primaryDark,
        secondarySelectedColor: AppColorTokens.primaryDark,
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
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 40,
        horizontalMargin: 16,
        columnSpacing: 16,
        decoration: const BoxDecoration(
          color: AppColorTokens.surfaceElevatedLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColorTokens.surfaceElevatedLight,
      ),
    );
  }
}
