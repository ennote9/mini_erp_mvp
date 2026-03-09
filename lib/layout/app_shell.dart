import 'package:flutter/material.dart';

import 'page_frame.dart';
import 'sidebar/app_sidebar.dart';

/// Stable app shell: left sidebar (expand/collapse) + main workspace.
/// Docs: 09_Navigation_and_App_Shell_v1.md
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(isExpanded: _sidebarExpanded),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: IconButton(
                icon: Icon(
                  _sidebarExpanded
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          Expanded(child: PageFrame(child: widget.child)),
        ],
      ),
    );
  }
}
