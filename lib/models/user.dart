// User model representing app users including the current device user.

class User {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final bool isCurrentUser;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.isCurrentUser = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'is_current_user': isCurrentUser ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      isCurrentUser: (map['is_current_user'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    bool? isCurrentUser,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);

  @override
  String toString() => 'User(id: $id, name: $name, isCurrentUser: $isCurrentUser)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
