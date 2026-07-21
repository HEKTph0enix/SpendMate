import 'package:flutter/material.dart';
import '../models/spending_insight.dart';
import 'neumorphic/neumorphic_card.dart';

class InsightBadge extends StatelessWidget {
  final SpendingInsight insight;

  const InsightBadge({
    Key? key,
    required this.insight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (insight.type) {
      case InsightType.trend:
        final isIncrease = insight.isPositiveChange;
        bgColor = isIncrease ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);
        textColor = isIncrease ? Colors.red : Colors.green;
        icon = isIncrease ? Icons.trending_up : Icons.trending_down;
        break;
      case InsightType.comparison:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.compare_arrows;
        break;
      case InsightType.highValue:
      case InsightType.anomaly:
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        icon = Icons.priority_high;
        break;
      case InsightType.recurring:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.autorenew;
        break;
    }

    return NeumorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      customColor: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
