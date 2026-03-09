import 'package:flutter/material.dart';

import '../../shared/app_list_page_placeholder.dart';

/// Shipments list. No New button per scope (Shipment created only from Confirmed SO).
class ShipmentsListPage extends StatelessWidget {
  const ShipmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListPagePlaceholder(
      title: 'Shipments',
      showNewButton: false,
      placeholderMessage: 'No shipments',
    );
  }
}
