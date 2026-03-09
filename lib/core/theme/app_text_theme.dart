import 'package:flutter/material.dart';

/// Dense, enterprise-style text theme. Desktop-first.
/// Docs: 22_UI_Consistency_Rules_v1.md (density, enterprise-like)
class AppTextTheme {
  AppTextTheme._();

  static TextTheme build(Color primary, Color secondary) {
    return TextTheme(
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
    );
  }
}
