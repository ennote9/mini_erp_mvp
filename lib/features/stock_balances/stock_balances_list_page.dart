import 'package:flutter/material.dart';

import '../../shared/app_list_page_placeholder.dart';

/// Stock Balances list. No New, no detail page in MVP (08_Screens_v1).
class StockBalancesListPage extends StatelessWidget {
  const StockBalancesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListPagePlaceholder(
      title: 'Stock Balances',
      showNewButton: false,
      placeholderMessage: 'No stock balances',
    );
  }
}
