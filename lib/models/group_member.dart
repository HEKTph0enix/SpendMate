// GroupMember model linking users to expense groups.

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      userId: map['user_id'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      GroupMember.fromMap(json);

  @override
  String toString() =>
      'GroupMember(id: $id, groupId: $groupId, userId: $userId)';
}
