// Category definitions with icons and colors for expense categorization.

import 'package:flutter/material.dart';

class CategoryHelper {
  CategoryHelper._();

  static IconData getIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Rent':
        return Icons.home_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Groceries':
        return Icons.local_grocery_store_rounded;
      case 'Other':
        return Icons.more_horiz_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF6B6B);
      case 'Travel':
        return const Color(0xFF4ECDC4);
      case 'Rent':
        return const Color(0xFF45B7D1);
      case 'Shopping':
        return const Color(0xFFF7DC6F);
      case 'Bills':
        return const Color(0xFFBB8FCE);
      case 'Entertainment':
        return const Color(0xFFFF8A65);
      case 'Education':
        return const Color(0xFF82E0AA);
      case 'Health':
        return const Color(0xFFEC7063);
      case 'Groceries':
        return const Color(0xFF76D7C4);
      case 'Other':
        return const Color(0xFFAEB6BF);
      default:
        return const Color(0xFFAEB6BF);
    }
  }

  static Color getContainerColor(String category) {
    return getColor(category).withOpacity(0.15);
  }
}
