import 'package:flutter/material.dart';

import 'app_breadcrumb.dart';
import 'app_page_header.dart';
import 'app_placeholder_state.dart';

/// Document page placeholder: breadcrumb, header, summary block, Overview/Lines tabs, tab content.
/// For Purchase Order, Receipt, Sales Order, Shipment. Structurally distinct from master data.
/// Docs: 13_Document_Page_Layout_v1.md (breadcrumb, title+number, status, summary block, tabs Overview/Lines)
class AppDocumentPagePlaceholder extends StatelessWidget {
  const AppDocumentPagePlaceholder({
    super.key,
    required this.breadcrumbSegments,
    required this.title,
    this.statusLabel,
    this.overviewPlaceholderMessage = 'Overview placeholder',
    this.linesPlaceholderMessage = 'Lines placeholder',
  });

  final List<String> breadcrumbSegments;
  final String title;
  final String? statusLabel;
  final String overviewPlaceholderMessage;
  final String linesPlaceholderMessage;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          // Summary block placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Summary placeholder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tab bar: Overview / Lines
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Lines'),
            ],
          ),
          const Divider(height: 1),
          // Tab content area
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AppPlaceholderState(
                    message: overviewPlaceholderMessage,
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AppPlaceholderState(message: linesPlaceholderMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
