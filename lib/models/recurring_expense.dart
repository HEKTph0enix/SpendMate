// Recurring expense model for detected or user-marked recurring transactions.

class RecurringExpense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final RecurrenceFrequency frequency;
  final DateTime? lastOccurrence;
  final DateTime? nextExpected;
  final bool isActive;
  final DateTime createdAt;

  RecurringExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    this.frequency = RecurrenceFrequency.monthly,
    this.lastOccurrence,
    this.nextExpected,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'frequency': frequency.name,
      'last_occurrence': lastOccurrence?.toIso8601String(),
      'next_expected': nextExpected?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => RecurrenceFrequency.monthly,
      ),
      lastOccurrence: map['last_occurrence'] != null
          ? DateTime.parse(map['last_occurrence'] as String)
          : null,
      nextExpected: map['next_expected'] != null
          ? DateTime.parse(map['next_expected'] as String)
          : null,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  RecurringExpense copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    RecurrenceFrequency? frequency,
    DateTime? lastOccurrence,
    DateTime? nextExpected,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
      nextExpected: nextExpected ?? this.nextExpected,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      RecurringExpense.fromMap(json);

  @override
  String toString() =>
      'RecurringExpense(id: $id, description: $description, amount: $amount, frequency: ${frequency.name})';
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}
