import 'package:flutter/foundation.dart';

import '../../items/data/items_repository.dart';
import '../../purchase_orders/data/purchase_order.dart';
import '../../purchase_orders/data/purchase_orders_repository.dart';
import '../../stock_balances/data/stock_balances_repository.dart';
import '../../stock_movements/data/stock_movement.dart';
import '../../stock_movements/data/stock_movements_repository.dart';
import '../../warehouses/data/warehouses_repository.dart';
import 'receipt.dart';
import 'receipt_line.dart';

/// In-memory repository for Receipts. Created from Confirmed PO only.
/// Docs: 02_Domain_Model.md, 04_Document_Flows.md, 05_Validation_Rules.md
class ReceiptsRepository {
  ReceiptsRepository();

  final Map<String, Receipt> _receipts = {};
  final Map<String, ReceiptLine> _lines = {};
  int _nextReceiptId = 1;
  int _nextLineId = 1;
  int _nextNumber = 1;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  List<Receipt> getAll() => _receipts.values.toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  List<Receipt> search({String query = '', String? statusFilter}) {
    var list = getAll();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) => r.number.toLowerCase().contains(q)).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      list = list.where((r) => r.status == statusFilter).toList();
    }
    return list;
  }

  Receipt? getById(String id) => _receipts[id];

  List<ReceiptLine> getLines(String receiptId) =>
      _lines.values.where((l) => l.receiptId == receiptId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  List<Receipt> getByPurchaseOrderId(String purchaseOrderId) =>
      _receipts.values.where((r) => r.purchaseOrderId == purchaseOrderId).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  bool hasDraftReceiptForPurchaseOrder(String poId) =>
      getByPurchaseOrderId(poId).any((r) => r.isDraft);

  bool hasPostedReceiptForPurchaseOrder(String poId) =>
      getByPurchaseOrderId(poId).any((r) => r.isPosted);

  /// True if PO is Confirmed and there is no Draft and no Posted receipt for it. Cancelled receipt allows new one.
  bool canCreateReceiptForPurchaseOrder(String poId) {
    final po = purchaseOrdersRepository.getById(poId);
    if (po == null || !po.isConfirmed) return false;
    if (hasDraftReceiptForPurchaseOrder(poId)) return false;
    if (hasPostedReceiptForPurchaseOrder(poId)) return false;
    return true;
  }

  String _assignNumber() {
    final n = _nextNumber++;
    return 'RCPT-${n.toString().padLeft(6, '0')}';
  }

  /// Create Draft Receipt from Confirmed PO. Number assigned immediately. Caller must ensure canCreateReceiptForPurchaseOrder(po.id).
  Receipt createFromPurchaseOrder(PurchaseOrder po) {
    final poLines = purchaseOrdersRepository.getLines(po.id);
    final receiptId = (_nextReceiptId++).toString();
    final number = _assignNumber();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final receipt = Receipt(
      id: receiptId,
      number: number,
      date: dateStr,
      purchaseOrderId: po.id,
      warehouseId: po.warehouseId,
      status: 'draft',
      comment: null,
    );
    _receipts[receiptId] = receipt;
    for (final pl in poLines) {
      final lineId = (_nextLineId++).toString();
      _lines[lineId] = ReceiptLine(
        id: lineId,
        receiptId: receiptId,
        itemId: pl.itemId,
        qty: pl.qty,
      );
    }
    version.value++;
    return receipt;
  }

  void update(Receipt receipt) {
    if (_receipts.containsKey(receipt.id) && receipt.isDraft) {
      _receipts[receipt.id] = receipt;
      version.value++;
    }
  }

  void cancelDocument(String receiptId) {
    final r = _receipts[receiptId];
    if (r != null && r.isDraft) {
      _receipts[receiptId] = r.copyWith(status: 'cancelled');
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

  /// Returns validation error for Save Draft (date, header, lines).
  String? validateDraft({
    required String date,
    required String purchaseOrderId,
    required String warehouseId,
    required List<ReceiptLine> lines,
  }) {
    if (date.trim().isEmpty) return 'Date is required';
    final parsed = DateTime.tryParse(date.trim());
    if (parsed == null || parsed.year < 1900 || parsed.year > 2100) {
      return 'Date must be a valid date';
    }
    if (purchaseOrderId.trim().isEmpty) return 'Purchase order is required';
    if (purchaseOrdersRepository.getById(purchaseOrderId) == null) {
      return 'Purchase order not found';
    }
    if (warehouseId.trim().isEmpty) return 'Warehouse is required';
    if (!_isWarehouseActive(warehouseId)) return 'Warehouse must be active';
    if (lines.isEmpty) return 'At least one line is required';
    for (final line in lines) {
      if (line.itemId.trim().isEmpty) return 'Each line must have an Item';
      if (line.qty <= 0) return 'Quantity must be greater than zero';
      if (!_isItemActive(line.itemId)) return 'All items must be active';
    }
    return null;
  }

  /// Returns validation error for Post, or null if valid.
  String? validatePost(String receiptId) {
    final r = _receipts[receiptId];
    if (r == null) return 'Receipt not found';
    if (!r.isDraft) return 'Only draft receipts can be posted';
    final po = purchaseOrdersRepository.getById(r.purchaseOrderId);
    if (po == null || !po.isConfirmed) {
      return 'Purchase order must be confirmed to post this receipt';
    }
    if (hasPostedReceiptForPurchaseOrder(r.purchaseOrderId)) {
      return 'A receipt for this purchase order has already been posted';
    }
    final lines = getLines(receiptId);
    if (lines.isEmpty) return 'At least one line is required';
    for (final line in lines) {
      if (line.itemId.trim().isEmpty) return 'Each line must have an Item';
      if (line.qty <= 0) return 'Quantity must be greater than zero';
      if (!_isItemActive(line.itemId)) return 'All items must be active';
    }
    if (!_isWarehouseActive(r.warehouseId)) return 'Warehouse must be active';
    return null;
  }

  /// Post receipt: create movements, update balances, set Posted, close PO.
  void post(String receiptId) {
    final err = validatePost(receiptId);
    if (err != null) return;
    final r = _receipts[receiptId]!;
    final lines = getLines(receiptId);
    final now = DateTime.now();
    final createdAt =
        '${now.toIso8601String().substring(0, 19)}Z';
    for (final line in lines) {
      stockMovementsRepository.add(StockMovement(
        id: '',
        itemId: line.itemId,
        warehouseId: r.warehouseId,
        qtyDelta: line.qty,
        movementType: 'receipt',
        sourceDocumentType: 'receipt',
        sourceDocumentId: receiptId,
        createdAt: createdAt,
        comment: null,
      ));
      stockBalancesRepository.addQty(line.itemId, r.warehouseId, line.qty);
    }
    _receipts[receiptId] = r.copyWith(status: 'posted');
    purchaseOrdersRepository.close(r.purchaseOrderId);
    version.value++;
  }
}

/// Single in-memory instance.
final receiptsRepository = ReceiptsRepository();
