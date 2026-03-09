import 'package:flutter/material.dart';

/// Page header: title, optional breadcrumb, optional actions (e.g. New).
/// Docs: 09_Navigation_and_App_Shell_v1.md (Page Top Bar), 11_List_Page_Pattern_v1.md
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.breadcrumb,
    this.actions,
  });

  final String title;
  final Widget? breadcrumb;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (breadcrumb != null) ...[
            breadcrumb!,
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: 16),
                ...actions!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
