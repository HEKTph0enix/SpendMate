// Spending insight model for generated analytics results.

class SpendingInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final double value;
  final double? previousValue;
  final double? changePercent;
  final String period;
  final DateTime generatedAt;

  SpendingInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    this.previousValue,
    this.changePercent,
    required this.period,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  bool get isPositiveChange => changePercent != null && changePercent! > 0;

  bool get isNegativeChange => changePercent != null && changePercent! < 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'value': value,
      'previous_value': previousValue,
      'change_percent': changePercent,
      'period': period,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  factory SpendingInsight.fromMap(Map<String, dynamic> map) {
    return SpendingInsight(
      id: map['id'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InsightType.trend,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      value: (map['value'] as num).toDouble(),
      previousValue: (map['previous_value'] as num?)?.toDouble(),
      changePercent: (map['change_percent'] as num?)?.toDouble(),
      period: map['period'] as String,
      generatedAt: DateTime.parse(map['generated_at'] as String),
    );
  }

  @override
  String toString() =>
      'SpendingInsight(type: ${type.name}, title: $title, value: $value)';
}

enum InsightType {
  trend,
  anomaly,
  comparison,
  recurring,
  highValue,
}
