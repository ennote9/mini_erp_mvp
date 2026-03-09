import 'package:flutter/material.dart';

import '../../shared/app_list_page_placeholder.dart';

/// Stock Movements list. No New, no detail page in MVP (08_Screens_v1).
class StockMovementsListPage extends StatelessWidget {
  const StockMovementsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListPagePlaceholder(
      title: 'Stock Movements',
      showNewButton: false,
      placeholderMessage: 'No stock movements',
    );
  }
}
