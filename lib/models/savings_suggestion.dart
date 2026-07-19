// Savings suggestion model for rule-based savings tips.
// Each suggestion includes reason, estimated savings, recommended action, and priority.
// Never provides investment or guaranteed financial-return advice.

class SavingsSuggestion {
  final String id;
  final String reason;
  final double estimatedSavings;
  final String recommendedAction;
  final SuggestionPriority priority;
  final String? category;
  final bool isActioned;
  final DateTime generatedAt;

  SavingsSuggestion({
    required this.id,
    required this.reason,
    required this.estimatedSavings,
    required this.recommendedAction,
    this.priority = SuggestionPriority.medium,
    this.category,
    this.isActioned = false,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reason': reason,
      'estimated_savings': estimatedSavings,
      'recommended_action': recommendedAction,
      'priority': priority.name,
      'category': category,
      'is_actioned': isActioned ? 1 : 0,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  factory SavingsSuggestion.fromMap(Map<String, dynamic> map) {
    return SavingsSuggestion(
      id: map['id'] as String,
      reason: map['reason'] as String,
      estimatedSavings: (map['estimated_savings'] as num).toDouble(),
      recommendedAction: map['recommended_action'] as String,
      priority: SuggestionPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => SuggestionPriority.medium,
      ),
      category: map['category'] as String?,
      isActioned: (map['is_actioned'] as int?) == 1,
      generatedAt: DateTime.parse(map['generated_at'] as String),
    );
  }

  SavingsSuggestion copyWith({
    String? id,
    String? reason,
    double? estimatedSavings,
    String? recommendedAction,
    SuggestionPriority? priority,
    String? category,
    bool? isActioned,
    DateTime? generatedAt,
  }) {
    return SavingsSuggestion(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      estimatedSavings: estimatedSavings ?? this.estimatedSavings,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isActioned: isActioned ?? this.isActioned,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory SavingsSuggestion.fromJson(Map<String, dynamic> json) =>
      SavingsSuggestion.fromMap(json);

  @override
  String toString() =>
      'SavingsSuggestion(reason: $reason, savings: $estimatedSavings, priority: ${priority.name})';
}

enum SuggestionPriority {
  high,
  medium,
  low,
}
