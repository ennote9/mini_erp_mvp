import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppPageHeader(title: 'Stock Movements'),
        const Divider(height: 1),
        _ControlsBar(
          searchController: _searchController,
          movementTypeFilter: _movementTypeFilter,
          onMovementTypeFilterChanged: (v) => setState(() {
            _movementTypeFilter = v;
            _movements = _repo.search(movementType: v);
            _searchQuery = _searchController.text.trim().toLowerCase();
            _movements = _movements.where(_matchesSearch).toList();
          }),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 240,
            height: 36,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by item or document number',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: movementTypeFilter == null,
                onSelected: (_) => onMovementTypeFilterChanged(null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Receipt'),
                selected: movementTypeFilter == 'receipt',
                onSelected: (v) =>
                    onMovementTypeFilterChanged(v ? 'receipt' : null),
              ),
              const SizedBox(width: 8),
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
    final allSelected =
        movements.isNotEmpty && selectedIds.length == movements.length;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5);
          }),
          columns: [
            DataColumn(
              label: Checkbox(
                value: allSelected,
                tristate: true,
                onChanged: (v) => onSelectAll(v == true),
              ),
            ),
            const DataColumn(label: Text('Date/Time')),
            const DataColumn(label: Text('Movement Type')),
            const DataColumn(label: Text('Item Code')),
            const DataColumn(label: Text('Item Name')),
            const DataColumn(label: Text('Warehouse')),
            const DataColumn(label: Text('Qty Delta')),
            const DataColumn(label: Text('Source Document')),
          ],
          rows: movements.map((m) {
            final selected = selectedIds.contains(m.id);
            final item = itemsRepository.getById(m.itemId);
            final warehouse = warehousesRepository.getById(m.warehouseId);
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
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(m.id, v ?? false),
                  ),
                ),
                DataCell(Text(_formatDateTime(m.createdAt))),
                DataCell(_MovementTypeBadge(movementType: m.movementType)),
                DataCell(Text(item?.code ?? m.itemId)),
                DataCell(Text(item?.name ?? '')),
                DataCell(Text(warehouse?.name ?? m.warehouseId)),
                DataCell(Text(m.qtyDelta > 0 ? '+${m.qtyDelta}' : '${m.qtyDelta}')),
                DataCell(
                  sourceRoute != null
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
              ],
            );
          }).toList(),
        ),
      ),
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
