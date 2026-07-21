import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  }) : assert(
  gradientColors.length >= 2,
  'At least two gradient colors are required',
  );

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(
      Radius.circular(18),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              height: 86,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),

                      // Prevents the title from overflowing.
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Shrinks large amounts to fit inside the card.
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.format(amount),
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}