import 'package:flutter/material.dart';

import '../../shared/app_document_page_placeholder.dart';

/// Receipt page. Object only (no create route).
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppDocumentPagePlaceholder(
      breadcrumbSegments: ['Purchasing', 'Receipts', id],
      title: 'Receipt $id',
      statusLabel: 'Draft',
      overviewPlaceholderMessage: 'Overview placeholder',
      linesPlaceholderMessage: 'Lines placeholder',
    );
  }
}
