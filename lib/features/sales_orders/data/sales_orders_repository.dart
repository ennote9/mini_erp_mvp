import 'package:flutter/foundation.dart';

import '../../customers/data/customers_repository.dart';
import '../../items/data/items_repository.dart';
import '../../warehouses/data/warehouses_repository.dart';
import 'sales_order.dart';
import 'sales_order_line.dart';

/// In-memory repository for Sales Orders. No backend.
/// Docs: 02_Domain_Model.md, 04_Document_Flows.md, 05_Validation_Rules.md
class SalesOrdersRepository {
  SalesOrdersRepository();

  final Map<String, SalesOrder> _orders = {};
  final Map<String, SalesOrderLine> _lines = {};
  int _nextOrderId = 1;
  int _nextLineId = 1;
  int _nextNumber = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<SalesOrder> getAll() => _orders.values.toList()
    ..sort((a, b) => (a.number.isEmpty ? 'zzz' : a.number).compareTo(b.number.isEmpty ? 'zzz' : b.number));

  SalesOrder? getById(String id) => _orders[id];

  List<SalesOrderLine> getLines(String salesOrderId) =>
      _lines.values.where((l) => l.salesOrderId == salesOrderId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  List<SalesOrder> search({String query = '', String? statusFilter}) {
    var list = getAll();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((o) => o.number.toLowerCase().contains(q)).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      list = list.where((o) => o.status == statusFilter).toList();
    }
    return list;
  }

  /// Assigns next number SO-000001, SO-000002, ...
  String _assignNumber() {
    final num = _nextNumber++;
    return 'SO-${num.toString().padLeft(6, '0')}';
  }

  SalesOrder add(SalesOrder order) {
    final id = (_nextOrderId++).toString();
    final number = order.number.isEmpty ? _assignNumber() : order.number;
    final created = order.copyWith(id: id, number: number, status: 'draft');
    _orders[id] = created;
    version.value++;
    return created;
  }

  void update(SalesOrder order) {
    if (_orders.containsKey(order.id) && order.isDraft) {
      _orders[order.id] = order;
      version.value++;
    }
  }

  void addLine(SalesOrderLine line) {
    final id = (_nextLineId++).toString();
    _lines[id] = line.copyWith(id: id);
    version.value++;
  }

  void updateLine(SalesOrderLine line) {
    if (_lines.containsKey(line.id)) {
      _lines[line.id] = line;
      version.value++;
    }
  }

  void removeLine(String lineId) {
    _lines.remove(lineId);
    version.value++;
  }

  void removeLinesByOrder(String salesOrderId) {
    _lines.removeWhere((_, l) => l.salesOrderId == salesOrderId);
    version.value++;
  }

  void confirm(String orderId) {
    final o = _orders[orderId];
    if (o != null && o.isDraft) {
      _orders[orderId] = o.copyWith(status: 'confirmed');
      version.value++;
    }
  }

  void cancelDocument(String orderId) {
    final o = _orders[orderId];
    if (o != null && (o.isDraft || o.isConfirmed)) {
      _orders[orderId] = o.copyWith(status: 'cancelled');
      version.value++;
    }
  }

  /// Set Sales Order to Closed (e.g. after Shipment is Posted). Called by ShipmentsRepository.
  void close(String orderId) {
    final o = _orders[orderId];
    if (o != null && o.isConfirmed) {
      _orders[orderId] = o.copyWith(status: 'closed');
      version.value++;
    }
  }

  bool _isCustomerActive(String customerId) {
    final c = customersRepository.getById(customerId);
    return c != null && c.isActive;
  }

  bool _isWarehouseActive(String warehouseId) {
    final w = warehousesRepository.getById(warehouseId);
    return w != null && w.isActive;
  }

  bool _isItemActive(String itemId) {
    final i = itemsRepository.getById(itemId);
    return i != null && i.isActive;
  }

  /// Returns validation error message or null if valid for Save Draft.
  String? validateDraft({
    required String date,
    required String customerId,
    required String warehouseId,
    required List<SalesOrderLine> lines,
  }) {
    if (date.trim().isEmpty) return 'Date is required';
    final parsed = DateTime.tryParse(date.trim());
    if (parsed == null || parsed.year < 1900 || parsed.year > 2100) {
      return 'Date must be a valid date';
    }
    if (customerId.trim().isEmpty) return 'Customer is required';
    if (warehouseId.trim().isEmpty) return 'Warehouse is required';
    if (!_isCustomerActive(customerId)) return 'Customer must be active';
    if (!_isWarehouseActive(warehouseId)) return 'Warehouse must be active';
    if (lines.isEmpty) return 'At least one line is required';
    final itemIds = <String>{};
    for (final line in lines) {
      if (line.itemId.trim().isEmpty) return 'Each line must have an Item';
      if (line.qty <= 0) return 'Quantity must be greater than zero';
      if (!_isItemActive(line.itemId)) return 'All items must be active';
      if (!itemIds.add(line.itemId)) return 'Duplicate items are not allowed';
    }
    return null;
  }
}

/// Single in-memory instance.
final salesOrdersRepository = SalesOrdersRepository();
