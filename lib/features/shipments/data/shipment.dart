/// Shipment document entity. Docs: 02_Domain_Model.md, 03_Statuses_and_Rules.md
class Shipment {
  const Shipment({
    required this.id,
    required this.number,
    required this.date,
    required this.salesOrderId,
    required this.warehouseId,
    required this.status,
    this.comment,
  });

  final String id;
  /// Business number (e.g. SHP-000001). Assigned at creation.
  final String number;
  final String date;
  final String salesOrderId;
  final String warehouseId;
  /// draft | posted | cancelled
  final String status;
  final String? comment;

  bool get isDraft => status == 'draft';
  bool get isPosted => status == 'posted';
  bool get isCancelled => status == 'cancelled';

  Shipment copyWith({
    String? id,
    String? number,
    String? date,
    String? salesOrderId,
    String? warehouseId,
    String? status,
    String? comment,
  }) {
    return Shipment(
      id: id ?? this.id,
      number: number ?? this.number,
      date: date ?? this.date,
      salesOrderId: salesOrderId ?? this.salesOrderId,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}
