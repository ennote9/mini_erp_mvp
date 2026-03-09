import 'package:flutter/foundation.dart';

import 'customer.dart';

/// In-memory repository for Customers. No backend. Docs: 02_Domain_Model.md, 05_Validation_Rules.md
class CustomersRepository {
  CustomersRepository() {
    _seed();
  }

  final Map<String, Customer> _customers = {};
  int _nextId = 1;

  void _seed() {
    if (_customers.isNotEmpty) return;
    add(const Customer(
      id: '',
      code: 'CUS001',
      name: 'North Retail Corp',
      isActive: true,
      phone: '+1 555 300 3001',
      email: 'sales@northretail.example',
      comment: null,
    ));
    add(const Customer(
      id: '',
      code: 'CUS002',
      name: 'South Distribution LLC',
      isActive: true,
      phone: '+1 555 400 4002',
      email: 'orders@southdist.example',
      comment: 'B2B only.',
    ));
    add(const Customer(
      id: '',
      code: 'CUS003',
      name: 'East Coast Stores',
      isActive: false,
      phone: null,
      email: null,
      comment: 'Merged into North Retail.',
    ));
  }

  /// Notifies when add or update changes data. List listens to refresh.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Customer> getAll() =>
      _customers.values.toList()..sort((a, b) => a.code.compareTo(b.code));

  Customer? getById(String id) => _customers[id];

  /// Returns customers matching search (code or name, case-insensitive) and active filter.
  List<Customer> search({String query = '', bool? activeOnly}) {
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

  /// Returns true if another customer (excluding [excludeId]) has this code.
  bool isCodeTaken(String code, [String? excludeId]) {
    final c = code.trim();
    if (c.isEmpty) return false;
    return _customers.values.any(
      (e) =>
          e.id != excludeId && e.code.trim().toLowerCase() == c.toLowerCase(),
    );
  }

  /// Adds customer; assigns new id. Returns the created customer with id.
  Customer add(Customer customer) {
    final id = (_nextId++).toString();
    final created = customer.copyWith(id: id);
    _customers[id] = created;
    version.value++;
    return created;
  }

  void update(Customer customer) {
    if (_customers.containsKey(customer.id)) {
      _customers[customer.id] = customer;
      version.value++;
    }
  }
}

/// Single in-memory instance for the Customers module.
final customersRepository = CustomersRepository();
