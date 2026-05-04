import 'dart:math';

import 'package:app_1/components/expense_summary.dart';
import 'package:app_1/components/expense_tile.dart';
import 'package:app_1/data/budget_data.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:app_1/models/expense_item.dart';
import 'package:flutter/material.dart';

class _SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SemiCircleGaugePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 28.0;
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, pi, false, backgroundPaint);

    if (progress > 0) {
      final sweepAngle = pi * progress;
      canvas.drawArc(rect, pi, sweepAngle, false, foregroundPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controller
  late final TextEditingController newExpenseNameController;
  late final TextEditingController newExpenseEuroController;
  late final TextEditingController newExpenseCentController;

  //data instances
  late final ExpenseData expenseData;
  late final BudgetData budgetData;
  double monthlyBudget = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    newExpenseNameController = TextEditingController();
    newExpenseEuroController = TextEditingController();
    newExpenseCentController = TextEditingController();
    expenseData = ExpenseData();
    budgetData = BudgetData();

    Future.wait([expenseData.prepareData(), budgetData.prepareData()]).then((_) {
      setState(() {
        monthlyBudget = double.tryParse(budgetData.getMonthlyIncome()) ?? 0.0;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    newExpenseNameController.dispose();
    newExpenseEuroController.dispose();
    newExpenseCentController.dispose();
    super.dispose();
  }

  //Add new expense

  void addNewExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add new expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //expense name
            TextField(
              controller: newExpenseNameController,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            SizedBox(height: 10),
            //expense amount - euros and cents
            Row(
              children: [
                Text('€'),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: newExpenseEuroController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Euro'),
                  ),
                ),
                SizedBox(width: 10),
                Text('.'),
                SizedBox(width: 5),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: newExpenseCentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Cent'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          //Save button
          MaterialButton(
            onPressed: () => save(dialogContext),
            child: Text('Save'),
          ),
          //Cancel button
          MaterialButton(
            onPressed: () => cancel(dialogContext),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //delete expense
  Future<void> deleteExpense(ExpenseItem expenese) async {
    await expenseData.deleteNewExpense(expenese);
    setState(() {});
  }

  //Save
  void save(BuildContext dialogContext) async {
    String name = newExpenseNameController.text.trim();
    String euros = newExpenseEuroController.text.trim();
    String cents = newExpenseCentController.text.trim();

    if (name.isEmpty || euros.isEmpty) {
      return;
    }

    // Default cents to 0 if empty
    if (cents.isEmpty) {
      cents = '0';
    }

    // Ensure cents are 2 digits
    if (cents.length == 1) {
      cents = '0$cents';
    }

    String amount = '$euros.$cents';

    //create new expense item
    ExpenseItem newExpense = ExpenseItem(
      name: name,
      amount: amount,
      dateTime: DateTime.now(),
    );

    // Capture navigator before async operation
    final navigator = Navigator.of(dialogContext, rootNavigator: false);

    //add new expense item
    await expenseData.addNewExpense(newExpense);

    //clear controllers
    newExpenseNameController.clear();
    newExpenseEuroController.clear();
    newExpenseCentController.clear();

    if (!mounted) return;

    //close dialog and refresh UI
    navigator.pop();
    setState(() {});
  }

  //Cancel
  void cancel(BuildContext dialogContext) {
    //clear controllers
    newExpenseNameController.clear();
    newExpenseEuroController.clear();
    newExpenseCentController.clear();

    //close dialog
    Navigator.of(dialogContext).pop();
  }

  double getTotalExpenses() {
    return expenseData.GetAllExpenseList().fold(
      0.0,
      (double sum, ExpenseItem expense) => sum + (double.tryParse(expense.amount) ?? 0.0),
    );
  }

  double getBudgetLeft() {
    final left = monthlyBudget - getTotalExpenses();
    return max(0.0, left);
  }

  double getBudgetProgress() {
    if (monthlyBudget <= 0) return 0.0;
    return min(1.0, getBudgetLeft() / monthlyBudget);
  }

  Widget buildBudgetGauge() {
    final budgetLeft = getBudgetLeft();
    final progress = getBudgetProgress();
    final spent = getTotalExpenses();
    final overBudget = monthlyBudget > 0 && spent > monthlyBudget;
    final gaugeColor = overBudget
        ? Colors.red
        : (progress > 0.2 ? Colors.green : Colors.orange);
    final budgetLabel = monthlyBudget > 0
        ? (overBudget
            ? 'Over budget'
            : '€${budgetLeft.toStringAsFixed(2)} left')
        : 'Set budget in profile';
    final subLabel = monthlyBudget > 0
        ? (overBudget
            ? '€${(spent - monthlyBudget).abs().toStringAsFixed(2)} over'
            : '€${spent.toStringAsFixed(2)} spent')
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 140),
                    painter: _SemiCircleGaugePainter(progress, gaugeColor),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            budgetLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: monthlyBudget > 0
                                  ? Colors.black
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (monthlyBudget > 0) ...[
                            Text(
                              subLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% remaining',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewExpense(context),
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                buildBudgetGauge(),
                //weekly expense summary
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: 200,
                  color: const Color.fromARGB(255, 240, 240, 240),
                  child: Center(
                    child: ExpenseSummary(
                      startOfWeek: expenseData.startOfWeekDate(),
                      expenseData: expenseData,
                    ),
                  ),
                ),
                //list of expenses
                ...expenseData.GetAllExpenseList().map(
                  (expense) => ExpenseTile(
                    name: expense.name,
                    amount: expense.amount,
                    dateTime: expense.dateTime,
                    deleteTapped: (context) => deleteExpense(expense),
                  ),
                ),
              ],
            ),
    );
  }
}
