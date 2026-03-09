import 'package:flutter/material.dart';

/// Main workspace frame: Page Top Bar + content. Used inside app shell.
/// Docs: 09_Navigation_and_App_Shell_v1.md (Main Workspace, Page Top Bar, Page Content)
class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
