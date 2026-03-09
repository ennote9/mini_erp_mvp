import 'package:flutter/material.dart';

import 'app_breadcrumb.dart';
import 'app_page_header.dart';

/// Document page placeholder: breadcrumb, header, summary block, Overview/Lines tabs, tab content.
/// For Purchase Order, Receipt, Sales Order, Shipment. Structurally distinct from master data.
/// Docs: 13_Document_Page_Layout_v1.md (breadcrumb, title+number, status, summary block, tabs Overview/Lines)
class AppDocumentPagePlaceholder extends StatelessWidget {
  const AppDocumentPagePlaceholder({
    super.key,
    required this.breadcrumbSegments,
    required this.title,
    this.statusLabel,
    this.overviewPlaceholderMessage =
        'Main document information will appear here.',
    this.linesPlaceholderMessage = 'Document lines will appear here.',
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Summary placeholder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tab bar: Overview / Lines
          TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _templateRow(context, 'Supplier', '—'),
                      const SizedBox(height: 8),
                      _templateRow(context, 'Warehouse', '—'),
                      const SizedBox(height: 8),
                      _templateRow(context, 'Date', '—'),
                      const SizedBox(height: 8),
                      _templateRow(context, 'Status', '—'),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lines',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _templateLinesContent(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _templateRow(BuildContext context, String label, String value) {
  final theme = Theme.of(context).textTheme;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Text(label, style: theme.bodySmall),
      ),
      Expanded(child: Text(value, style: theme.bodyMedium)),
    ],
  );
}

Widget _templateLinesContent(BuildContext context) {
  final theme = Theme.of(context).textTheme;
  return Table(
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(0.8),
      2: FlexColumnWidth(0.8),
    },
    children: [
      TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Item', style: theme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Qty', style: theme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('UOM', style: theme.bodySmall),
          ),
        ],
      ),
      TableRow(
        children: [
          Text('Item A', style: theme.bodyMedium),
          Text('10', style: theme.bodyMedium),
          Text('PCS', style: theme.bodyMedium),
        ],
      ),
      TableRow(
        children: [
          Text('Item B', style: theme.bodyMedium),
          Text('5', style: theme.bodyMedium),
          Text('BOX', style: theme.bodyMedium),
        ],
      ),
    ],
  );
}
