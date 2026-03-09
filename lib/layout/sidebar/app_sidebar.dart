import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_color_tokens.dart';
import '../../core/router/app_routes.dart';
import 'sidebar_group.dart';
import 'sidebar_item.dart';

/// Left sidebar: expanded/collapsed, grouped navigation, active route highlighting.
/// Docs: 09_Navigation_and_App_Shell_v1.md (Sidebar structure and behavior)
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required this.isExpanded});

  final bool isExpanded;

  static bool _isActive(String location, String path) {
    if (path == '/${AppRoutes.pathDashboard}') {
      return location == path || location == '/' || location.isEmpty;
    }
    return location == path ||
        (location.startsWith('$path/') && location.length > path.length + 1);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColorTokens.sidebarBackgroundDark
        : AppColorTokens.sidebarBackgroundLight;

    return Container(
      width: isExpanded ? 240 : 56,
      color: bg,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Dashboard (single item per 09_Navigation_and_App_Shell_v1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              path: '/${AppRoutes.pathDashboard}',
              isExpanded: isExpanded,
              isActive: _isActive(location, '/${AppRoutes.pathDashboard}'),
            ),
          ),
          const SizedBox(height: 12),
          // Master Data
          SidebarGroup(
            label: 'Master Data',
            icon: Icons.folder_outlined,
            initiallyExpanded: true,
            children: [
              SidebarItem(
                icon: Icons.inventory_2_outlined,
                label: 'Items',
                path: '/${AppRoutes.pathItems}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathItems}' ||
                    location.startsWith('/${AppRoutes.pathItems}/'),
              ),
              SidebarItem(
                icon: Icons.local_shipping_outlined,
                label: 'Suppliers',
                path: '/${AppRoutes.pathSuppliers}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathSuppliers}' ||
                    location.startsWith('/${AppRoutes.pathSuppliers}/'),
              ),
              SidebarItem(
                icon: Icons.person_outline,
                label: 'Customers',
                path: '/${AppRoutes.pathCustomers}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathCustomers}' ||
                    location.startsWith('/${AppRoutes.pathCustomers}/'),
              ),
              SidebarItem(
                icon: Icons.warehouse_outlined,
                label: 'Warehouses',
                path: '/${AppRoutes.pathWarehouses}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathWarehouses}' ||
                    location.startsWith('/${AppRoutes.pathWarehouses}/'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Purchasing
          SidebarGroup(
            label: 'Purchasing',
            icon: Icons.shopping_cart_outlined,
            initiallyExpanded: true,
            children: [
              SidebarItem(
                icon: Icons.description_outlined,
                label: 'Purchase Orders',
                path: '/${AppRoutes.pathPurchaseOrders}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathPurchaseOrders}' ||
                    location.startsWith('/${AppRoutes.pathPurchaseOrders}/'),
              ),
              SidebarItem(
                icon: Icons.receipt_long_outlined,
                label: 'Receipts',
                path: '/${AppRoutes.pathReceipts}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathReceipts}' ||
                    location.startsWith('/${AppRoutes.pathReceipts}/'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sales
          SidebarGroup(
            label: 'Sales',
            icon: Icons.sell_outlined,
            initiallyExpanded: true,
            children: [
              SidebarItem(
                icon: Icons.description_outlined,
                label: 'Sales Orders',
                path: '/${AppRoutes.pathSalesOrders}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathSalesOrders}' ||
                    location.startsWith('/${AppRoutes.pathSalesOrders}/'),
              ),
              SidebarItem(
                icon: Icons.local_shipping_outlined,
                label: 'Shipments',
                path: '/${AppRoutes.pathShipments}',
                isExpanded: isExpanded,
                isActive:
                    location == '/${AppRoutes.pathShipments}' ||
                    location.startsWith('/${AppRoutes.pathShipments}/'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Inventory
          SidebarGroup(
            label: 'Inventory',
            icon: Icons.inventory_outlined,
            initiallyExpanded: true,
            children: [
              SidebarItem(
                icon: Icons.balance_outlined,
                label: 'Stock Balances',
                path: '/${AppRoutes.pathStockBalances}',
                isExpanded: isExpanded,
                isActive: location == '/${AppRoutes.pathStockBalances}',
              ),
              SidebarItem(
                icon: Icons.swap_vert_outlined,
                label: 'Stock Movements',
                path: '/${AppRoutes.pathStockMovements}',
                isExpanded: isExpanded,
                isActive: location == '/${AppRoutes.pathStockMovements}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
