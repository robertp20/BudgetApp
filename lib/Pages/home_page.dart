import 'dart:math';

import 'package:app_1/components/expense_summary.dart';
import 'package:app_1/components/expense_tile.dart';
import 'package:app_1/components/category_pie_chart.dart';
import 'package:app_1/data/budget_data.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:app_1/data/income_data.dart';
import 'package:app_1/data/category_data.dart';
import 'package:app_1/data/currency_converter.dart';
import 'package:app_1/data/currency_data.dart';
import 'package:app_1/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    if (progress >= 0) {
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
  late final IncomeData incomeData;
  double monthlyBudget = 0.0;
  bool isLoading = true;

  //category state
  String selectedCategory = 'food';
  String selectedFilterCategory = 'all';
  bool isRecurringExpense = false;

  @override
  void initState() {
    super.initState();
    newExpenseNameController = TextEditingController();
    newExpenseEuroController = TextEditingController();
    newExpenseCentController = TextEditingController();
    expenseData = ExpenseData();
    budgetData = BudgetData();
    incomeData = IncomeData();

    Future.wait([expenseData.prepareData(), budgetData.prepareData(), incomeData.prepareData()]).then((_) {
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
    String tempSelectedCategory = selectedCategory;
    bool tempIsRecurring = isRecurringExpense;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setStateDialog) => AlertDialog(
          title: const Text('Add new expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //expense name
                TextField(
                  controller: newExpenseNameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                const SizedBox(height: 10),
                //expense amount - euros and cents
                Row(
                  children: [
                    Consumer<CurrencyData>(
                      builder: (context, currencyData, _) {
                        final symbol = CurrencyConverter.getCurrencySymbol(currencyData.selectedCurrency);
                        return Text(symbol);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: newExpenseEuroController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Euro'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('.'),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: newExpenseCentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Cent'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //category selection
                const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CategoryData.getAllDefaultCategories().map((category) {
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          tempSelectedCategory = category.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tempSelectedCategory == category.id ? category.color : Colors.grey,
                            width: tempSelectedCategory == category.id ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: tempSelectedCategory == category.id ? category.color.withAlpha(30) : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, color: category.color, size: 28),
                            const SizedBox(height: 4),
                            Text(category.name, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                //recurring toggle
                Row(
                  children: [
                    Expanded(
                      child: const Text('Recurring expense?', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Switch(
                      value: tempIsRecurring,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempIsRecurring = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            //Save button
            MaterialButton(
              onPressed: () {
                selectedCategory = tempSelectedCategory;
                isRecurringExpense = tempIsRecurring;
                save(dialogContext);
              },
              child: const Text('Save'),
            ),
            //Cancel button
            MaterialButton(
              onPressed: () => cancel(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
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
      category: selectedCategory,
      isRecurring: isRecurringExpense,
    );

    // Capture navigator before async operation
    final navigator = Navigator.of(dialogContext, rootNavigator: false);

    //add new expense item
    await expenseData.addNewExpense(newExpense);

    //clear controllers
    newExpenseNameController.clear();
    newExpenseEuroController.clear();
    newExpenseCentController.clear();
    selectedCategory = 'food'; // Reset to default
    isRecurringExpense = false; // Reset to default

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
    selectedCategory = 'food'; // Reset to default
    isRecurringExpense = false; // Reset to default

    //close dialog
    Navigator.of(dialogContext).pop();
  }

  Widget buildCategoryFilterBar() {
    final allCategories = CategoryData.getAllDefaultCategories();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilterCategory = 'all';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedFilterCategory == 'all' ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    color: selectedFilterCategory == 'all' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ...allCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilterCategory = category.id;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedFilterCategory == category.id 
                        ? category.color 
                        : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: selectedFilterCategory == category.id ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: selectedFilterCategory == category.id ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<ExpenseItem> getFilteredExpenses() {
    if (selectedFilterCategory == 'all') {
      return expenseData.GetAllExpenseList();
    } else {
      return expenseData.getExpensesByCategory(selectedFilterCategory);
    }
  }

  void showCategoryPieChart() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense Categories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CategoryPieChart(expenseData: expenseData),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double getTotalIncome() {
    return incomeData.getTotalIncome();
  }

  double getTotalExpenses() {
    final recurring = expenseData.getTotalRecurringExpenses();
    final oneTime = expenseData.getTotalOneTimeExpenses();
    return recurring + oneTime;
  }

  double getBudgetLeft() {
    final totalIncome = getTotalIncome();
    final totalExpenses = getTotalExpenses();
    final left = totalIncome - totalExpenses;
    return max(0.0, left);
  }

  

  double getBudgetProgress() {
  final totalIncome = getTotalIncome();
  if (totalIncome <= 0) return 0.0;

  final spent = getTotalExpenses();

  if (spent > totalIncome) return 1.0;

  return 1.0 - (spent / totalIncome);
}

  Widget buildBudgetGauge() {
    final budgetLeft = getBudgetLeft();
    final progress = getBudgetProgress();
    final spent = getTotalExpenses();
    final totalIncome = getTotalIncome();
    final overBudget = spent > totalIncome;
   
    final percentText =
    totalIncome <= 0
        ? '0% remaining'
        : overBudget
            ? '0% remaining'
            : '${(progress * 100).toStringAsFixed(0)}% remaining';

    final gaugeColor = overBudget
    ? Colors.red
    : progress > 0.5
        ? Colors.green
        : progress > 0.2
            ? Colors.orange
            : Colors.red;

    return Consumer<CurrencyData>(
      builder: (context, currencyData, _) {
        final symbol = CurrencyConverter.getCurrencySymbol(currencyData.selectedCurrency);
        
        final budgetLabel = totalIncome > 0
            ? (overBudget
                ? 'Over budget'
                : '$symbol${budgetLeft.toStringAsFixed(2)} left')
            : 'Add income in Profile';
        final subLabel = totalIncome > 0
            ? (overBudget
                ? '$symbol${(spent - totalIncome).abs().toStringAsFixed(2)} over'
                : '$symbol${spent.toStringAsFixed(2)} spent')
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
                                  color: totalIncome > 0
                                      ? Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (totalIncome > 0) ...[
                                Text(
                                  subLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              //'${(progress * 100).toStringAsFixed(0)}% remaining',
                               percentText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Colors.grey.shade200,
        onPressed: () => addNewExpense(context),
        child: const Icon(Icons.add,color: Colors.black,),
        
      ),
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: showCategoryPieChart,
            tooltip: 'View category breakdown',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                buildBudgetGauge(),
                //weekly expense summary
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Weekly Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 190,
                          child: Center(
                            child: ExpenseSummary(
                              startOfWeek: expenseData.startOfWeekDate(),
                              expenseData: expenseData,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //category filter
                buildCategoryFilterBar(),
                //list of expenses (filtered by category)
                ...getFilteredExpenses().map(
                  (expense) => ExpenseTile(
                    name: expense.name,
                    amount: expense.amount,
                    dateTime: expense.dateTime,
                    category: expense.category,
                    isRecurring: expense.isRecurring,
                    deleteTapped: (context) => deleteExpense(expense),
                  ),
                ),
              ],
            ),
    );
  }
}
