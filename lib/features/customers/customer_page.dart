import 'package:flutter/material.dart';

import '../../shared/app_object_page_placeholder.dart';

/// Customer page: create mode or object mode.
class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key, this.id});

  final String? id;

  bool get isCreateMode => id == null || id == 'new';

  @override
  Widget build(BuildContext context) {
    if (isCreateMode) {
      return AppObjectPagePlaceholder(
        breadcrumbSegments: ['Master Data', 'Customers', 'New Customer'],
        title: 'New Customer',
        placeholderMessage: 'Create form placeholder',
      );
    }
    return AppObjectPagePlaceholder(
      breadcrumbSegments: ['Master Data', 'Customers', id!],
      title: 'Customer $id',
      placeholderMessage: 'Customer details placeholder',
    );
  }
}
