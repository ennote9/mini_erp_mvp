import 'package:flutter/material.dart';

import '../../shared/app_object_page_placeholder.dart';

/// Warehouse page: create mode or object mode.
class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  Widget build(BuildContext context) {
    if (isCreateMode) {
      return AppObjectPagePlaceholder(
        breadcrumbSegments: ['Master Data', 'Warehouses', 'New Warehouse'],
        title: 'New Warehouse',
        placeholderMessage: 'Create form placeholder',
      );
    }
    return AppObjectPagePlaceholder(
      breadcrumbSegments: ['Master Data', 'Warehouses', id!],
      title: 'Warehouse $id',
      placeholderMessage: 'Warehouse details placeholder',
    );
  }
}
