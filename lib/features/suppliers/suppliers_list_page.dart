import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_list_page_placeholder.dart';

class SuppliersListPage extends StatelessWidget {
  const SuppliersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListPagePlaceholder(
      title: 'Suppliers',
      showNewButton: true,
      onNewPressed: () => context.go('/${AppRoutes.pathSuppliers}/${AppRoutes.pathNew}'),
      placeholderMessage: 'No suppliers',
    );
  }
}
