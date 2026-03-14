import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../../shared/list_layout_constants.dart';
import '../../shared/list_page_workspace.dart';
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
    final theme = Theme.of(context);
    return ListPageWorkspace(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppPageHeader(title: 'Receipts'),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.8)),
          Container(
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
            child: _ControlsBar(
              searchController: _searchController,
              statusFilter: _statusFilter,
              onFilterChanged: (v) => setState(() {
                _statusFilter = v;
                _receipts = _repo.search(query: _searchQuery, statusFilter: v);
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
    if (_receipts.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _statusFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No receipts match current search'
            : 'No receipts yet\nReceipts are created from confirmed purchase orders.',
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
                      onSelected: (v) => onFilterChanged(v ? 'draft' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Posted'),
                      selected: statusFilter == 'posted',
                      onSelected: (v) => onFilterChanged(v ? 'posted' : null),
                    ),
                    const SizedBox(width: ListLayoutConstants.gapBetweenChips),
                    ChoiceChip(
                      label: const Text('Cancelled'),
                      selected: statusFilter == 'cancelled',
                      onSelected: (v) => onFilterChanged(v ? 'cancelled' : null),
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
    final theme = Theme.of(context);
    final headerStyle = ListLayoutConstants.tableHeaderStyle(theme);
    final allSelected =
        receipts.isNotEmpty && selectedIds.length == receipts.length;
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
              DataColumn(label: Text('Purchase Order', style: headerStyle)),
              DataColumn(label: Text('Warehouse', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
            ],
          rows: receipts.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;
            final selected = selectedIds.contains(r.id);
            final po = purchaseOrdersRepository.getById(r.purchaseOrderId);
            final warehouse = warehousesRepository.getById(r.warehouseId);
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
                    onChanged: (v) => onSelectionChanged(r.id, v ?? false),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColNumber),
                    child: Text(r.number),
                  ),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColDate),
                    child: Text(_displayDate(r.date)),
                  ),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColRelation),
                    child: Text(po?.number ?? r.purchaseOrderId),
                  ),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColRelation),
                    child: Text(warehouse?.name ?? r.warehouseId),
                  ),
                  onTap: () => onRowTap(r),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColStatus),
                    child: Text(_statusLabel(r.status)),
                  ),
                  onTap: () => onRowTap(r),
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
      case 'posted':
        return 'Posted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
