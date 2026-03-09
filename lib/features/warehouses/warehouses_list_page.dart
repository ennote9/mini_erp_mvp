import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import 'data/warehouse.dart';
import 'data/warehouses_repository.dart';

/// Warehouses list page. Real grid, search, filter, row click, New. Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1, 20_Grid_Interaction_Rules_v1.
class WarehousesListPage extends StatefulWidget {
  const WarehousesListPage({super.key});

  @override
  State<WarehousesListPage> createState() => _WarehousesListPageState();
}

class _WarehousesListPageState extends State<WarehousesListPage> {
  final WarehousesRepository _repo = warehousesRepository;
  final TextEditingController _searchController = TextEditingController();

  List<Warehouse> _warehouses = [];
  bool _loading = true;
  String _searchQuery = '';
  bool? _activeFilter; // null = All, true = Active, false = Inactive
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _warehouses =
          _repo.search(query: _searchQuery, activeOnly: _activeFilter);
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _warehouses =
          _repo.search(query: _searchQuery, activeOnly: _activeFilter);
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
    setState(() {
      _loading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _warehouses =
            _repo.search(query: _searchQuery, activeOnly: _activeFilter);
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

  List<Warehouse> get _filteredWarehouses => _warehouses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: 'Warehouses',
          actions: [
            FilledButton.icon(
              onPressed: () => context
                  .go('/${AppRoutes.pathWarehouses}/${AppRoutes.pathNew}'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
            ),
          ],
        ),
        const Divider(height: 1),
        _ControlsBar(
          searchController: _searchController,
          activeFilter: _activeFilter,
          onFilterChanged: (v) => setState(() {
            _activeFilter = v;
            _warehouses = _repo.search(query: _searchQuery, activeOnly: v);
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
    if (_filteredWarehouses.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _activeFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No warehouses match current search'
            : 'No warehouses yet\nCreate your first warehouse to manage inventory locations',
        icon: isFiltered ? Icons.search_off : Icons.warehouse_outlined,
      );
    }
    return _WarehousesGrid(
      warehouses: _filteredWarehouses,
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
            for (final e in _filteredWarehouses) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (w) => context.go('/${AppRoutes.pathWarehouses}/${w.id}'),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final bool? activeFilter;
  final void Function(bool?) onFilterChanged;

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
                hintText: 'Search',
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
          _FilterChips(
            activeFilter: activeFilter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final bool? activeFilter;
  final void Function(bool?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: activeFilter == null,
          onSelected: (_) => onFilterChanged(null),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Active'),
          selected: activeFilter == true,
          onSelected: (v) {
            onFilterChanged(v ? true : null);
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Inactive'),
          selected: activeFilter == false,
          onSelected: (v) {
            onFilterChanged(v ? false : null);
          },
        ),
      ],
    );
  }
}

class _WarehousesGrid extends StatelessWidget {
  const _WarehousesGrid({
    required this.warehouses,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<Warehouse> warehouses;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(Warehouse warehouse) onRowTap;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        warehouses.isNotEmpty && selectedIds.length == warehouses.length;
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
            const DataColumn(label: Text('Code')),
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('Active')),
          ],
          rows: warehouses.map((w) {
            final selected = selectedIds.contains(w.id);
            return DataRow(
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(w.id, v ?? false),
                  ),
                ),
                DataCell(Text(w.code), onTap: () => onRowTap(w)),
                DataCell(Text(w.name), onTap: () => onRowTap(w)),
                DataCell(
                  Text(w.isActive ? 'Yes' : 'No'),
                  onTap: () => onRowTap(w),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
