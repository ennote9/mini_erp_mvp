import 'package:flutter/foundation.dart';

import 'stock_movement.dart';

/// In-memory repository for Stock Movements. Created by Posted Receipt/Shipment.
/// Docs: 02_Domain_Model.md
class StockMovementsRepository {
  StockMovementsRepository();

  final Map<String, StockMovement> _movements = {};
  int _nextId = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<StockMovement> getAll() => _movements.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Returns movements optionally filtered by movement type. No cross-repo dependency; list page resolves item/warehouse/source doc for display and search.
  List<StockMovement> search({String? movementType}) {
    var list = getAll();
    if (movementType != null && movementType.isNotEmpty) {
      list = list.where((m) => m.movementType == movementType).toList();
    }
    return list;
  }

  StockMovement? getById(String id) => _movements[id];

  void add(StockMovement movement) {
    final id = (_nextId++).toString();
    _movements[id] = movement.copyWith(id: id);
    version.value++;
  }
}

final stockMovementsRepository = StockMovementsRepository();
