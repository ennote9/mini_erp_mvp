/// Sales Order Line entity. Docs: 02_Domain_Model.md
class SalesOrderLine {
  const SalesOrderLine({
    required this.id,
    required this.salesOrderId,
    required this.itemId,
    required this.qty,
  });

  final String id;
  final String salesOrderId;
  final String itemId;
  final int qty;

  SalesOrderLine copyWith({
    String? id,
    String? salesOrderId,
    String? itemId,
    int? qty,
  }) {
    return SalesOrderLine(
      id: id ?? this.id,
      salesOrderId: salesOrderId ?? this.salesOrderId,
      itemId: itemId ?? this.itemId,
      qty: qty ?? this.qty,
    );
  }
}
