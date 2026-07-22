// Budget model for monthly spending limits.

class Budget {
  final String id;
  final int month;
  final int year;
  final double limitAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.limitAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'limit_amount': limitAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Budget copyWith({
    String? id,
    int? month,
    int? year,
    double? limitAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      limitAmount: limitAmount ?? this.limitAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Budget.fromJson(Map<String, dynamic> json) => Budget.fromMap(json);

  @override
  String toString() =>
      'Budget(id: $id, month: $month/$year, limit: $limitAmount)';
}
