import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../../shared/list_layout_constants.dart';
import '../../shared/list_page_workspace.dart';
import '../items/data/items_repository.dart';
import '../receipts/data/receipts_repository.dart';
import '../shipments/data/shipments_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/stock_movement.dart';
import 'data/stock_movements_repository.dart';

/// Format createdAt (ISO-like) for display: dd.MM.yyyy HH:mm.
String _formatDateTime(String s) {
  if (s.trim().isEmpty) return '—';
  final d = DateTime.tryParse(s.trim());
  if (d == null) return s;
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Stock Movements list. Read-only; no New, no detail page. Navigation only via Source Document link.
/// Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1, 20_Grid_Interaction_Rules_v1.
class StockMovementsListPage extends StatefulWidget {
  const StockMovementsListPage({super.key});

  @override
  State<StockMovementsListPage> createState() => _StockMovementsListPageState();
}

class _StockMovementsListPageState extends State<StockMovementsListPage> {
  final StockMovementsRepository _repo = stockMovementsRepository;
  final TextEditingController _searchController = TextEditingController();

  List<StockMovement> _movements = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _movementTypeFilter;
  final Set<String> _selectedIds = {};

  bool _matchesSearch(StockMovement m) {
    if (_searchQuery.isEmpty) return true;
    final item = itemsRepository.getById(m.itemId);
    if (item != null &&
        (item.code.toLowerCase().contains(_searchQuery) ||
            item.name.toLowerCase().contains(_searchQuery))) {
      return true;
    }
    if (m.sourceDocumentType == 'receipt') {
      final receipt = receiptsRepository.getById(m.sourceDocumentId);
      if (receipt != null &&
          receipt.number.toLowerCase().contains(_searchQuery)) {
        return true;
      }
    }
    return false;
  }

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _movements = _repo.search(movementType: _movementTypeFilter);
      _movements = _movements.where(_matchesSearch).toList();
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _movements = _repo.search(movementType: _movementTypeFilter);
      _movements = _movements.where(_matchesSearch).toList();
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
        _movements = _repo.search(movementType: _movementTypeFilter);
        _searchQuery = _searchController.text.trim().toLowerCase();
        _movements = _movements.where(_matchesSearch).toList();
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
          const AppPageHeader(title: 'Stock Movements'),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.8)),
          Container(
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
            child: _ControlsBar(
              searchController: _searchController,
              movementTypeFilter: _movementTypeFilter,
              onMovementTypeFilterChanged: (v) => setState(() {
                _movementTypeFilter = v;
                _movements = _repo.search(movementType: v);
                _searchQuery = _searchController.text.trim().toLowerCase();
                _movements = _movements.where(_matchesSearch).toList();
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
    if (_movements.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _movementTypeFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No stock movements match current search'
            : 'No stock movements yet\nMovements will appear after posting receipts and shipments',
        icon: isFiltered ? Icons.search_off : Icons.swap_vert_outlined,
      );
    }
    return _StockMovementsGrid(movements: _movements, selectedIds: _selectedIds,
        onSelectionChanged: (id, selected) {
      setState(() {
        if (selected) {
          _selectedIds.add(id);
        } else {
          _selectedIds.remove(id);
        }
      });
    }, onSelectAll: (selected) {
      setState(() {
        if (selected) {
          for (final e in _movements) {
            _selectedIds.add(e.id);
          }
        } else {
          _selectedIds.clear();
        }
      });
    });
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.searchController,
    required this.movementTypeFilter,
    required this.onMovementTypeFilterChanged,
  });

  final TextEditingController searchController;
  final String? movementTypeFilter;
  final void Function(String?) onMovementTypeFilterChanged;

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
                      hintText: 'Search by item or document number',
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
                      selected: movementTypeFilter == null,
                      onSelected: (_) => onMovementTypeFilterChanged(null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Receipt'),
                      selected: movementTypeFilter == 'receipt',
                      onSelected: (v) =>
                          onMovementTypeFilterChanged(v ? 'receipt' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Shipment'),
                      selected: movementTypeFilter == 'shipment',
                      onSelected: (v) =>
                          onMovementTypeFilterChanged(v ? 'shipment' : null),
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

class _StockMovementsGrid extends StatelessWidget {
  const _StockMovementsGrid({
    required this.movements,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
  });

  final List<StockMovement> movements;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = ListLayoutConstants.tableHeaderStyle(theme);
    final allSelected =
        movements.isNotEmpty && selectedIds.length == movements.length;
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
              DataColumn(label: Text('Date/Time', style: headerStyle)),
              DataColumn(label: Text('Movement Type', style: headerStyle)),
              DataColumn(label: Text('Item Code', style: headerStyle)),
              DataColumn(label: Text('Item Name', style: headerStyle)),
              DataColumn(label: Text('Warehouse', style: headerStyle)),
              DataColumn(label: Text('Qty Delta', style: headerStyle)),
              DataColumn(label: Text('Source Document', style: headerStyle)),
            ],
          rows: movements.asMap().entries.map((entry) {
            final index = entry.key;
            final m = entry.value;
            final selected = selectedIds.contains(m.id);
            final item = itemsRepository.getById(m.itemId);
            final warehouse = warehousesRepository.getById(m.warehouseId);
            final subtleStrip = index.isOdd
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: ListLayoutConstants.tableRowAlternateOpacity)
                : null;
            String sourceLabel = '—';
            String? sourceRoute;
            if (m.sourceDocumentType == 'receipt') {
              final receipt = receiptsRepository.getById(m.sourceDocumentId);
              sourceLabel = receipt != null
                  ? 'Receipt ${receipt.number}'
                  : 'Receipt ${m.sourceDocumentId}';
              sourceRoute = '/${AppRoutes.pathReceipts}/${m.sourceDocumentId}';
            } else if (m.sourceDocumentType == 'shipment') {
              final shipment = shipmentsRepository.getById(m.sourceDocumentId);
              sourceLabel = shipment != null
                  ? 'Shipment ${shipment.number}'
                  : 'Shipment ${m.sourceDocumentId}';
              sourceRoute = '/${AppRoutes.pathShipments}/${m.sourceDocumentId}';
            }
            return DataRow(
              color: WidgetStateProperty.all(subtleStrip),
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(m.id, v ?? false),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColDateTime),
                    child: Text(_formatDateTime(m.createdAt)),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColMovementType),
                    child: _MovementTypeBadge(movementType: m.movementType),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColCode),
                    child: Text(item?.code ?? m.itemId),
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
                    child: Text(warehouse?.name ?? m.warehouseId),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColQty),
                    child: Text(
                        m.qtyDelta > 0 ? '+${m.qtyDelta}' : '${m.qtyDelta}'),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColSourceDocument),
                    child: sourceRoute != null
                        ? InkWell(
                            onTap: () => context.go(sourceRoute!),
                            child: Text(
                              sourceLabel,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : Text(sourceLabel),
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

class _MovementTypeBadge extends StatelessWidget {
  const _MovementTypeBadge({required this.movementType});

  final String movementType;

  @override
  Widget build(BuildContext context) {
    final label = movementType == 'receipt' ? 'Receipt' : movementType == 'shipment' ? 'Shipment' : movementType;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
