import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/currency_formatter.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final bool isDark;

  const CategoryPieChart({
    super.key,
    required this.categoryTotals,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No expense data to chart.'));
    }

    final double totalExpense = categoryTotals.values.fold(0, (sum, val) => sum + val);

    final List<PieChartSectionData> sections = [];
    
    // Sort to show largest first
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      if (entry.value <= 0) continue;
      
      final percentage = (entry.value / totalExpense) * 100;
      final color = CategoryHelper.getColor(entry.key);
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: percentage >= 15 ? 60 : 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: percentage >= 10 ? _Badge(
            entry.key,
            size: 30,
            borderColor: AppColors.getBorder(isDark),
          ) : null,
          badgePositionPercentageOffset: 1.1,
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(enabled: true),
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: sections,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String category;
  final double size;
  final Color borderColor;

  const _Badge(this.category, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CategoryHelper.getColor(category),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Icon(
          CategoryHelper.getIcon(category),
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }
}
