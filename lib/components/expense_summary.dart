import 'package:app_1/bar_graph/bar_graph.dart';
import 'package:app_1/date_time/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:app_1/data/expense_data.dart';

class ExpenseSummary extends StatelessWidget {
  final DateTime startOfWeek;
  final ExpenseData expenseData;

  const ExpenseSummary({super.key, required this.startOfWeek, required this.expenseData});

  Map<String, double> getWeeklySummary() {
    final dailySummary = expenseData.calculateDailyExpenseSummary();
    return {
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 0))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 0)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 1))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 1)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 2))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 2)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 3))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 3)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 4))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 4)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 5))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 5)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 6))): dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 6)))] ?? 0,
    };
  }

  double calculateMaxY() {
    final weeklySummary = getWeeklySummary();
    double maxY = 0;
    for (final value in weeklySummary.values) {
      if (value > maxY) {
        maxY = value;
      }
    }
    return maxY;
  }

  double calculateWeekTotal() {
    final weeklySummary = getWeeklySummary();
    return weeklySummary.values.fold(0.0, (double sum, double value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final weeklySummary = getWeeklySummary();

    return Column(
      children: [
        //week total
        Text(
          'Week total:  €${calculateWeekTotal().toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(
          height: 200 - 39,
          child: MyBarChart(
            maxY: calculateMaxY(),
            sunAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 0)))] ?? 0,
            monAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 1)))] ?? 0,
            tueAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 2)))] ?? 0,
            wedAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 3)))] ?? 0,
            thuAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 4)))] ?? 0,
            friAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 5)))] ?? 0,
            satAmount: weeklySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 6)))] ?? 0,
          ),
        ),
      ],
    );
  }
}
