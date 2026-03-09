/// Warehouse master data entity. Docs: 02_Domain_Model.md
class Warehouse {
  const Warehouse({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    this.comment,
  });

  final String id;
  final String code;
  final String name;
  final bool isActive;
  final String? comment;

  Warehouse copyWith({
    String? id,
    String? code,
    String? name,
    bool? isActive,
    String? comment,
  }) {
    return Warehouse(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      comment: comment ?? this.comment,
    );
  }
}
