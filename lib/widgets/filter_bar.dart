import 'package:flutter/material.dart';
import 'neumorphic/neumorphic_container.dart';

class FilterBar extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = filter == activeFilter;
          
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                onFilterChanged(filter);
              }
            },
            child: NeumorphicContainer(
              isInset: isActive,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                filter,
                style: TextStyle(
                  color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
