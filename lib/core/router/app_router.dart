import 'package:go_router/go_router.dart';

import '../../layout/app_shell.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/items/items_list_page.dart';
import '../../features/items/item_page.dart';
import '../../features/suppliers/suppliers_list_page.dart';
import '../../features/suppliers/supplier_page.dart';
import '../../features/customers/customers_list_page.dart';
import '../../features/customers/customer_page.dart';
import '../../features/warehouses/warehouses_list_page.dart';
import '../../features/warehouses/warehouse_page.dart';
import '../../features/purchase_orders/purchase_orders_list_page.dart';
import '../../features/purchase_orders/purchase_order_page.dart';
import '../../features/receipts/receipts_list_page.dart';
import '../../features/receipts/receipt_page.dart';
import '../../features/sales_orders/sales_orders_list_page.dart';
import '../../features/sales_orders/sales_order_page.dart';
import '../../features/shipments/shipments_list_page.dart';
import '../../features/shipments/shipment_page.dart';
import '../../features/stock_balances/stock_balances_list_page.dart';
import '../../features/stock_movements/stock_movements_list_page.dart';
import 'app_routes.dart';

/// go_router config. /new routes before :id. Dashboard initial.
/// Docs: 10_Screen_to_Screen_Navigation_Map_v1.md
final GoRouter appRouter = GoRouter(
  initialLocation: '/${AppRoutes.pathDashboard}',
  redirect: (context, state) {
    final path = state.uri.path;
    if (path.isEmpty || path == '/') return '/${AppRoutes.pathDashboard}';
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/${AppRoutes.pathDashboard}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: '/${AppRoutes.pathItems}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ItemsListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ItemPage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: ItemPage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathSuppliers}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SuppliersListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SupplierPage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: SupplierPage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathCustomers}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CustomersListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: CustomerPage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: CustomerPage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathWarehouses}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WarehousesListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: WarehousePage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: WarehousePage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathPurchaseOrders}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PurchaseOrdersListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: PurchaseOrderPage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: PurchaseOrderPage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathReceipts}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReceiptsListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: ReceiptPage(id: state.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathSalesOrders}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SalesOrdersListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathNew,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SalesOrderPage(id: 'new')),
            ),
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: SalesOrderPage(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathShipments}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ShipmentsListPage()),
          routes: [
            GoRoute(
              path: AppRoutes.pathId,
              pageBuilder: (context, state) => NoTransitionPage(
                child: ShipmentPage(id: state.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/${AppRoutes.pathStockBalances}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StockBalancesListPage()),
        ),
        GoRoute(
          path: '/${AppRoutes.pathStockMovements}',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StockMovementsListPage()),
        ),
      ],
    ),
  ],
);
