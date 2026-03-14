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
          AppSidebar(
            isExpanded: _sidebarExpanded,
            onCollapseToggle: () =>
                setState(() => _sidebarExpanded = !_sidebarExpanded),
          ),
          Expanded(child: PageFrame(child: widget.child)),
        ],
      ),
    );
  }
}
