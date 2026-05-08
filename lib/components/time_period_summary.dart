import 'package:app_1/bar_graph/bar_graph.dart';
import 'package:app_1/date_time/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:fl_chart/fl_chart.dart';

class TimePeriodSummary extends StatefulWidget {
  final ExpenseData expenseData;

  const TimePeriodSummary({super.key, required this.expenseData});

  @override
  State<TimePeriodSummary> createState() => _TimePeriodSummaryState();
}

class _TimePeriodSummaryState extends State<TimePeriodSummary> {
  String selectedPeriod = 'week'; // 'week', 'month', 'year'

  Map<String, double> getWeeklySummary() {
    final startOfWeek = widget.expenseData.startOfWeekDate();
    final dailySummary = widget.expenseData.calculateDailyExpenseSummary();
    return {
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 0))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 0)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 1))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 1)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 2))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 2)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 3))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 3)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 4))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 4)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 5))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 5)))] ?? 0,
      convertDateTimeToSting(startOfWeek.add(const Duration(days: 6))): 
        dailySummary[convertDateTimeToSting(startOfWeek.add(const Duration(days: 6)))] ?? 0,
    };
  }

  double calculateMaxY() {
    late Map<String, double> data;
    if (selectedPeriod == 'week') {
      data = getWeeklySummary();
    } else if (selectedPeriod == 'month') {
      data = widget.expenseData.calculateMonthlySummary();
    } else {
      data = widget.expenseData.calculateYearlySummary();
    }

    double maxY = 0;
    for (final value in data.values) {
      if (value > maxY) {
        maxY = value;
      }
    }
    return maxY == 0 ? 100 : maxY;
  }

  double calculateTotal() {
    late Map<String, double> data;
    if (selectedPeriod == 'week') {
      data = getWeeklySummary();
    } else if (selectedPeriod == 'month') {
      data = widget.expenseData.calculateMonthlySummary();
    } else {
      data = widget.expenseData.calculateYearlySummary();
    }

    return data.values.fold(0.0, (double sum, double value) => sum + value);
  }

  BarChart buildChart() {
    if (selectedPeriod == 'week') {
      return buildWeeklyChart();
    } else if (selectedPeriod == 'month') {
      return buildMonthlyChart();
    } else {
      return buildYearlyChart();
    }
  }

  BarChart buildWeeklyChart() {
    final weeklySummary = getWeeklySummary();
    final values = weeklySummary.values.toList();

    return BarChart(
      BarChartData(
        maxY: calculateMaxY(),
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                return Text(days[value.toInt()]);
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: calculateMaxY(),
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChart buildMonthlyChart() {
    final monthlySummary = widget.expenseData.calculateMonthlySummary();
    final values = monthlySummary.values.toList();

    return BarChart(
      BarChartData(
        maxY: calculateMaxY(),
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: Colors.green,
                width: 15,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: calculateMaxY(),
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChart buildYearlyChart() {
    final yearlySummary = widget.expenseData.calculateYearlySummary();
    final values = yearlySummary.values.toList();
    final keys = yearlySummary.keys.toList();

    return BarChart(
      BarChartData(
        maxY: calculateMaxY(),
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < keys.length) {
                  return Text(keys[value.toInt()].substring(5), style: const TextStyle(fontSize: 8));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: Colors.orange,
                width: 12,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: calculateMaxY(),
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and period tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildPeriodButton('Week', 'week'),
                    const SizedBox(width: 8),
                    _buildPeriodButton('Month', 'month'),
                    const SizedBox(width: 8),
                    _buildPeriodButton('Year', 'year'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total text
            Text(
              '${selectedPeriod == 'week' ? 'Week' : selectedPeriod == 'month' ? 'Month' : 'Year'} total: €${calculateTotal().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 200,
              child: buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
