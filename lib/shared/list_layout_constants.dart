// Shared layout constants for list/grid pages. Ensures controls bar, table rhythm,
// and column discipline are consistent across all list pages. Docs: 11_List_Page_Pattern_v1.

import 'package:flutter/material.dart';

class ListLayoutConstants {
  ListLayoutConstants._();

  // ----- Workspace composition -----
  static const double maxListContentWidth = 1600;
  static const double workspacePanelPadding = 24;
  static const double workspacePanelBorderRadius = 10;
  static const double workspacePanelBackgroundOpacity = 0.38;
  static const double workspacePanelBorderOpacity = 0.18;
  /// Alternating row tint for body rows (reference-style).
  static const double tableRowAlternateOpacity = 0.1;

  // ----- Controls bar / toolbar -----
  static const double horizontalPadding = 24;
  static const double controlsVerticalPadding = 12;
  static const double toolbarVerticalPadding = 14;
  /// Inner padding for the search+chips cluster so it reads as one control group.
  static const double toolbarClusterPaddingH = 14;
  static const double toolbarClusterPaddingV = 10;
  static const double toolbarClusterBorderRadius = 6;
  static const double toolbarClusterBackgroundOpacity = 0.45;
  static const double searchFieldWidth = 240;
  static const double searchFieldHeight = 36;
  static const double searchContentPaddingH = 12;
  static const double searchContentPaddingV = 8;
  static const double gapSearchToFilters = 16;
  static const double gapBetweenChips = 8;

  // ----- Table surface -----
  static const double tableSurfaceBorderRadius = 8;
  static const double tableSurfaceBorderOpacity = 0.35;
  static const double tableSurfaceBackgroundOpacity = 0.32;

  // ----- Table rhythm (list pages override theme for alignment) -----
  static const double tableHeadingRowHeight = 40;
  static const double tableDataRowHeight = 38;
  static const double tableColumnSpacing = 20;
  /// Inner margin so table content is framed and does not sit flush on container.
  static const double tableHorizontalMargin = 16;
  static const double tableHeaderBackgroundOpacity = 0.52;

  // ----- Column minimum widths (stable key columns, balanced for workspace) -----
  static const double minColCheckbox = 48;
  static const double minColNumber = 100;
  static const double minColDate = 96;
  static const double minColStatus = 92;
  static const double minColCode = 88;
  static const double minColName = 140;
  static const double minColRelation = 120;
  static const double minColQty = 72;
  static const double minColDateTime = 120;
  static const double minColSourceDocument = 140;
  static const double minColActive = 56;
  static const double minColUom = 56;
  static const double minColMovementType = 88;

  /// Subdued, product-grade style for table header labels.
  static TextStyle? tableHeaderStyle(ThemeData theme) {
    return theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );
  }
}
