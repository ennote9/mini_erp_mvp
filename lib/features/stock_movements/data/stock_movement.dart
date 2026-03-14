/// Stock Movement entity. Docs: 02_Domain_Model.md.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.itemId,
    required this.warehouseId,
    required this.qtyDelta,
    required this.movementType,
    required this.sourceDocumentType,
    required this.sourceDocumentId,
    required this.createdAt,
    this.comment,
  });

  final String id;
  final String itemId;
  final String warehouseId;
  /// Positive for receipt, negative for shipment.
  final int qtyDelta;
  /// e.g. 'receipt', 'shipment'
  final String movementType;
  final String sourceDocumentType;
  final String sourceDocumentId;
  final String createdAt;
  final String? comment;

  StockMovement copyWith({
    String? id,
    String? itemId,
    String? warehouseId,
    int? qtyDelta,
    String? movementType,
    String? sourceDocumentType,
    String? sourceDocumentId,
    String? createdAt,
    String? comment,
  }) {
    return StockMovement(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      warehouseId: warehouseId ?? this.warehouseId,
      qtyDelta: qtyDelta ?? this.qtyDelta,
      movementType: movementType ?? this.movementType,
      sourceDocumentType: sourceDocumentType ?? this.sourceDocumentType,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
    );
  }
}
