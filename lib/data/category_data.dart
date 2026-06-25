import 'package:flutter/material.dart';
import 'package:app_1/models/expense_category.dart';

class CategoryData {
  static final Map<String, ExpenseCategory> _categoryLookup = {};

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
    'personal care': ExpenseCategory(
      id: 'personal_care',
      name: 'Self care',
      icon: Icons.person,
      color: Colors.green,
    ),
    'other': ExpenseCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.category,
      color: Colors.grey,
    ),
  };

  static void _ensureCategoriesLoaded() {
    if (_categoryLookup.isNotEmpty) {
      return;
    }

    for (final entry in defaultCategories.entries) {
      _categoryLookup[entry.key] = entry.value;
      _categoryLookup[entry.value.id] = entry.value;
    }
  }

  static void addCategory(ExpenseCategory category) {
    if (category.id.isEmpty) {
      return;
    }

    _ensureCategoriesLoaded();
    _categoryLookup[category.id] = category;
  }

  static List<ExpenseCategory> getAllDefaultCategories() {
    _ensureCategoriesLoaded();
    return _categoryLookup.values.toSet().toList();
  }

  static ExpenseCategory getDefaultCategory() {
    return getCategoryById('food');
  }

  static ExpenseCategory getCategoryById(String id) {
    _ensureCategoriesLoaded();
    return _categoryLookup[id] ?? getDefaultCategory();
  }

  static bool isValidCategoryId(String id) {
    _ensureCategoriesLoaded();
    return _categoryLookup.containsKey(id);
  }
}
