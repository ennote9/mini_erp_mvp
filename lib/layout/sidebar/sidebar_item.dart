import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_color_tokens.dart';

/// Single sidebar nav item. Icon + label when expanded. Active state from route.
class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.path,
    required this.isExpanded,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool isExpanded;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColorTokens.sidebarActiveDark : AppColorTokens.sidebarActiveLight;
    final hoverColor = isDark ? AppColorTokens.sidebarHoverDark : AppColorTokens.sidebarHoverLight;
    final textColor = isActive
        ? activeColor
        : (isDark ? AppColorTokens.sidebarTextDark : AppColorTokens.sidebarTextLight);

    return Material(
      color: isActive ? hoverColor.withValues(alpha: 0.5) : Colors.transparent,
      child: InkWell(
        onTap: () => context.go(path),
        hoverColor: hoverColor.withValues(alpha: 0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 22, color: textColor),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
