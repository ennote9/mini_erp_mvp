/// Stock Balance entity. Docs: 02_Domain_Model.md. One row per (item, warehouse).
class StockBalance {
  const StockBalance({
    required this.id,
    required this.itemId,
    required this.warehouseId,
    required this.qtyOnHand,
  });

  final String id;
  final String itemId;
  final String warehouseId;
  final int qtyOnHand;

  StockBalance copyWith({
    String? id,
    String? itemId,
    String? warehouseId,
    int? qtyOnHand,
  }) {
    return StockBalance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      warehouseId: warehouseId ?? this.warehouseId,
      qtyOnHand: qtyOnHand ?? this.qtyOnHand,
    );
  }
}
