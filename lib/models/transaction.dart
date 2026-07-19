// Unified transaction model for the financial dashboard.
// Lives alongside the existing Expense model — does not replace it.

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String paymentMethod;
  final TransactionSource source;
  final DateTime date;
  final String? note;
  final String? accountId;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.paymentMethod,
    this.source = TransactionSource.manual,
    required this.date,
    this.note,
    this.accountId,
    this.isRecurring = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category,
      'payment_method': paymentMethod,
      'source': source.name,
      'date': date.toIso8601String(),
      'note': note,
      'account_id': accountId,
      'is_recurring': isRecurring ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] as String,
      paymentMethod: map['payment_method'] as String,
      source: TransactionSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => TransactionSource.manual,
      ),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      accountId: map['account_id'] as String?,
      isRecurring: (map['is_recurring'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? paymentMethod,
    TransactionSource? source,
    DateTime? date,
    String? note,
    String? accountId,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      source: source ?? this.source,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  Map<String, dynamic> toJson() => toMap();
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction.fromMap(json);

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, type: ${type.name}, category: $category)';
}

enum TransactionType {
  income,
  expense,
  transfer,
}

enum TransactionSource {
  manual,
  sms,
  import_,
  bankSync,
}
