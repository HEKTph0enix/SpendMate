// Cash wallet model for tracking cash-in-hand balance.
// Single-instance per user — only one cash wallet exists.

class CashWallet {
  final String id;
  final double balance;
  final DateTime lastUpdatedAt;

  CashWallet({
    required this.id,
    this.balance = 0.0,
    DateTime? lastUpdatedAt,
  }) : lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'balance': balance,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }

  factory CashWallet.fromMap(Map<String, dynamic> map) {
    return CashWallet(
      id: map['id'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      lastUpdatedAt: DateTime.parse(map['last_updated_at'] as String),
    );
  }

  CashWallet copyWith({
    String? id,
    double? balance,
    DateTime? lastUpdatedAt,
  }) {
    return CashWallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory CashWallet.fromJson(Map<String, dynamic> json) =>
      CashWallet.fromMap(json);

  @override
  String toString() => 'CashWallet(id: $id, balance: $balance)';
}
