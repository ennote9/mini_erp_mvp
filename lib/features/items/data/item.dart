/// Item master data entity. Docs: 02_Domain_Model.md
class Item {
  const Item({
    required this.id,
    required this.code,
    required this.name,
    required this.uom,
    required this.isActive,
    this.description,
  });

  final String id;
  final String code;
  final String name;
  final String uom;
  final bool isActive;
  final String? description;

  Item copyWith({
    String? id,
    String? code,
    String? name,
    String? uom,
    bool? isActive,
    String? description,
  }) {
    return Item(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      uom: uom ?? this.uom,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}
