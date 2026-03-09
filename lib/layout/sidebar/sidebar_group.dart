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
    final textColor = isDark ? AppColorTokens.sidebarTextMutedDark : AppColorTokens.sidebarTextMutedLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: textColor),
                if (widget.children.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: textColor,
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColorTokens.sidebarTextDark : AppColorTokens.sidebarTextLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_expanded && widget.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: widget.children,
            ),
          ),
      ],
    );
  }
}
