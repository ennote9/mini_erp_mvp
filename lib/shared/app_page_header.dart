import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page header: optional back arrow, title, optional breadcrumb, optional actions (e.g. New).
/// Docs: 09_Navigation_and_App_Shell_v1.md (Page Top Bar), 11_List_Page_Pattern_v1.md
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.breadcrumb,
    this.actions,
    /// When set, shows a compact back arrow. Tap: pop if possible, else go to this route.
    this.backFallbackRoute,
  });

  final String title;
  final Widget? breadcrumb;
  final List<Widget>? actions;
  final String? backFallbackRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (breadcrumb != null) ...[
            breadcrumb!,
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (backFallbackRoute != null) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(backFallbackRoute!);
                    }
                  },
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(title, style: theme.textTheme.headlineSmall),
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
