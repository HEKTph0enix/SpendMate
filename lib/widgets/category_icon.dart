import 'package:flutter/material.dart';
import '../constants/categories.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final double padding;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24.0,
    this.padding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: CategoryHelper.getContainerColor(category),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CategoryHelper.getIcon(category),
        color: CategoryHelper.getColor(category),
        size: size,
      ),
    );
  }
}
