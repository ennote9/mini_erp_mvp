/// Customer master data entity. Docs: 02_Domain_Model.md
class Customer {
  const Customer({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    this.phone,
    this.email,
    this.comment,
  });

  final String id;
  final String code;
  final String name;
  final bool isActive;
  final String? phone;
  final String? email;
  final String? comment;

  Customer copyWith({
    String? id,
    String? code,
    String? name,
    bool? isActive,
    String? phone,
    String? email,
    String? comment,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      comment: comment ?? this.comment,
    );
  }
}
