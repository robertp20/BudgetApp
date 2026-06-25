import 'package:app_1/data/category_data.dart';
import 'package:app_1/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom categories are returned instead of falling back to food', () {
    final customCategory = ExpenseCategory(
      id: 'gym',
      name: 'Gym',
      icon: Icons.fitness_center,
      color: Colors.purple,
    );

    CategoryData.addCategory(customCategory);

    expect(CategoryData.isValidCategoryId('gym'), isTrue);
    expect(CategoryData.getCategoryById('gym').name, 'Gym');
    expect(CategoryData.getCategoryById('gym').id, 'gym');
  });
}
