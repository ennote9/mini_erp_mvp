import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_list_page_placeholder.dart';

class WarehousesListPage extends StatelessWidget {
  const WarehousesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListPagePlaceholder(
      title: 'Warehouses',
      showNewButton: true,
      onNewPressed: () =>
          context.go('/${AppRoutes.pathWarehouses}/${AppRoutes.pathNew}'),
      placeholderMessage: 'No warehouses',
    );
  }
}
