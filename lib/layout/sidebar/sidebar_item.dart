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
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(path),
        hoverColor: hoverColor.withValues(alpha: 0.4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 60;
            if (narrow) {
              // Collapsed: icon with subtle active background when selected
              return Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: isActive
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: hoverColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 20, color: textColor),
                        )
                      : Icon(icon, size: 22, color: textColor),
                ),
              );
            }
            // Expanded: active = soft background only, no hard border
            return Container(
              constraints: const BoxConstraints(minHeight: 36),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: hoverColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: textColor),
                    if (isExpanded) ...[
                      const SizedBox(width: 12),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
