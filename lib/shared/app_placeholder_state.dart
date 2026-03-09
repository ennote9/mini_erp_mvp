import 'package:flutter/material.dart';

/// Generic placeholder or empty state. Single message, calm and readable.
/// Docs: 11_List_Page_Pattern_v1.md (empty state), 22_UI_Consistency_Rules_v1.md
class AppPlaceholderState extends StatelessWidget {
  const AppPlaceholderState({
    super.key,
    this.message = 'Placeholder',
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
