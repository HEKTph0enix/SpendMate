// GroupSplit model for tracking individual shares in group expenses.

class GroupSplit {
  final String id;
  final String expenseId;
  final String userId;
  final double shareAmount;
  final double? sharePercentage;
  final String splitType;

  GroupSplit({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.shareAmount,
    this.sharePercentage,
    required this.splitType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'share_amount': shareAmount,
      'share_percentage': sharePercentage,
      'split_type': splitType,
    };
  }

  factory GroupSplit.fromMap(Map<String, dynamic> map) {
    return GroupSplit(
      id: map['id'] as String,
      expenseId: map['expense_id'] as String,
      userId: map['user_id'] as String,
      shareAmount: (map['share_amount'] as num).toDouble(),
      sharePercentage: (map['share_percentage'] as num?)?.toDouble(),
      splitType: map['split_type'] as String,
    );
  }

  GroupSplit copyWith({
    String? id,
    String? expenseId,
    String? userId,
    double? shareAmount,
    double? sharePercentage,
    String? splitType,
  }) {
    return GroupSplit(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      shareAmount: shareAmount ?? this.shareAmount,
      sharePercentage: sharePercentage ?? this.sharePercentage,
      splitType: splitType ?? this.splitType,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory GroupSplit.fromJson(Map<String, dynamic> json) =>
      GroupSplit.fromMap(json);

  @override
  String toString() =>
      'GroupSplit(id: $id, expenseId: $expenseId, userId: $userId, share: $shareAmount)';
}
