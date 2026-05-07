import 'package:flutter/material.dart';
import 'package:app_1/models/expense_category.dart';

class CategoryData {
  // Default categories
  static final Map<String, ExpenseCategory> defaultCategories = {
    'food': ExpenseCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    'shopping': ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    'car': ExpenseCategory(
      id: 'car',
      name: 'Car',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    'bills': ExpenseCategory(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt,
      color: Colors.red,
    ),
  };

  static List<ExpenseCategory> getAllDefaultCategories() {
    return defaultCategories.values.toList();
  }

  static ExpenseCategory getDefaultCategory() {
    return defaultCategories['food']!; // Default to 'Food' category
  }

  static ExpenseCategory getCategoryById(String id) {
    return defaultCategories[id] ?? getDefaultCategory();
  }

  static bool isValidCategoryId(String id) {
    return defaultCategories.containsKey(id);
  }
}
