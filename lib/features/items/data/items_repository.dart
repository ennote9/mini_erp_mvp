import 'package:flutter/foundation.dart';

import 'item.dart';

/// In-memory repository for Items. No backend. Docs: 02_Domain_Model.md, 05_Validation_Rules.md
class ItemsRepository {
  ItemsRepository() {
    _seed();
  }

  final Map<String, Item> _items = {};
  int _nextId = 1;

  void _seed() {
    const seeds = [
      _SeedItem('ITM-001', 'Shampoo Classic 250ml', 'PCS', true, 'Core assortment item'),
      _SeedItem('ITM-002', 'Conditioner Repair 250ml', 'PCS', true, 'Hair care line'),
      _SeedItem('ITM-003', 'Body Wash Citrus 500ml', 'PCS', true, 'Daily care product'),
      _SeedItem('ITM-004', 'Face Cream Hydration Night', 'PCS', true, 'Premium skincare item'),
      _SeedItem('ITM-005', 'Cotton Pads 120 pcs', 'PACK', true, 'Consumable item'),
      _SeedItem('ITM-006', 'Lip Balm Berry Soft', 'PCS', false, 'Temporarily inactive item'),
      _SeedItem('ITM-007', 'Hand Cream Almond 75ml', 'PCS', true, 'Seasonal assortment'),
      _SeedItem('ITM-008', 'Perfume Test Long Name Collection Edition No 8', 'PCS', true, 'Long name for table width testing'),
      _SeedItem('ITM-009', 'Nail Polish Deep Red', 'PCS', false, 'Inactive for filter testing'),
      _SeedItem('ITM-010', 'Soap Lavender', 'PCS', true, 'Short simple item'),
      _SeedItem('ITM-011', 'Hair Mask Intensive Recovery Professional Series', 'PCS', true, 'Long product name for overflow testing'),
      _SeedItem('ITM-012', 'Wet Wipes Kids Sensitive 64 pcs', 'PACK', true, 'Family care product'),
      _SeedItem('ITM-013', 'Toothpaste Fresh Mint 100ml', 'PCS', false, 'Inactive SKU'),
      _SeedItem('ITM-014', 'Sunscreen SPF50 Ultra Light Fluid', 'PCS', true, 'Summer assortment'),
      _SeedItem('ITM-015', 'Makeup Remover Micellar Water Extra Gentle 400ml', 'PCS', true, 'Medium-length code and long name test'),
      _SeedItem('00000000012345', 'Крем для рук питательный', 'PCS', true, 'Cyrillic name test'),
      _SeedItem('A1', 'Масло для волос', 'PCS', false, 'Very short code test'),
      _SeedItem('SKU-SUPER-LONG-2026-ALPHA-001', 'Serum Professional Repair Formula', 'PCS', true, 'Long code test'),
    ];
    for (var i = 0; i < seeds.length; i++) {
      final s = seeds[i];
      final id = (i + 1).toString();
      _items[id] = Item(
        id: id,
        code: s.code,
        name: s.name,
        uom: s.uom,
        isActive: s.isActive,
        description: s.description,
      );
    }
    _nextId = seeds.length + 1;
  }

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

class _SeedItem {
  const _SeedItem(
    this.code,
    this.name,
    this.uom,
    this.isActive,
    this.description,
  );
  final String code;
  final String name;
  final String uom;
  final bool isActive;
  final String description;
}
