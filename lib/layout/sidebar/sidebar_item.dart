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
    final activeColor = isDark
        ? AppColorTokens.sidebarActiveDark
        : AppColorTokens.sidebarActiveLight;
    final hoverColor = isDark
        ? AppColorTokens.sidebarHoverDark
        : AppColorTokens.sidebarHoverLight;
    final textColor = isActive
        ? activeColor
        : (isDark
              ? AppColorTokens.sidebarTextDark
              : AppColorTokens.sidebarTextLight);

    return Material(
      color: isActive ? hoverColor.withValues(alpha: 0.5) : Colors.transparent,
      child: InkWell(
        onTap: () => context.go(path),
        hoverColor: hoverColor.withValues(alpha: 0.6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 36;
            if (narrow) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Icon(icon, size: 20, color: textColor),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: textColor),
                  if (isExpanded) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
