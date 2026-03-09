import 'package:flutter/foundation.dart';

import '../../items/data/items_repository.dart';
import '../../suppliers/data/suppliers_repository.dart';
import '../../warehouses/data/warehouses_repository.dart';
import 'purchase_order.dart';
import 'purchase_order_line.dart';

/// In-memory repository for Purchase Orders. No backend.
/// Docs: 02_Domain_Model.md, 04_Document_Flows.md, 05_Validation_Rules.md
class PurchaseOrdersRepository {
  PurchaseOrdersRepository();

  final Map<String, PurchaseOrder> _orders = {};
  final Map<String, PurchaseOrderLine> _lines = {};
  int _nextOrderId = 1;
  int _nextLineId = 1;
  int _nextNumber = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<PurchaseOrder> getAll() => _orders.values.toList()
    ..sort((a, b) => (a.number.isEmpty ? 'zzz' : a.number).compareTo(b.number.isEmpty ? 'zzz' : b.number));

  PurchaseOrder? getById(String id) => _orders[id];

  List<PurchaseOrderLine> getLines(String purchaseOrderId) =>
      _lines.values.where((l) => l.purchaseOrderId == purchaseOrderId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  List<PurchaseOrder> search({String query = '', String? statusFilter}) {
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

  /// Assigns next number PO-000001, PO-000002, ...
  String _assignNumber() {
    final num = _nextNumber++;
    return 'PO-${num.toString().padLeft(6, '0')}';
  }

  PurchaseOrder add(PurchaseOrder order) {
    final id = (_nextOrderId++).toString();
    final number = order.number.isEmpty ? _assignNumber() : order.number;
    final created = order.copyWith(id: id, number: number, status: 'draft');
    _orders[id] = created;
    version.value++;
    return created;
  }

  void update(PurchaseOrder order) {
    if (_orders.containsKey(order.id) && order.isDraft) {
      _orders[order.id] = order;
      version.value++;
    }
  }

  void addLine(PurchaseOrderLine line) {
    final id = (_nextLineId++).toString();
    _lines[id] = line.copyWith(id: id);
    version.value++;
  }

  void updateLine(PurchaseOrderLine line) {
    if (_lines.containsKey(line.id)) {
      _lines[line.id] = line;
      version.value++;
    }
  }

  void removeLine(String lineId) {
    _lines.remove(lineId);
    version.value++;
  }

  void removeLinesByOrder(String purchaseOrderId) {
    _lines.removeWhere((_, l) => l.purchaseOrderId == purchaseOrderId);
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

  bool _isSupplierActive(String supplierId) {
    final s = suppliersRepository.getById(supplierId);
    return s != null && s.isActive;
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
    required String supplierId,
    required String warehouseId,
    required List<PurchaseOrderLine> lines,
    String? excludeOrderId,
  }) {
    if (date.trim().isEmpty) return 'Date is required';
    if (supplierId.trim().isEmpty) return 'Supplier is required';
    if (warehouseId.trim().isEmpty) return 'Warehouse is required';
    if (!_isSupplierActive(supplierId)) return 'Supplier must be active';
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

  /// Can show Create Receipt (placeholder). In MVP without Receipts, always false.
  bool canCreateReceipt(String orderId) => false;
}

/// Single in-memory instance.
final purchaseOrdersRepository = PurchaseOrdersRepository();
