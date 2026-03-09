import 'package:flutter/material.dart';

import '../../shared/app_document_page_placeholder.dart';

/// Sales Order page: create mode or object mode.
class SalesOrderPage extends StatelessWidget {
  const SalesOrderPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  Widget build(BuildContext context) {
    if (isCreateMode) {
      return AppDocumentPagePlaceholder(
        breadcrumbSegments: ['Sales', 'Sales Orders', 'New Sales Order'],
        title: 'New Sales Order',
        overviewPlaceholderMessage: 'Overview placeholder',
        linesPlaceholderMessage: 'Lines placeholder',
      );
    }
    return AppDocumentPagePlaceholder(
      breadcrumbSegments: ['Sales', 'Sales Orders', id!],
      title: 'Sales Order $id',
      statusLabel: 'Draft',
      overviewPlaceholderMessage: 'Overview placeholder',
      linesPlaceholderMessage: 'Lines placeholder',
    );
  }
}
