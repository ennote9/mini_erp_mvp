/// Shipment Line entity. Docs: 02_Domain_Model.md. Read-only in MVP; UOM resolved from Item when displaying.
class ShipmentLine {
  const ShipmentLine({
    required this.id,
    required this.shipmentId,
    required this.itemId,
    required this.qty,
  });

  final String id;
  final String shipmentId;
  final String itemId;
  final int qty;

  ShipmentLine copyWith({
    String? id,
    String? shipmentId,
    String? itemId,
    int? qty,
  }) {
    return ShipmentLine(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      itemId: itemId ?? this.itemId,
      qty: qty ?? this.qty,
    );
  }
}
