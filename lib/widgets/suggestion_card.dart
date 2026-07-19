import 'package:flutter/material.dart';
import '../models/savings_suggestion.dart';

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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion.reason,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.recommendedAction,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
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
