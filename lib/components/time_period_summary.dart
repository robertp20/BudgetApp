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
  String selectedPeriod = 'week';
  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;

  // --- Date helpers ---

  DateTime get _selectedWeekStart {
    final base = widget.expenseData.startOfWeekDate();
    return base.add(Duration(days: 7 * weekOffset));
  }

  DateTime get _selectedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  int get _selectedYear => DateTime.now().year + yearOffset;

  String get _navigationLabel {
    if (selectedPeriod == 'week') {
      final start = _selectedWeekStart;
      final end = start.add(const Duration(days: 6));
      return '${_shortMonth(start.month)} ${start.day} – ${_shortMonth(end.month)} ${end.day}, ${end.year}';
    } else if (selectedPeriod == 'month') {
      final d = _selectedMonth;
      return '${_fullMonth(d.month)} ${d.year}';
    } else {
      return '$_selectedYear';
    }
  }

  bool get _canNavigateForward {
    if (selectedPeriod == 'week') return weekOffset < 0;
    if (selectedPeriod == 'month') return monthOffset < 0;
    return yearOffset < 0;
  }

  String _shortMonth(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m - 1];
  }

  String _fullMonth(int m) {
    const names = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return names[m - 1];
  }

  void _navigate(int delta) {
    setState(() {
      if (selectedPeriod == 'week') {
        weekOffset += delta;
      } else if (selectedPeriod == 'month') {
        monthOffset += delta;
      } else {
        yearOffset += delta;
      }
    });
  }

  // --- Data ---

  Map<String, double> _getActiveData() {
    if (selectedPeriod == 'week') return _getWeeklySummary();
    if (selectedPeriod == 'month') return _getMonthlySummary();
    return _getYearlySummary();
  }

  Map<String, double> _getWeeklySummary() {
    final start = _selectedWeekStart;
    final allDaily = widget.expenseData.calculateDailyExpenseSummary();
    final result = <String, double>{};
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final key = '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
      result[key] = allDaily[key] ?? 0;
    }
    return result;
  }

  Map<String, double> _getMonthlySummary() {
    final d = _selectedMonth;
    return widget.expenseData.calculateDailyExpenseSummaryForMonth(d.year, d.month);
  }

  Map<String, double> _getYearlySummary() {
    return widget.expenseData.calculateMonthlySummaryForYear(_selectedYear);
  }

  double _calculateMaxY() {
    final data = _getActiveData();
    double maxY = 0;
    for (final v in data.values) {
      if (v > maxY) maxY = v;
    }
    return maxY == 0 ? 100 : maxY;
  }

  double _calculateTotal() {
    return _getActiveData().values.fold(0.0, (sum, v) => sum + v);
  }

  // --- Charts ---

  BarChart _buildChart() {
    if (selectedPeriod == 'week') return _buildWeeklyChart();
    if (selectedPeriod == 'month') return _buildMonthDailyChart();
    return _buildYearMonthlyChart();
  }

  BarChart _buildWeeklyChart() {
    final values = _getWeeklySummary().values.toList();
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return BarChart(BarChartData(
      maxY: _calculateMaxY(),
      minY: 0,
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(dayLabels[value.toInt()]),
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(values.length, (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: values[i],
          color: Colors.blue,
          width: 20,
          borderRadius: BorderRadius.circular(5),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: _calculateMaxY(), color: Colors.grey[300]),
        )],
      )),
    ), swapAnimationDuration: Duration.zero);
  }

  BarChart _buildMonthDailyChart() {
    final d = _selectedMonth;
    final daysInMonth = DateTime(d.year, d.month + 1, 0).day;
    final data = _getMonthlySummary();
    final values = List.generate(daysInMonth, (i) {
      final day = i + 1;
      final key = '${d.year}${d.month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
      return data[key] ?? 0.0;
    });
    final maxY = _calculateMaxY();

    return BarChart(BarChartData(
      maxY: maxY,
      minY: 0,
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final day = value.toInt() + 1;
            if (day == 1 || day % 5 == 0) {
              return Text('$day', style: const TextStyle(fontSize: 9));
            }
            return const Text('');
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(values.length, (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: values[i],
          color: Colors.green,
          width: 7,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey[300]),
        )],
      )),
    ), swapAnimationDuration: Duration.zero);
  }

  BarChart _buildYearMonthlyChart() {
    final values = _getYearlySummary().values.toList();
    const monthLabels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    final maxY = _calculateMaxY();

    return BarChart(BarChartData(
      maxY: maxY,
      minY: 0,
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(monthLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(values.length, (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: values[i],
          color: Colors.orange,
          width: 15,
          borderRadius: BorderRadius.circular(5),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey[300]),
        )],
      )),
    ), swapAnimationDuration: Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final periodLabel = selectedPeriod == 'week' ? 'Week' : selectedPeriod == 'month' ? 'Month' : 'Year';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + period tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(children: [
                  _buildPeriodButton('Week', 'week'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Month', 'month'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Year', 'year'),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            // Navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _navigate(-1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Text(_navigationLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: _canNavigateForward ? null : Colors.grey[400]),
                  onPressed: _canNavigateForward ? () => _navigate(1) : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Total
            Text(
              '$periodLabel total: €${_calculateTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Chart
            SizedBox(height: 200, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
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
