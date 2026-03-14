/// Receipt document entity. Docs: 02_Domain_Model.md, 03_Statuses_and_Rules.md
class Receipt {
  const Receipt({
    required this.id,
    required this.number,
    required this.date,
    required this.purchaseOrderId,
    required this.warehouseId,
    required this.status,
    this.comment,
  });

  final String id;
  /// Business number (e.g. RCPT-000001). Assigned at creation.
  final String number;
  final String date;
  final String purchaseOrderId;
  final String warehouseId;
  /// draft | posted | cancelled
  final String status;
  final String? comment;

  bool get isDraft => status == 'draft';
  bool get isPosted => status == 'posted';
  bool get isCancelled => status == 'cancelled';

  Receipt copyWith({
    String? id,
    String? number,
    String? date,
    String? purchaseOrderId,
    String? warehouseId,
    String? status,
    String? comment,
  }) {
    return Receipt(
      id: id ?? this.id,
      number: number ?? this.number,
      date: date ?? this.date,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}
