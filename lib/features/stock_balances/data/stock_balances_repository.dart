import 'package:flutter/foundation.dart';

import 'stock_balance.dart';

/// In-memory repository for Stock Balances. Updated by Posted Receipt/Shipment.
/// Docs: 02_Domain_Model.md
class StockBalancesRepository {
  StockBalancesRepository();

  final Map<String, StockBalance> _balances = {};
  int _nextId = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<StockBalance> getAll() => _balances.values.toList()
    ..sort((a, b) {
      final c = a.itemId.compareTo(b.itemId);
      return c != 0 ? c : a.warehouseId.compareTo(b.warehouseId);
    });

  /// Returns balances optionally filtered by warehouse. No cross-repo dependency; list page resolves item/warehouse for display and search.
  List<StockBalance> search({String? warehouseId}) {
    var list = getAll();
    if (warehouseId != null && warehouseId.isNotEmpty) {
      list = list.where((b) => b.warehouseId == warehouseId).toList();
    }
    return list;
  }

  StockBalance? getById(String id) => _balances[id];

  StockBalance? getByItemAndWarehouse(String itemId, String warehouseId) {
    for (final b in _balances.values) {
      if (b.itemId == itemId && b.warehouseId == warehouseId) return b;
    }
    return null;
  }

  /// Increase or create balance for (itemId, warehouseId) by [delta]. Used on Receipt Post.
  void addQty(String itemId, String warehouseId, int delta) {
    if (delta <= 0) return;
    final existing = getByItemAndWarehouse(itemId, warehouseId);
    if (existing != null) {
      _balances[existing.id] =
          existing.copyWith(qtyOnHand: existing.qtyOnHand + delta);
    } else {
      final id = (_nextId++).toString();
      _balances[id] = StockBalance(
        id: id,
        itemId: itemId,
        warehouseId: warehouseId,
        qtyOnHand: delta,
      );
    }
    version.value++;
  }

  /// Decrease balance for (itemId, warehouseId) by [delta]. Used on Shipment Post.
  void subtractQty(String itemId, String warehouseId, int delta) {
    if (delta <= 0) return;
    final existing = getByItemAndWarehouse(itemId, warehouseId);
    if (existing != null) {
      final newQty = existing.qtyOnHand - delta;
      _balances[existing.id] = existing.copyWith(qtyOnHand: newQty.clamp(0, 0x7fffffff));
    }
    version.value++;
  }
}

final stockBalancesRepository = StockBalancesRepository();
