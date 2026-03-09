import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';

/// Dashboard: overview page (not a list). Block structure per 17_Dashboard_v1.md.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(title: 'Dashboard'),
          const SizedBox(height: 24),
          // A. Summary Cards
          Text('Summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _DashboardCard(
                title: 'Items',
                subtitle: '0',
                onTap: () => context.go('/${AppRoutes.pathItems}'),
              ),
              const SizedBox(width: 16),
              _DashboardCard(
                title: 'Suppliers',
                subtitle: '0',
                onTap: () => context.go('/${AppRoutes.pathSuppliers}'),
              ),
              const SizedBox(width: 16),
              _DashboardCard(
                title: 'Customers',
                subtitle: '0',
                onTap: () => context.go('/${AppRoutes.pathCustomers}'),
              ),
              const SizedBox(width: 16),
              _DashboardCard(
                title: 'Warehouses',
                subtitle: '0',
                onTap: () => context.go('/${AppRoutes.pathWarehouses}'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // B. Stock Overview
          Text(
            'Stock Overview',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Total items with stock: 0'),
                  const SizedBox(width: 24),
                  const Text('Total quantity on hand: 0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // C & D & E - Latest blocks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Latest Purchase Orders',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No data'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Latest Sales Orders',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No data'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Latest Stock Movements',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No data'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // F. Quick Navigation
          Text(
            'Quick Navigation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickLink(
                label: 'Items',
                onTap: () => context.go('/${AppRoutes.pathItems}'),
              ),
              _QuickLink(
                label: 'Suppliers',
                onTap: () => context.go('/${AppRoutes.pathSuppliers}'),
              ),
              _QuickLink(
                label: 'Customers',
                onTap: () => context.go('/${AppRoutes.pathCustomers}'),
              ),
              _QuickLink(
                label: 'Warehouses',
                onTap: () => context.go('/${AppRoutes.pathWarehouses}'),
              ),
              _QuickLink(
                label: 'Purchase Orders',
                onTap: () => context.go('/${AppRoutes.pathPurchaseOrders}'),
              ),
              _QuickLink(
                label: 'Receipts',
                onTap: () => context.go('/${AppRoutes.pathReceipts}'),
              ),
              _QuickLink(
                label: 'Sales Orders',
                onTap: () => context.go('/${AppRoutes.pathSalesOrders}'),
              ),
              _QuickLink(
                label: 'Shipments',
                onTap: () => context.go('/${AppRoutes.pathShipments}'),
              ),
              _QuickLink(
                label: 'Stock Balances',
                onTap: () => context.go('/${AppRoutes.pathStockBalances}'),
              ),
              _QuickLink(
                label: 'Stock Movements',
                onTap: () => context.go('/${AppRoutes.pathStockMovements}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(label));
  }
}
