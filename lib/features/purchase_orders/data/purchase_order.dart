/// Purchase Order document entity. Docs: 02_Domain_Model.md, 03_Statuses_and_Rules.md
class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.number,
    required this.date,
    required this.supplierId,
    required this.warehouseId,
    required this.status,
    this.comment,
  });

  final String id;
  /// Business number (e.g. PO-000001). Empty until assigned on first save.
  final String number;
  final String date;
  final String supplierId;
  final String warehouseId;
  /// draft | confirmed | closed | cancelled
  final String status;
  final String? comment;

  bool get isDraft => status == 'draft';
  bool get isConfirmed => status == 'confirmed';
  bool get isClosed => status == 'closed';
  bool get isCancelled => status == 'cancelled';

  PurchaseOrder copyWith({
    String? id,
    String? number,
    String? date,
    String? supplierId,
    String? warehouseId,
    String? status,
    String? comment,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      date: date ?? this.date,
      supplierId: supplierId ?? this.supplierId,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}
