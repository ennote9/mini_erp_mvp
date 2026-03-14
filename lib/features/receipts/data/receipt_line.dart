/// Receipt Line entity. Docs: 02_Domain_Model.md. UOM resolved from Item when displaying.
class ReceiptLine {
  const ReceiptLine({
    required this.id,
    required this.receiptId,
    required this.itemId,
    required this.qty,
  });

  final String id;
  final String receiptId;
  final String itemId;
  final int qty;

  ReceiptLine copyWith({
    String? id,
    String? receiptId,
    String? itemId,
    int? qty,
  }) {
    return ReceiptLine(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      itemId: itemId ?? this.itemId,
      qty: qty ?? this.qty,
    );
  }
}
