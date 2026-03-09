/// Purchase Order Line entity. Docs: 02_Domain_Model.md
class PurchaseOrderLine {
  const PurchaseOrderLine({
    required this.id,
    required this.purchaseOrderId,
    required this.itemId,
    required this.qty,
  });

  final String id;
  final String purchaseOrderId;
  final String itemId;
  final int qty;

  PurchaseOrderLine copyWith({
    String? id,
    String? purchaseOrderId,
    String? itemId,
    int? qty,
  }) {
    return PurchaseOrderLine(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      itemId: itemId ?? this.itemId,
      qty: qty ?? this.qty,
    );
  }
}
