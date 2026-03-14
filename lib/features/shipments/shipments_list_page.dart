import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../sales_orders/data/sales_orders_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/shipment.dart';
import 'data/shipments_repository.dart';

/// Display date in dd.MM.yyyy format; "—" if invalid.
String _displayDate(String? s) {
  if (s == null || s.trim().isEmpty) return '—';
  final d = DateTime.tryParse(s.trim());
  if (d == null || d.year < 1900 || d.year > 2100) return '—';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Shipments list. No New button per scope (Shipment created only from Confirmed SO).
/// Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1.
class ShipmentsListPage extends StatefulWidget {
  const ShipmentsListPage({super.key});

  @override
  State<ShipmentsListPage> createState() => _ShipmentsListPageState();
}

class _ShipmentsListPageState extends State<ShipmentsListPage> {
  final ShipmentsRepository _repo = shipmentsRepository;
  final TextEditingController _searchController = TextEditingController();

  List<Shipment> _shipments = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _statusFilter;
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _shipments = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _shipments = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
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
        _shipments = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
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
        const AppPageHeader(title: 'Shipments'),
        const Divider(height: 1),
        _ControlsBar(
          searchController: _searchController,
          statusFilter: _statusFilter,
          onFilterChanged: (v) => setState(() {
            _statusFilter = v;
            _shipments = _repo.search(query: _searchQuery, statusFilter: v);
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
    if (_shipments.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _statusFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No shipments match current search'
            : 'No shipments yet',
        icon: isFiltered ? Icons.search_off : Icons.local_shipping_outlined,
      );
    }
    return _ShipmentsGrid(
      shipments: _shipments,
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
            for (final e in _shipments) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (s) => context.go('/${AppRoutes.pathShipments}/${s.id}'),
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
                hintText: 'Search by number',
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
                selected: statusFilter == null,
                onSelected: (_) => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Draft'),
                selected: statusFilter == 'draft',
                onSelected: (v) => onFilterChanged(v ? 'draft' : null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Posted'),
                selected: statusFilter == 'posted',
                onSelected: (v) => onFilterChanged(v ? 'posted' : null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Cancelled'),
                selected: statusFilter == 'cancelled',
                onSelected: (v) => onFilterChanged(v ? 'cancelled' : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShipmentsGrid extends StatelessWidget {
  const _ShipmentsGrid({
    required this.shipments,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<Shipment> shipments;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(Shipment shipment) onRowTap;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        shipments.isNotEmpty && selectedIds.length == shipments.length;
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
            const DataColumn(label: Text('Number')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Sales Order')),
            DataColumn(label: Text('Warehouse')),
            DataColumn(label: Text('Status')),
          ],
          rows: shipments.map((s) {
            final selected = selectedIds.contains(s.id);
            final so = salesOrdersRepository.getById(s.salesOrderId);
            final warehouse = warehousesRepository.getById(s.warehouseId);
            return DataRow(
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(s.id, v ?? false),
                  ),
                ),
                DataCell(Text(s.number), onTap: () => onRowTap(s)),
                DataCell(Text(_displayDate(s.date)), onTap: () => onRowTap(s)),
                DataCell(
                  Text(so?.number ?? s.salesOrderId),
                  onTap: () => onRowTap(s),
                ),
                DataCell(
                  Text(warehouse?.name ?? s.warehouseId),
                  onTap: () => onRowTap(s),
                ),
                DataCell(
                  Text(_statusLabel(s.status)),
                  onTap: () => onRowTap(s),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
