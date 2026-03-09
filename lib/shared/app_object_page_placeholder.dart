import 'package:flutter/material.dart';

import 'app_breadcrumb.dart';
import 'app_page_header.dart';
import 'app_placeholder_state.dart';

/// Standard object page placeholder: breadcrumb, header, summary/content area.
/// Docs: 12_Object_Page_Pattern_v1.md (A. Breadcrumb, B. Header, C. Summary, D. Main Content)
class AppObjectPagePlaceholder extends StatelessWidget {
  const AppObjectPagePlaceholder({
    super.key,
    required this.breadcrumbSegments,
    required this.title,
    this.statusLabel,
    this.actions,
    this.placeholderMessage = 'Placeholder',
  });

  final List<String> breadcrumbSegments;
  final String title;
  final String? statusLabel;
  final List<Widget>? actions;
  final String placeholderMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: title,
          breadcrumb: AppBreadcrumb(segments: breadcrumbSegments),
          actions: [
            if (statusLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            if (actions != null && actions!.isNotEmpty) ...[
              if (statusLabel != null) const SizedBox(width: 12),
              ...actions!,
            ],
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AppPlaceholderState(message: placeholderMessage),
          ),
        ),
      ],
    );
  }
}
