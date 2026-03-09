import 'package:flutter/foundation.dart';

import 'supplier.dart';

/// In-memory repository for Suppliers. No backend. Docs: 02_Domain_Model.md, 05_Validation_Rules.md
class SuppliersRepository {
  SuppliersRepository() {
    _seed();
  }

  final Map<String, Supplier> _suppliers = {};
  int _nextId = 1;

  void _seed() {
    if (_suppliers.isNotEmpty) return;
    add(const Supplier(
      id: '',
      code: 'SUP001',
      name: 'Acme Supplies Ltd',
      isActive: true,
      phone: '+1 555 100 1001',
      email: 'orders@acmesupplies.example',
      comment: null,
    ));
    add(const Supplier(
      id: '',
      code: 'SUP002',
      name: 'Global Parts Inc',
      isActive: true,
      phone: '+1 555 200 2002',
      email: 'contact@globalparts.example',
      comment: 'Preferred vendor for fasteners.',
    ));
    add(const Supplier(
      id: '',
      code: 'SUP003',
      name: 'Legacy Wholesale Co',
      isActive: false,
      phone: null,
      email: null,
      comment: 'Inactive since 2024.',
    ));
  }

  /// Notifies when add or update changes data. List listens to refresh.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Supplier> getAll() =>
      _suppliers.values.toList()..sort((a, b) => a.code.compareTo(b.code));

  Supplier? getById(String id) => _suppliers[id];

  /// Returns suppliers matching search (code or name, case-insensitive) and active filter.
  List<Supplier> search({String query = '', bool? activeOnly}) {
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

  /// Returns true if another supplier (excluding [excludeId]) has this code.
  bool isCodeTaken(String code, [String? excludeId]) {
    final c = code.trim();
    if (c.isEmpty) return false;
    return _suppliers.values.any(
      (e) =>
          e.id != excludeId && e.code.trim().toLowerCase() == c.toLowerCase(),
    );
  }

  /// Adds supplier; assigns new id. Returns the created supplier with id.
  Supplier add(Supplier supplier) {
    final id = (_nextId++).toString();
    final created = supplier.copyWith(id: id);
    _suppliers[id] = created;
    version.value++;
    return created;
  }

  void update(Supplier supplier) {
    if (_suppliers.containsKey(supplier.id)) {
      _suppliers[supplier.id] = supplier;
      version.value++;
    }
  }
}

/// Single in-memory instance for the Suppliers module.
final suppliersRepository = SuppliersRepository();
