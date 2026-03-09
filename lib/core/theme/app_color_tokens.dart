import 'package:flutter/material.dart';

/// Color tokens for the app. Calm steel/graphite dark palette, light-ready.
/// Docs: 09_Navigation_and_App_Shell_v1.md, 22_UI_Consistency_Rules_v1.md
class AppColorTokens {
  AppColorTokens._();

  // ----- Dark theme (steel/graphite) -----
  static const Color appBackgroundDark = Color(0xFF181818);
  static const Color sidebarBackgroundDark = Color(0xFF212121);
  static const Color mainSurfaceDark = Color(0xFF1E1E1E);
  static const Color cardSurfaceDark = Color(0xFF1E1E1E);
  static const Color inputSurfaceDark = Color(0xFF303030);

  static const Color surfaceHoverDark = Color(0xFF2C2C2C);
  static const Color surfaceSelectedDark = Color(0xFF313741);
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF3A3A3A);
  static const Color focusRingDark = Color(0xFF0A84FF);

  static const Color textPrimaryDark = Color(0xFFECECEC);
  static const Color textSecondaryDark = Color(0xFFB5B5B5);
  static const Color textMutedDark = Color(0xFF8C8C8C);

  static const Color primaryDark = Color(0xFF0A84FF);
  static const Color primaryHoverDark = Color(0xFF409CFF);
  static const Color linkDark = Color(0xFF0A84FF);
  static const Color selectedAccentDark = Color(0xFF0A84FF);

  static const Color successDark = Color(0xFF34C759);
  static const Color errorDark = Color(0xFFEF4444);

  static const Color switchActiveDark = Color(0xFF34C759);
  static const Color switchInactiveTrackDark = Color(0xFF4A4A4A);
  static const Color switchThumbDark = Color(0xFFF5F5F5);

  // Sidebar (dark) - use shared palette
  static const Color sidebarTextDark = textPrimaryDark;
  static const Color sidebarTextMutedDark = textMutedDark;
  static const Color sidebarActiveDark = linkDark;
  static const Color sidebarHoverDark = surfaceHoverDark;

  // Legacy aliases for theme/surfaces (dark)
  static const Color surfaceDark = mainSurfaceDark;
  static const Color surfaceElevatedDark = cardSurfaceDark;

  // ----- Light theme (unchanged structure) -----
  static const Color sidebarBackgroundLight = Color(0xFFF0F2F5);
  static const Color sidebarSurfaceLight = Color(0xFFE4E6EB);
  static const Color sidebarTextLight = Color(0xFF1C1E21);
  static const Color sidebarTextMutedLight = Color(0xFF65676B);
  static const Color sidebarActiveLight = Color(0xFF1877F2);
  static const Color sidebarHoverLight = Color(0xFFE4E6EB);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF7F8FA);
  static const Color textPrimaryLight = Color(0xFF1C1E21);
  static const Color textSecondaryLight = Color(0xFF65676B);
  static const Color borderLight = Color(0xFFCED0D4);
  static const Color dividerLight = Color(0xFFE4E6EB);
}
