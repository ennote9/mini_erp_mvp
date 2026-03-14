import 'package:flutter/material.dart';

import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../../shared/list_layout_constants.dart';
import '../../shared/list_page_workspace.dart';
import '../items/data/items_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/stock_balance.dart';
import 'data/stock_balances_repository.dart';

/// Stock Balances list. Read-only; no New, no detail page. Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1.
class StockBalancesListPage extends StatefulWidget {
  const StockBalancesListPage({super.key});

  @override
  State<StockBalancesListPage> createState() => _StockBalancesListPageState();
}

class _StockBalancesListPageState extends State<StockBalancesListPage> {
  final StockBalancesRepository _repo = stockBalancesRepository;
  final TextEditingController _searchController = TextEditingController();

  List<StockBalance> _balances = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _warehouseFilter;
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _balances = _repo.search(warehouseId: _warehouseFilter);
      if (_searchQuery.isNotEmpty) {
        _balances = _balances.where((b) {
          final item = itemsRepository.getById(b.itemId);
          if (item == null) return false;
          return item.code.toLowerCase().contains(_searchQuery) ||
              item.name.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _balances = _repo.search(warehouseId: _warehouseFilter);
      if (_searchQuery.isNotEmpty) {
        _balances = _balances.where((b) {
          final item = itemsRepository.getById(b.itemId);
          if (item == null) return false;
          return item.code.toLowerCase().contains(_searchQuery) ||
              item.name.toLowerCase().contains(_searchQuery);
        }).toList();
      }
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
        _balances = _repo.search(warehouseId: _warehouseFilter);
        _searchQuery = _searchController.text.trim().toLowerCase();
        if (_searchQuery.isNotEmpty) {
          _balances = _balances.where((b) {
            final item = itemsRepository.getById(b.itemId);
            if (item == null) return false;
            return item.code.toLowerCase().contains(_searchQuery) ||
                item.name.toLowerCase().contains(_searchQuery);
          }).toList();
        }
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
          const AppPageHeader(title: 'Stock Balances'),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.8)),
          Container(
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
            child: _ControlsBar(
              searchController: _searchController,
              warehouseFilter: _warehouseFilter,
              onWarehouseFilterChanged: (v) => setState(() {
                _warehouseFilter = v;
                _balances = _repo.search(warehouseId: v);
                _searchQuery = _searchController.text.trim().toLowerCase();
                if (_searchQuery.isNotEmpty) {
                  _balances = _balances.where((b) {
                    final item = itemsRepository.getById(b.itemId);
                    if (item == null) return false;
                    return item.code.toLowerCase().contains(_searchQuery) ||
                        item.name.toLowerCase().contains(_searchQuery);
                  }).toList();
                }
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
    if (_balances.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _warehouseFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No stock balances match current search'
            : 'No stock balances yet\nBalances will appear after posting receipts (and shipments)',
        icon: isFiltered ? Icons.search_off : Icons.balance_outlined,
      );
    }
    return _StockBalancesGrid(
      balances: _balances,
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
            for (final e in _balances) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.searchController,
    required this.warehouseFilter,
    required this.onWarehouseFilterChanged,
  });

  final TextEditingController searchController;
  final String? warehouseFilter;
  final void Function(String?) onWarehouseFilterChanged;

  @override
  Widget build(BuildContext context) {
    final warehouses = warehousesRepository.getAll().where((w) => w.isActive).toList();
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
                      hintText: 'Search by item code or name',
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
                      label: const Text('All warehouses'),
                      selected: warehouseFilter == null,
                      onSelected: (_) => onWarehouseFilterChanged(null),
                    ),
                    ...warehouses.expand((w) => [
                          const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                          ChoiceChip(
                            label: Text(w.name),
                            selected: warehouseFilter == w.id,
                            onSelected: (v) =>
                                onWarehouseFilterChanged(v ? w.id : null),
                          ),
                        ]),
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

class _StockBalancesGrid extends StatelessWidget {
  const _StockBalancesGrid({
    required this.balances,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
  });

  final List<StockBalance> balances;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = ListLayoutConstants.tableHeaderStyle(theme);
    final allSelected =
        balances.isNotEmpty && selectedIds.length == balances.length;
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
              DataColumn(label: Text('Item Code', style: headerStyle)),
              DataColumn(label: Text('Item Name', style: headerStyle)),
              DataColumn(label: Text('Warehouse', style: headerStyle)),
              DataColumn(label: Text('Qty On Hand', style: headerStyle)),
            ],
          rows: balances.asMap().entries.map((entry) {
            final index = entry.key;
            final b = entry.value;
            final selected = selectedIds.contains(b.id);
            final item = itemsRepository.getById(b.itemId);
            final warehouse = warehousesRepository.getById(b.warehouseId);
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
                    onChanged: (v) => onSelectionChanged(b.id, v ?? false),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColCode),
                    child: Text(item?.code ?? b.itemId),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColName),
                    child: Text(item?.name ?? ''),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColRelation),
                    child: Text(warehouse?.name ?? b.warehouseId),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColQty),
                    child: Text('${b.qtyOnHand}'),
                  ),
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
}
