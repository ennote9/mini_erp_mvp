import 'package:flutter/material.dart';

import '../../shared/app_object_page_placeholder.dart';

/// Supplier page: create mode (/suppliers/new) or object mode (/suppliers/:id).
class SupplierPage extends StatelessWidget {
  const SupplierPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  Widget build(BuildContext context) {
    if (isCreateMode) {
      return AppObjectPagePlaceholder(
        breadcrumbSegments: ['Master Data', 'Suppliers', 'New Supplier'],
        title: 'New Supplier',
        placeholderMessage: 'Create form placeholder',
      );
    }
    return AppObjectPagePlaceholder(
      breadcrumbSegments: ['Master Data', 'Suppliers', id!],
      title: 'Supplier $id',
      placeholderMessage: 'Supplier details placeholder',
    );
  }
}
