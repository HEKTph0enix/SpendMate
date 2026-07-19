import 'package:flutter/material.dart';

class StatChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child; // Typically a chart widget
  final VoidCallback? onMoreTap;

  const StatChartCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (onMoreTap != null)
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onMoreTap,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200, // Fixed height for charts
              width: double.infinity,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
