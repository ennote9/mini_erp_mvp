import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_list_page_placeholder.dart';

class CustomersListPage extends StatelessWidget {
  const CustomersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListPagePlaceholder(
      title: 'Customers',
      showNewButton: true,
      onNewPressed: () =>
          context.go('/${AppRoutes.pathCustomers}/${AppRoutes.pathNew}'),
      placeholderMessage: 'No customers',
    );
  }
}
