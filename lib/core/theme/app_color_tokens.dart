import 'package:flutter/material.dart';

/// Color tokens for the app. Dark-first, light-ready.
/// Docs: 09_Navigation_and_App_Shell_v1.md, 22_UI_Consistency_Rules_v1.md
class AppColorTokens {
  AppColorTokens._();

  // ----- Dark theme -----
  static const Color sidebarBackgroundDark = Color(0xFF1E2329);
  static const Color sidebarSurfaceDark = Color(0xFF252B33);
  static const Color sidebarTextDark = Color(0xFFE6EDF3);
  static const Color sidebarTextMutedDark = Color(0xFF8B949E);
  static const Color sidebarActiveDark = Color(0xFF388BFD);
  static const Color sidebarHoverDark = Color(0xFF30363D);

  static const Color surfaceDark = Color(0xFF0D1117);
  static const Color surfaceElevatedDark = Color(0xFF161B22);
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color borderDark = Color(0xFF30363D);
  static const Color dividerDark = Color(0xFF21262D);

  // ----- Light theme -----
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
