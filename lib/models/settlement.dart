// Settlement model for recording payments between group members.

class Settlement {
  final String id;
  final String groupId;
  final String paidByUserId;
  final String paidToUserId;
  final double amount;
  final DateTime dateTime;
  final String? note;
  final DateTime createdAt;

  Settlement({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.paidToUserId,
    required this.amount,
    required this.dateTime,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'paid_by_user_id': paidByUserId,
      'paid_to_user_id': paidToUserId,
      'amount': amount,
      'date_time': dateTime.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      paidByUserId: map['paid_by_user_id'] as String,
      paidToUserId: map['paid_to_user_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['date_time'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Settlement copyWith({
    String? id,
    String? groupId,
    String? paidByUserId,
    String? paidToUserId,
    double? amount,
    DateTime? dateTime,
    String? note,
    DateTime? createdAt,
  }) {
    return Settlement(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      paidByUserId: paidByUserId ?? this.paidByUserId,
      paidToUserId: paidToUserId ?? this.paidToUserId,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement.fromMap(json);

  @override
  String toString() =>
      'Settlement(id: $id, from: $paidByUserId, to: $paidToUserId, amount: $amount)';
}
