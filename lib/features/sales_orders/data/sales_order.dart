/// Sales Order document entity. Docs: 02_Domain_Model.md, 03_Statuses_and_Rules.md
class SalesOrder {
  const SalesOrder({
    required this.id,
    required this.number,
    required this.date,
    required this.customerId,
    required this.warehouseId,
    required this.status,
    this.comment,
  });

  final String id;
  /// Business number (e.g. SO-000001). Empty until assigned on first save.
  final String number;
  final String date;
  final String customerId;
  final String warehouseId;
  /// draft | confirmed | closed | cancelled
  final String status;
  final String? comment;

  bool get isDraft => status == 'draft';
  bool get isConfirmed => status == 'confirmed';
  bool get isClosed => status == 'closed';
  bool get isCancelled => status == 'cancelled';

  SalesOrder copyWith({
    String? id,
    String? number,
    String? date,
    String? customerId,
    String? warehouseId,
    String? status,
    String? comment,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}
