import 'package:flutter/material.dart';

/// Breadcrumb for object pages. Required on all object pages per docs.
/// Docs: 09_Navigation_and_App_Shell_v1.md, 12_Object_Page_Pattern_v1.md
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    super.key,
    required this.segments,
    this.onTap,
  });

  /// Ordered list of segment labels (e.g. ['Master Data', 'Items', 'ITEM-001']).
  final List<String> segments;

  /// Optional tap handler for segments (e.g. navigate). Phase 1: not used.
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          if (i > 0) const SizedBox(width: 4),
          GestureDetector(
            onTap: onTap != null ? () => onTap!(i) : null,
            child: Text(
              segments[i],
              style: textStyle,
            ),
          ),
        ],
      ],
    );
  }
}
