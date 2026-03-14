import 'package:flutter/material.dart';

import 'list_layout_constants.dart';

/// Wraps list page content in a composed workspace: visible panel + max width.
/// Matches reference: distinct work surface (slightly lighter panel), padding, rounded corners.
/// Docs: 11_List_Page_Pattern_v1.
class ListPageWorkspace extends StatelessWidget {
  const ListPageWorkspace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ListLayoutConstants.maxListContentWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(ListLayoutConstants.workspacePanelPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest
                .withValues(alpha: ListLayoutConstants.workspacePanelBackgroundOpacity),
            borderRadius: BorderRadius.circular(ListLayoutConstants.workspacePanelBorderRadius),
            border: Border.all(
              color: theme.colorScheme.outline
                  .withValues(alpha: ListLayoutConstants.workspacePanelBorderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
