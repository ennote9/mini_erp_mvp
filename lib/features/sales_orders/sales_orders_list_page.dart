import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_list_page_placeholder.dart';

class SalesOrdersListPage extends StatelessWidget {
  const SalesOrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListPagePlaceholder(
      title: 'Sales Orders',
      showNewButton: true,
      onNewPressed: () => context.go('/${AppRoutes.pathSalesOrders}/${AppRoutes.pathNew}'),
      placeholderMessage: 'No sales orders',
    );
  }
}
