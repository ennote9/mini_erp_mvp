import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../shared/app_page_header.dart';
import '../../shared/app_placeholder_state.dart';
import 'data/supplier.dart';
import 'data/suppliers_repository.dart';

/// Suppliers list page. Real grid, search, filter, row click, New. Docs: 08_Screens_v1, 11_List_Page_Pattern_v1, 19_Data_Grid_Column_Definitions_v1, 20_Grid_Interaction_Rules_v1.
class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  final SuppliersRepository _repo = suppliersRepository;
  final TextEditingController _searchController = TextEditingController();

  List<Supplier> _suppliers = [];
  bool _loading = true;
  String _searchQuery = '';
  bool? _activeFilter; // null = All, true = Active, false = Inactive
  final Set<String> _selectedIds = {};

  void _applySearchAndFilter() {
    setState(() {
      _searchQuery = _searchController.text;
      _suppliers = _repo.search(query: _searchQuery, activeOnly: _activeFilter);
    });
  }

  void _refreshFromRepo() {
    if (!mounted) return;
    setState(() {
      _suppliers =
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
        _suppliers =
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

  List<Supplier> get _filteredSuppliers => _suppliers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: 'Suppliers',
          actions: [
            FilledButton.icon(
              onPressed: () =>
                  context.go('/${AppRoutes.pathSuppliers}/${AppRoutes.pathNew}'),
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
            _suppliers = _repo.search(query: _searchQuery, activeOnly: v);
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
    if (_filteredSuppliers.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _activeFilter != null;
      return AppPlaceholderState(
        message: isFiltered
            ? 'No suppliers match current search'
            : 'No suppliers yet\nCreate your first supplier to start purchasing workflow',
        icon: isFiltered ? Icons.search_off : Icons.business_outlined,
      );
    }
    return _SuppliersGrid(
      suppliers: _filteredSuppliers,
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
            for (final e in _filteredSuppliers) {
              _selectedIds.add(e.id);
            }
          } else {
            _selectedIds.clear();
          }
        });
      },
      onRowTap: (s) => context.go('/${AppRoutes.pathSuppliers}/${s.id}'),
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

class _SuppliersGrid extends StatelessWidget {
  const _SuppliersGrid({
    required this.suppliers,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onRowTap,
  });

  final List<Supplier> suppliers;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectAll;
  final void Function(Supplier supplier) onRowTap;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        suppliers.isNotEmpty && selectedIds.length == suppliers.length;
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
            const DataColumn(label: Text('Phone')),
            const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('Active')),
          ],
          rows: suppliers.map((s) {
            final selected = selectedIds.contains(s.id);
            return DataRow(
              selected: selected,
              cells: [
                DataCell(
                  Checkbox(
                    value: selected,
                    onChanged: (v) => onSelectionChanged(s.id, v ?? false),
                  ),
                ),
                DataCell(Text(s.code), onTap: () => onRowTap(s)),
                DataCell(Text(s.name), onTap: () => onRowTap(s)),
                DataCell(Text(s.phone ?? ''), onTap: () => onRowTap(s)),
                DataCell(Text(s.email ?? ''), onTap: () => onRowTap(s)),
                DataCell(
                  Text(s.isActive ? 'Yes' : 'No'),
                  onTap: () => onRowTap(s),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
