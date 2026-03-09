import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import 'data/item.dart';
import 'data/items_repository.dart';

/// Items list page. Real grid, search, filter, row click, New. Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1, 20_Grid_Interaction_Rules_v1.
class ItemsListPage extends StatefulWidget {
  const ItemsListPage({super.key});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  final ItemsRepository _repo = itemsRepository;
  final TextEditingController _searchController = TextEditingController();

  List<Item> _items = [];
  bool _loading = true;
  String _searchQuery = '';
  bool? _activeFilter; // null = All, true = Active, false = Inactive
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _items = _repo.search(query: _searchQuery, activeOnly: _activeFilter);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchAndFilter);
    _load();
  }

  void _load() {
    setState(() {
      _loading = true;
    });
    // In-memory is synchronous; brief delay to show loading state if desired.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _items = _repo.search(query: _searchQuery, activeOnly: _activeFilter);
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> get _filteredItems => _items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: 'Items',
          actions: [
            FilledButton.icon(
              onPressed: () => context.go('/${AppRoutes.pathItems}/${AppRoutes.pathNew}'),
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
            _items = _repo.search(query: _searchQuery, activeOnly: v);
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
    if (_filteredItems.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _activeFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No items match current search'
            : 'No items yet\nCreate your first item to start working with inventory',
        icon: isFiltered ? Icons.search_off : Icons.inventory_2_outlined,
      );
    }
    return _ItemsGrid(
      items: _filteredItems,
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
            for (final e in _filteredItems) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (item) => context.go('/${AppRoutes.pathItems}/${item.id}'),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _FilterChips(activeFilter: activeFilter, onFilterChanged: onFilterChanged),
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

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid({
    required this.items,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<Item> items;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(Item item) onRowTap;

  @override
  Widget build(BuildContext context) {
    final allSelected = items.isNotEmpty && selectedIds.length == items.length;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
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
            const DataColumn(label: Text('UOM')),
            const DataColumn(label: Text('Active')),
          ],
          rows: items.map((item) {
            final selected = selectedIds.contains(item.id);
            return DataRow(
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(item.id, v ?? false),
                  ),
                ),
                DataCell(Text(item.code), onTap: () => onRowTap(item)),
                DataCell(Text(item.name), onTap: () => onRowTap(item)),
                DataCell(Text(item.uom), onTap: () => onRowTap(item)),
                DataCell(Text(item.isActive ? 'Yes' : 'No'), onTap: () => onRowTap(item)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
