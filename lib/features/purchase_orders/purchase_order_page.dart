import 'package:flutter/material.dart';

import '../../shared/app_document_page_placeholder.dart';

/// Purchase Order page: create mode (/purchase-orders/new) or object mode (/purchase-orders/:id).
class PurchaseOrderPage extends StatelessWidget {
  const PurchaseOrderPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  Widget build(BuildContext context) {
    if (isCreateMode) {
      return AppDocumentPagePlaceholder(
        breadcrumbSegments: ['Purchasing', 'Purchase Orders', 'New Purchase Order'],
        title: 'New Purchase Order',
        overviewPlaceholderMessage: 'Overview placeholder',
        linesPlaceholderMessage: 'Lines placeholder',
      );
    }
    return AppDocumentPagePlaceholder(
      breadcrumbSegments: ['Purchasing', 'Purchase Orders', id!],
      title: 'Purchase Order $id',
      statusLabel: 'Draft',
      overviewPlaceholderMessage: 'Overview placeholder',
      linesPlaceholderMessage: 'Lines placeholder',
    );
  }
}
