import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../../shared/list_layout_constants.dart';
import '../../shared/list_page_workspace.dart';
import '../suppliers/data/suppliers_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/purchase_order.dart';
import 'data/purchase_orders_repository.dart';

/// Display PO date in dd.MM.yyyy format; "—" if invalid.
String _displayPoDate(String? s) {
  if (s == null || s.trim().isEmpty) return '—';
  final d = DateTime.tryParse(s.trim());
  if (d == null || d.year < 1900 || d.year > 2100) return '—';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Purchase Orders list page. Real grid, search, status filter, row click, New.
/// Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1, 20_Grid_Interaction_Rules_v1.
class PurchaseOrdersListPage extends StatefulWidget {
  const PurchaseOrdersListPage({super.key});

  @override
  State<PurchaseOrdersListPage> createState() => _PurchaseOrdersListPageState();
}

class _PurchaseOrdersListPageState extends State<PurchaseOrdersListPage> {
  final PurchaseOrdersRepository _repo = purchaseOrdersRepository;
  final TextEditingController _searchController = TextEditingController();

  List<PurchaseOrder> _orders = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _statusFilter; // null = All, or 'draft', 'confirmed', 'cancelled', 'closed'
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _orders = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _orders = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchAndFilter);
    _repo.version.addListener(_refreshFromRepo);
    _load();
  }

  void _load() {
    setState(() => _loading = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _orders = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _repo.version.removeListener(_refreshFromRepo);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListPageWorkspace(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPageHeader(
            title: 'Purchase Orders',
            actions: [
              FilledButton.icon(
                onPressed: () => context
                    .go('/${AppRoutes.pathPurchaseOrders}/${AppRoutes.pathNew}'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
              ),
            ],
          ),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.8)),
          Container(
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
            child: _ControlsBar(
              searchController: _searchController,
              statusFilter: _statusFilter,
              onFilterChanged: (v) => setState(() {
                _statusFilter = v;
                _orders = _repo.search(query: _searchQuery, statusFilter: v);
              }),
            ),
          ),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.8)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ListLayoutConstants.horizontalPadding),
                    child: _buildContent(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_orders.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _statusFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No purchase orders match current search'
            : 'No purchase orders yet\nCreate your first purchase order to start',
        icon: isFiltered ? Icons.search_off : Icons.description_outlined,
      );
    }
    return _PurchaseOrdersGrid(
      orders: _orders,
      selectedIds: _selectedIds,
      onSelectionChanged: (id, selected) {
        setState(() {
          if (selected) {
            _selectedIds.add(id);
          } else {
            _selectedIds.remove(id);
          }
        });
      },
      onSelectAll: (selected) {
        setState(() {
          if (selected) {
            for (final e in _orders) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (o) =>
          context.go('/${AppRoutes.pathPurchaseOrders}/${o.id}'),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.searchController,
    required this.statusFilter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final String? statusFilter;
  final void Function(String?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ListLayoutConstants.horizontalPadding,
        vertical: ListLayoutConstants.toolbarVerticalPadding,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ListLayoutConstants.toolbarClusterPaddingH,
              vertical: ListLayoutConstants.toolbarClusterPaddingV,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListLayoutConstants.toolbarClusterBorderRadius),
              color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: ListLayoutConstants.toolbarClusterBackgroundOpacity),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: ListLayoutConstants.searchFieldWidth,
                  height: ListLayoutConstants.searchFieldHeight,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by number',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ListLayoutConstants.searchContentPaddingH,
                        vertical: ListLayoutConstants.searchContentPaddingV,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ListLayoutConstants.gapSearchToFilters),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: statusFilter == null,
                      onSelected: (_) => onFilterChanged(null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Draft'),
                      selected: statusFilter == 'draft',
                      onSelected: (v) =>
                          onFilterChanged(v ? 'draft' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Confirmed'),
                      selected: statusFilter == 'confirmed',
                      onSelected: (v) =>
                          onFilterChanged(v ? 'confirmed' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Closed'),
                      selected: statusFilter == 'closed',
                      onSelected: (v) => onFilterChanged(v ? 'closed' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Cancelled'),
                      selected: statusFilter == 'cancelled',
                      onSelected: (v) =>
                          onFilterChanged(v ? 'cancelled' : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseOrdersGrid extends StatelessWidget {
  const _PurchaseOrdersGrid({
    required this.orders,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<PurchaseOrder> orders;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(PurchaseOrder order) onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = ListLayoutConstants.tableHeaderStyle(theme);
    final allSelected =
        orders.isNotEmpty && selectedIds.length == orders.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ListLayoutConstants.tableSurfaceBorderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: ListLayoutConstants.tableSurfaceBorderOpacity),
            ),
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: ListLayoutConstants.tableSurfaceBackgroundOpacity),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: ListLayoutConstants.tableHeadingRowHeight,
            dataRowMinHeight: ListLayoutConstants.tableDataRowHeight,
            dataRowMaxHeight: ListLayoutConstants.tableDataRowHeight,
            columnSpacing: ListLayoutConstants.tableColumnSpacing,
            horizontalMargin: ListLayoutConstants.tableHorizontalMargin,
            headingRowColor: WidgetStateProperty.resolveWith((states) {
              return theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: ListLayoutConstants.tableHeaderBackgroundOpacity);
            }),
            columns: [
              DataColumn(
                label: Checkbox(
                  value: allSelected,
                  tristate: true,
                  onChanged: (v) => onSelectAll(v == true),
                ),
              ),
              DataColumn(label: Text('Number', style: headerStyle)),
              DataColumn(label: Text('Date', style: headerStyle)),
              DataColumn(label: Text('Supplier', style: headerStyle)),
              DataColumn(label: Text('Warehouse', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
            ],
          rows: orders.asMap().entries.map((entry) {
            final index = entry.key;
            final o = entry.value;
            final selected = selectedIds.contains(o.id);
            final supplier = suppliersRepository.getById(o.supplierId);
            final warehouse = warehousesRepository.getById(o.warehouseId);
            final subtleStrip = index.isOdd
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: ListLayoutConstants.tableRowAlternateOpacity)
                : null;
            return DataRow(
              color: WidgetStateProperty.all(subtleStrip),
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) =>
                        onSelectionChanged(o.id, v ?? false),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColNumber),
                    child: Text(o.number),
                  ),
                  onTap: () => onRowTap(o),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColDate),
                    child: Text(_displayPoDate(o.date)),
                  ),
                  onTap: () => onRowTap(o),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColRelation),
                    child: Text(supplier?.name ?? o.supplierId),
                  ),
                  onTap: () => onRowTap(o),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColRelation),
                    child: Text(warehouse?.name ?? o.warehouseId),
                  ),
                  onTap: () => onRowTap(o),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColStatus),
                    child: Text(_statusLabel(o.status)),
                  ),
                  onTap: () => onRowTap(o),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ),
    );
      },
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'confirmed':
        return 'Confirmed';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
