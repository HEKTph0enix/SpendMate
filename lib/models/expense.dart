// Expense model for personal and group expenses.

class Expense {
  final String id;
  final double amount;
  final DateTime dateTime;
  final String category;
  final String paymentMethod;
  final String? note;
  final bool isGroupExpense;
  final String? groupId;
  final String? payerUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.category,
    required this.paymentMethod,
    this.note,
    this.isGroupExpense = false,
    this.groupId,
    this.payerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date_time': dateTime.toIso8601String(),
      'category': category,
      'payment_method': paymentMethod,
      'note': note,
      'is_group_expense': isGroupExpense ? 1 : 0,
      'group_id': groupId,
      'payer_user_id': payerUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['date_time'] as String),
      category: map['category'] as String,
      paymentMethod: map['payment_method'] as String,
      note: map['note'] as String?,
      isGroupExpense: (map['is_group_expense'] as int?) == 1,
      groupId: map['group_id'] as String?,
      payerUserId: map['payer_user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    DateTime? dateTime,
    String? category,
    String? paymentMethod,
    String? note,
    bool? isGroupExpense,
    String? groupId,
    String? payerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      isGroupExpense: isGroupExpense ?? this.isGroupExpense,
      groupId: groupId ?? this.groupId,
      payerUserId: payerUserId ?? this.payerUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Expense.fromJson(Map<String, dynamic> json) => Expense.fromMap(json);

  @override
  String toString() =>
      'Expense(id: $id, amount: $amount, category: $category, isGroup: $isGroupExpense)';
}
