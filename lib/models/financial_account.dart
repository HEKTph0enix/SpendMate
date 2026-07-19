// Financial account model representing a linked bank account or wallet.
// Account numbers are stored masked (last 4 digits only) for security.

class FinancialAccount {
  final String id;
  final String name;
  final AccountType type;
  final String? bankName;
  final String? maskedAccountNumber; // Format: XXXX-XXXX-1234
  final double balance;
  final DateTime? lastSyncedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    this.bankName,
    this.maskedAccountNumber,
    this.balance = 0.0,
    this.lastSyncedAt,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'bank_name': bankName,
      'masked_account_number': maskedAccountNumber,
      'balance': balance,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FinancialAccount.fromMap(Map<String, dynamic> map) {
    return FinancialAccount(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AccountType.bank,
      ),
      bankName: map['bank_name'] as String?,
      maskedAccountNumber: map['masked_account_number'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  FinancialAccount copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? bankName,
    String? maskedAccountNumber,
    double? balance,
    DateTime? lastSyncedAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      balance: balance ?? this.balance,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Masks a full account number, keeping only the last 4 digits.
  static String maskAccountNumber(String fullNumber) {
    final digits = fullNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return 'XXXX-XXXX-$last4';
  }

  Map<String, dynamic> toJson() => toMap();
  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      FinancialAccount.fromMap(json);

  @override
  String toString() =>
      'FinancialAccount(id: $id, name: $name, type: ${type.name}, balance: $balance)';
}

enum AccountType {
  bank,
  wallet,
  upi,
}
