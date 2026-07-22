import 'package:flutter/material.dart';
import '../models/spending_insight.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'neobrutal/neobrutal_card.dart';

class InsightBadge extends StatelessWidget {
  final SpendingInsight insight;

  const InsightBadge({
    Key? key,
    required this.insight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    IconData icon;

    switch (insight.type) {
      case InsightType.trend:
        final isIncrease = insight.isPositiveChange;
        bgColor = isIncrease
            ? AppColors.getCardAccentColors(isDark)[5]
            : AppColors.getCardAccentColors(isDark)[4];
        textColor = isIncrease ? AppColors.error : AppColors.accentGreen;
        icon = isIncrease ? Icons.trending_up : Icons.trending_down;
        break;
      case InsightType.comparison:
        bgColor = AppColors.getCardAccentColors(isDark)[6];
        textColor = AppColors.accentOrange;
        icon = Icons.compare_arrows;
        break;
      case InsightType.highValue:
      case InsightType.anomaly:
        bgColor = AppColors.getCardAccentColors(isDark)[0];
        textColor = AppColors.accentPurple;
        icon = Icons.priority_high;
        break;
      case InsightType.recurring:
        bgColor = AppColors.getCardAccentColors(isDark)[3];
        textColor = AppColors.accentBlue;
        icon = Icons.autorenew;
        break;
    }

    return NeoBrutalCard(
      margin: const EdgeInsets.only(bottom: 10),
      backgroundColor: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.getBorder(isDark), width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: AppTextStyles.body(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
