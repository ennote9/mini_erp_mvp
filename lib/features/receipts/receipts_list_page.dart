import 'package:flutter/material.dart';

import '../../shared/app_list_page_placeholder.dart';

/// Receipts list. No New button per scope (Receipt created only from Confirmed PO).
class ReceiptsListPage extends StatelessWidget {
  const ReceiptsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListPagePlaceholder(
      title: 'Receipts',
      showNewButton: false,
      placeholderMessage: 'No receipts',
    );
  }
}
