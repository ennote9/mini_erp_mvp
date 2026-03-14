import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../purchase_orders/data/purchase_orders_repository.dart';
import '../warehouses/data/warehouses_repository.dart';
import 'data/receipt.dart';
import 'data/receipts_repository.dart';

/// Display date in dd.MM.yyyy format; "—" if invalid.
String _displayDate(String? s) {
  if (s == null || s.trim().isEmpty) return '—';
  final d = DateTime.tryParse(s.trim());
  if (d == null || d.year < 1900 || d.year > 2100) return '—';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Receipts list. No New button per scope (Receipt created only from Confirmed PO).
/// Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1.
class ReceiptsListPage extends StatefulWidget {
  const ReceiptsListPage({super.key});

  @override
  State<ReceiptsListPage> createState() => _ReceiptsListPageState();
}

class _ReceiptsListPageState extends State<ReceiptsListPage> {
  final ReceiptsRepository _repo = receiptsRepository;
  final TextEditingController _searchController = TextEditingController();

  List<Receipt> _receipts = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _statusFilter;
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _receipts = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _receipts = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
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
        _receipts = _repo.search(query: _searchQuery, statusFilter: _statusFilter);
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
        const AppPageHeader(title: 'Receipts'),
        const Divider(height: 1),
        _ControlsBar(
          searchController: _searchController,
          statusFilter: _statusFilter,
          onFilterChanged: (v) => setState(() {
            _statusFilter = v;
            _receipts = _repo.search(query: _searchQuery, statusFilter: v);
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
    if (_receipts.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _statusFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No receipts match current search'
            : 'No receipts yet',
        icon: isFiltered ? Icons.search_off : Icons.receipt_long_outlined,
      );
    }
    return _ReceiptsGrid(
      receipts: _receipts,
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
            for (final e in _receipts) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (r) => context.go('/${AppRoutes.pathReceipts}/${r.id}'),
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

class _ReceiptsGrid extends StatelessWidget {
  const _ReceiptsGrid({
    required this.receipts,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<Receipt> receipts;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(Receipt receipt) onRowTap;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        receipts.isNotEmpty && selectedIds.length == receipts.length;
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
            const DataColumn(label: Text('Date')),
            const DataColumn(label: Text('Purchase Order')),
            const DataColumn(label: Text('Warehouse')),
            const DataColumn(label: Text('Status')),
          ],
          rows: receipts.map((r) {
            final selected = selectedIds.contains(r.id);
            final po = purchaseOrdersRepository.getById(r.purchaseOrderId);
            final warehouse = warehousesRepository.getById(r.warehouseId);
            return DataRow(
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(r.id, v ?? false),
                  ),
                ),
                DataCell(Text(r.number), onTap: () => onRowTap(r)),
                DataCell(Text(_displayDate(r.date)), onTap: () => onRowTap(r)),
                DataCell(
                  Text(po?.number ?? r.purchaseOrderId),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  Text(warehouse?.name ?? r.warehouseId),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  Text(_statusLabel(r.status)),
                  onTap: () => onRowTap(r),
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
