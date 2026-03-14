import 'package:flutter/foundation.dart';

import '../../items/data/items_repository.dart';
import '../../sales_orders/data/sales_order.dart';
import '../../sales_orders/data/sales_orders_repository.dart';
import '../../stock_balances/data/stock_balances_repository.dart';
import '../../stock_movements/data/stock_movement.dart';
import '../../stock_movements/data/stock_movements_repository.dart';
import '../../warehouses/data/warehouses_repository.dart';
import 'shipment.dart';
import 'shipment_line.dart';

/// In-memory repository for Shipments. Created from Confirmed SO only.
/// Docs: 02_Domain_Model.md, 04_Document_Flows.md, 05_Validation_Rules.md
class ShipmentsRepository {
  ShipmentsRepository();

  final Map<String, Shipment> _shipments = {};
  final Map<String, ShipmentLine> _lines = {};
  int _nextShipmentId = 1;
  int _nextLineId = 1;
  int _nextNumber = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Shipment> getAll() => _shipments.values.toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  List<Shipment> search({String query = '', String? statusFilter}) {
    var list = getAll();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) => s.number.toLowerCase().contains(q)).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      list = list.where((s) => s.status == statusFilter).toList();
    }
    return list;
  }

  Shipment? getById(String id) => _shipments[id];

  List<ShipmentLine> getLines(String shipmentId) =>
      _lines.values.where((l) => l.shipmentId == shipmentId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  List<Shipment> getBySalesOrderId(String salesOrderId) =>
      _shipments.values.where((s) => s.salesOrderId == salesOrderId).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  bool hasDraftShipmentForSalesOrder(String soId) =>
      getBySalesOrderId(soId).any((s) => s.isDraft);

  bool hasPostedShipmentForSalesOrder(String soId) =>
      getBySalesOrderId(soId).any((s) => s.isPosted);

  /// True if SO is Confirmed and there is no Draft and no Posted shipment for it. Cancelled shipment(s) allow new one.
  bool canCreateShipmentForSalesOrder(String soId) {
    final so = salesOrdersRepository.getById(soId);
    if (so == null || !so.isConfirmed) return false;
    if (hasDraftShipmentForSalesOrder(soId)) return false;
    if (hasPostedShipmentForSalesOrder(soId)) return false;
    return true;
  }

  String _assignNumber() {
    final n = _nextNumber++;
    return 'SHP-${n.toString().padLeft(6, '0')}';
  }

  /// Create Draft Shipment from Confirmed SO. Number assigned immediately. Caller must ensure canCreateShipmentForSalesOrder(so.id).
  Shipment createFromSalesOrder(SalesOrder so) {
    final soLines = salesOrdersRepository.getLines(so.id);
    final shipmentId = (_nextShipmentId++).toString();
    final number = _assignNumber();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final shipment = Shipment(
      id: shipmentId,
      number: number,
      date: dateStr,
      salesOrderId: so.id,
      warehouseId: so.warehouseId,
      status: 'draft',
      comment: null,
    );
    _shipments[shipmentId] = shipment;
    for (final sl in soLines) {
      final lineId = (_nextLineId++).toString();
      _lines[lineId] = ShipmentLine(
        id: lineId,
        shipmentId: shipmentId,
        itemId: sl.itemId,
        qty: sl.qty,
      );
    }
    version.value++;
    return shipment;
  }

  void update(Shipment shipment) {
    if (_shipments.containsKey(shipment.id) && shipment.isDraft) {
      _shipments[shipment.id] = shipment;
      version.value++;
    }
  }

  void cancelDocument(String shipmentId) {
    final s = _shipments[shipmentId];
    if (s != null && s.isDraft) {
      _shipments[shipmentId] = s.copyWith(status: 'cancelled');
      version.value++;
    }
  }

  bool _isItemActive(String itemId) {
    final i = itemsRepository.getById(itemId);
    return i != null && i.isActive;
  }

  bool _isWarehouseActive(String warehouseId) {
    final w = warehousesRepository.getById(warehouseId);
    return w != null && w.isActive;
  }

  /// Returns validation error for Save Draft (date, header only; lines are read-only).
  String? validateDraft({
    required String date,
    required String salesOrderId,
    required String warehouseId,
    required List<ShipmentLine> lines,
  }) {
    if (date.trim().isEmpty) return 'Date is required';
    final parsed = DateTime.tryParse(date.trim());
    if (parsed == null || parsed.year < 1900 || parsed.year > 2100) {
      return 'Date must be a valid date';
    }
    if (salesOrderId.trim().isEmpty) return 'Sales order is required';
    if (salesOrdersRepository.getById(salesOrderId) == null) {
      return 'Sales order not found';
    }
    if (warehouseId.trim().isEmpty) return 'Warehouse is required';
    if (!_isWarehouseActive(warehouseId)) return 'Warehouse must be active';
    if (lines.isEmpty) return 'At least one line is required';
    return null;
  }

  /// Returns validation error for Post, or null if valid. Atomic: if any line has insufficient stock, returns one simple message; no partial post.
  String? validatePost(String shipmentId) {
    final s = _shipments[shipmentId];
    if (s == null) return 'Shipment not found';
    if (!s.isDraft) return 'Only draft shipments can be posted';
    final so = salesOrdersRepository.getById(s.salesOrderId);
    if (so == null || !so.isConfirmed) {
      return 'Sales order must be confirmed to post this shipment';
    }
    if (hasPostedShipmentForSalesOrder(s.salesOrderId)) {
      return 'A shipment for this sales order has already been posted';
    }
    final lines = getLines(shipmentId);
    if (lines.isEmpty) return 'At least one line is required';
    for (final line in lines) {
      if (line.itemId.trim().isEmpty) return 'Each line must have an Item';
      if (line.qty <= 0) return 'Quantity must be greater than zero';
      if (!_isItemActive(line.itemId)) return 'All items must be active';
    }
    if (!_isWarehouseActive(s.warehouseId)) return 'Warehouse must be active';

    // Atomic stock check: if any line has insufficient stock, fail with one simple message
    for (final line in lines) {
      final balance = stockBalancesRepository.getByItemAndWarehouse(line.itemId, s.warehouseId);
      final qtyOnHand = balance?.qtyOnHand ?? 0;
      if (qtyOnHand < line.qty) {
        return 'Not enough stock to ship. One or more items have insufficient quantity on hand.';
      }
    }
    return null;
  }

  /// Post shipment: create movements, update balances, set Posted, close SO. Only call when validatePost returns null.
  void post(String shipmentId) {
    final err = validatePost(shipmentId);
    if (err != null) return;
    final s = _shipments[shipmentId]!;
    final lines = getLines(shipmentId);
    final now = DateTime.now();
    final createdAt = '${now.toIso8601String().substring(0, 19)}Z';
    for (final line in lines) {
      stockMovementsRepository.add(StockMovement(
        id: '',
        itemId: line.itemId,
        warehouseId: s.warehouseId,
        qtyDelta: -line.qty,
        movementType: 'shipment',
        sourceDocumentType: 'shipment',
        sourceDocumentId: shipmentId,
        createdAt: createdAt,
        comment: null,
      ));
      stockBalancesRepository.subtractQty(line.itemId, s.warehouseId, line.qty);
    }
    _shipments[shipmentId] = s.copyWith(status: 'posted');
    salesOrdersRepository.close(s.salesOrderId);
    version.value++;
  }
}

/// Single in-memory instance.
final shipmentsRepository = ShipmentsRepository();
