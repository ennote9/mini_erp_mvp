import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_list_page_placeholder.dart';

class PurchaseOrdersListPage extends StatelessWidget {
  const PurchaseOrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListPagePlaceholder(
      title: 'Purchase Orders',
      showNewButton: true,
      onNewPressed: () => context.go('/${AppRoutes.pathPurchaseOrders}/${AppRoutes.pathNew}'),
      placeholderMessage: 'No purchase orders',
    );
  }
}
