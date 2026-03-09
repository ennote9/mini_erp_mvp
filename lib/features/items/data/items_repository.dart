import 'package:flutter/foundation.dart';

import 'item.dart';

/// In-memory repository for Items. No backend. Docs: 02_Domain_Model.md, 05_Validation_Rules.md
class ItemsRepository {
  ItemsRepository();

  final Map<String, Item> _items = {};
  int _nextId = 1;

  /// Notifies when add or update changes data. Items list listens to refresh.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Item> getAll() =>
      _items.values.toList()..sort((a, b) => a.code.compareTo(b.code));

  Item? getById(String id) => _items[id];

  /// Returns items matching search (code or name, case-insensitive) and active filter.
  List<Item> search({String query = '', bool? activeOnly}) {
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

  /// Returns true if another item (excluding [excludeId]) has this code.
  bool isCodeTaken(String code, [String? excludeId]) {
    final c = code.trim();
    if (c.isEmpty) return false;
    return _items.values.any(
      (e) =>
          e.id != excludeId && e.code.trim().toLowerCase() == c.toLowerCase(),
    );
  }

  /// Adds item; assigns new id. Returns the created item with id.
  Item add(Item item) {
    final id = (_nextId++).toString();
    final created = item.copyWith(id: id);
    _items[id] = created;
    version.value++;
    return created;
  }

  void update(Item item) {
    if (_items.containsKey(item.id)) {
      _items[item.id] = item;
      version.value++;
    }
  }
}

/// Single in-memory instance for the Items module. No dependency injection in Phase 1.
final itemsRepository = ItemsRepository();
