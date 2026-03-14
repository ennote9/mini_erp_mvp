import 'package:flutter/material.dart';

import 'list_layout_constants.dart';

/// Wraps list page content in a composed workspace: max width and centered on large screens.
/// Keeps the list from feeling full-bleed on very wide displays without creating a narrow island.
/// Docs: 11_List_Page_Pattern_v1.
class ListPageWorkspace extends StatelessWidget {
  const ListPageWorkspace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ListLayoutConstants.maxListContentWidth),
        child: child,
      ),
    );
  }
}
