import 'package:flutter/material.dart';

import '../../core/theme/app_color_tokens.dart';
import 'sidebar_item.dart';

/// Collapsible sidebar group. Shows label when expanded; contains nav items.
class SidebarGroup extends StatefulWidget {
  const SidebarGroup({
    super.key,
    required this.label,
    required this.icon,
    required this.children,
    this.initiallyExpanded = true,
  });

  final String label;
  final IconData icon;
  final List<SidebarItem> children;
  final bool initiallyExpanded;

  @override
  State<SidebarGroup> createState() => _SidebarGroupState();
}

class _SidebarGroupState extends State<SidebarGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColorTokens.sidebarTextMutedDark
        : AppColorTokens.sidebarTextMutedLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 60;
            if (narrow) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Icon(widget.icon, size: 20, color: textColor),
                ),
              );
            }
            // Expanded: section label row (quiet, structural)
            return InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 16, color: textColor),
                    if (widget.children.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textColor.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 16,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ] else ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColorTokens.sidebarTextDark
                                : AppColorTokens.sidebarTextLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        if (_expanded && widget.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2),
            child: Column(children: widget.children),
          ),
      ],
    );
  }
}
