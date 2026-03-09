import 'package:flutter/foundation.dart';

import 'warehouse.dart';

/// In-memory repository for Warehouses. No backend. Docs: 02_Domain_Model.md, 05_Validation_Rules.md
class WarehousesRepository {
  WarehousesRepository() {
    _seed();
  }

  final Map<String, Warehouse> _warehouses = {};
  int _nextId = 1;

  void _seed() {
    if (_warehouses.isNotEmpty) return;
    add(const Warehouse(
      id: '',
      code: 'WH01',
      name: 'Main Warehouse',
      isActive: true,
      comment: 'Primary storage and shipping.',
    ));
    add(const Warehouse(
      id: '',
      code: 'WH02',
      name: 'East Site',
      isActive: true,
      comment: null,
    ));
    add(const Warehouse(
      id: '',
      code: 'WH03',
      name: 'Old Depot',
      isActive: false,
      comment: 'Closed for renovation.',
    ));
  }

  /// Notifies when add or update changes data. List listens to refresh.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Warehouse> getAll() =>
      _warehouses.values.toList()..sort((a, b) => a.code.compareTo(b.code));

  Warehouse? getById(String id) => _warehouses[id];

  /// Returns warehouses matching search (code or name, case-insensitive) and active filter.
  List<Warehouse> search({String query = '', bool? activeOnly}) {
    var list = getAll();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        return e.code.toLowerCase().contains(q) ||
            e.name.toLowerCase().contains(q);
      }).toList();
    }
    if (activeOnly != null) {
      list = list.where((e) => e.isActive == activeOnly).toList();
    }
    return list;
  }

  /// Returns true if another warehouse (excluding [excludeId]) has this code.
  bool isCodeTaken(String code, [String? excludeId]) {
    final c = code.trim();
    if (c.isEmpty) return false;
    return _warehouses.values.any(
      (e) =>
          e.id != excludeId && e.code.trim().toLowerCase() == c.toLowerCase(),
    );
  }

  /// Adds warehouse; assigns new id. Returns the created warehouse with id.
  Warehouse add(Warehouse warehouse) {
    final id = (_nextId++).toString();
    final created = warehouse.copyWith(id: id);
    _warehouses[id] = created;
    version.value++;
    return created;
  }

  void update(Warehouse warehouse) {
    if (_warehouses.containsKey(warehouse.id)) {
      _warehouses[warehouse.id] = warehouse;
      version.value++;
    }
  }
}

/// Single in-memory instance for the Warehouses module.
final warehousesRepository = WarehousesRepository();
