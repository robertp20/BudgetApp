import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_1/data/category_data.dart';
import 'package:app_1/data/expense_data.dart';

class CategoryPieChart extends StatelessWidget {
  final ExpenseData expenseData;

  const CategoryPieChart({
    super.key,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = expenseData.calculateCategoryTotals();
    final double totalAmount = categoryTotals.values.fold(0, (sum, val) => sum + val);

    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text('No expenses yet'),
      );
    }

    final pieSections = <PieChartSectionData>[];

    categoryTotals.forEach((categoryId, total) {
      final category = CategoryData.getCategoryById(categoryId);
      final percentage = (total / totalAmount) * 100;

      pieSections.add(
        PieChartSectionData(
          color: category.color,
          value: total,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: pieSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            
            itemCount: categoryTotals.length,
            itemBuilder: (context, index) {
              final entries = categoryTotals.entries.toList();
              final categoryId = entries[index].key;
              final total = entries[index].value;
              final category = CategoryData.getCategoryById(categoryId);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(category.icon, color: category.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '€${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
