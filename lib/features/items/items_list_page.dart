import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import '../../shared/list_layout_constants.dart';
import '../../shared/list_page_workspace.dart';
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

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _items = _repo.search(query: _searchQuery, activeOnly: _activeFilter);
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
        _items = _repo.search(query: _searchQuery, activeOnly: _activeFilter);
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

  List<Item> get _filteredItems => _items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListPageWorkspace(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPageHeader(
            title: 'Items',
            actions: [
              FilledButton.icon(
                onPressed: () =>
                    context.go('/${AppRoutes.pathItems}/${AppRoutes.pathNew}'),
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
              activeFilter: _activeFilter,
              onFilterChanged: (v) => setState(() {
                _activeFilter = v;
                _items = _repo.search(query: _searchQuery, activeOnly: v);
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
                      hintText: 'Search by code or name',
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
                _FilterChips(
                  activeFilter: activeFilter,
                  onFilterChanged: onFilterChanged,
                ),
              ],
            ),
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
        const SizedBox(width: ListLayoutConstants.gapBetweenChips),
        ChoiceChip(
          label: const Text('Active'),
          selected: activeFilter == true,
          onSelected: (v) {
            onFilterChanged(v ? true : null);
          },
        ),
        const SizedBox(width: ListLayoutConstants.gapBetweenChips),
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
    final theme = Theme.of(context);
    final allSelected = items.isNotEmpty && selectedIds.length == items.length;
    final headerStyle = ListLayoutConstants.tableHeaderStyle(theme);
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
              DataColumn(label: Text('Code', style: headerStyle)),
              DataColumn(label: Text('Name', style: headerStyle)),
              DataColumn(label: Text('UOM', style: headerStyle)),
              DataColumn(label: Text('Active', style: headerStyle)),
            ],
          rows: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final selected = selectedIds.contains(item.id);
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
                    onChanged: (v) => onSelectionChanged(item.id, v ?? false),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColCode),
                    child: Text(item.code),
                  ),
                  onTap: () => onRowTap(item),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColName),
                    child: Text(item.name),
                  ),
                  onTap: () => onRowTap(item),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColUom),
                    child: Text(item.uom),
                  ),
                  onTap: () => onRowTap(item),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: ListLayoutConstants.minColActive),
                    child: Text(item.isActive ? 'Yes' : 'No'),
                  ),
                  onTap: () => onRowTap(item),
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
