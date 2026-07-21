import 'package:flutter/material.dart';
import '../models/savings_suggestion.dart';
import 'neumorphic/neumorphic_card.dart';
import 'neumorphic/neumorphic_icon_button.dart';
import 'neumorphic/neumorphic_container.dart';

class SuggestionCard extends StatelessWidget {
  final SavingsSuggestion suggestion;
  final VoidCallback onDismiss;

  const SuggestionCard({
    Key? key,
    required this.suggestion,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    IconData priorityIcon;

    switch (suggestion.priority) {
      case SuggestionPriority.high:
        priorityColor = Colors.red;
        priorityIcon = Icons.warning_amber_rounded;
        break;
      case SuggestionPriority.medium:
        priorityColor = Colors.orange;
        priorityIcon = Icons.info_outline;
        break;
      case SuggestionPriority.low:
        priorityColor = Colors.green;
        priorityIcon = Icons.lightbulb_outline;
        break;
    }

    return NeumorphicCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(priorityIcon, color: priorityColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Potential Savings: ₹${suggestion.estimatedSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                NeumorphicIconButton(
                  icon: Icons.close,
                  onPressed: onDismiss,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion.reason,
              style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            NeumorphicContainer(
              isInset: true,
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.recommendedAction,
                      style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
