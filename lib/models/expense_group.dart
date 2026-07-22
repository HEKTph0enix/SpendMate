// ExpenseGroup model for group expense management.

class ExpenseGroup {
  final String id;
  final String name;
  final String? description;
  final DateTime createdDate;
  final DateTime updatedAt;

  ExpenseGroup({
    required this.id,
    required this.name,
    this.description,
    DateTime? createdDate,
    DateTime? updatedAt,
  })  : createdDate = createdDate ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_date': createdDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseGroup.fromMap(Map<String, dynamic> map) {
    return ExpenseGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdDate: DateTime.parse(map['created_date'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ExpenseGroup copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdDate,
    DateTime? updatedAt,
  }) {
    return ExpenseGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) =>
      ExpenseGroup.fromMap(json);

  @override
  String toString() => 'ExpenseGroup(id: $id, name: $name)';
}
