import 'package:flutter/material.dart';

import '../../shared/app_document_page_placeholder.dart';

/// Shipment page. Object only (no create route).
class ShipmentPage extends StatelessWidget {
  const ShipmentPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppDocumentPagePlaceholder(
      breadcrumbSegments: ['Sales', 'Shipments', id],
      title: 'Shipment $id',
      statusLabel: 'Draft',
      overviewPlaceholderMessage: 'Overview placeholder',
      linesPlaceholderMessage: 'Lines placeholder',
    );
  }
}
