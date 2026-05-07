import 'package:app_1/models/expense_item.dart';
import 'package:app_1/models/income_item.dart';
import 'package:hive/hive.dart';

class HiveDatabase {
  //reference our box lazily after Hive is opened
  Box get _myBox => Hive.box('expense_data');

  //write data
  Future<void> saveData(List<ExpenseItem> allExpense) async {
    List<List<dynamic>> allExpenseConverted = [];
    for (var expense in allExpense) {
      List<dynamic> singleExpense = [];
      singleExpense.add(expense.name);
      singleExpense.add(expense.amount);
      singleExpense.add(expense.dateTime);
      singleExpense.add(expense.category);
      singleExpense.add(expense.isRecurring);
      allExpenseConverted.add(singleExpense);
    }

    await _myBox.put('ALL_EXPENSE', allExpenseConverted);
  }

  //read data
  List<ExpenseItem> loadData() {
    List savedExpenses = _myBox.get('ALL_EXPENSE') ?? [];
    List<ExpenseItem> allExpenseList = [];

    for (int i = 0; i < savedExpenses.length; i++) {
      List singleExpense = savedExpenses[i];
      String name = singleExpense[0];
      String amount = singleExpense[1];
      DateTime dateTime = singleExpense[2];
      String category = singleExpense.length > 3 ? singleExpense[3] : 'food';
      bool isRecurring = singleExpense.length > 4 ? singleExpense[4] : false; // Default to false for backward compatibility

      allExpenseList.add(
        ExpenseItem(
          name: name,
          amount: amount,
          dateTime: dateTime,
          category: category,
          isRecurring: isRecurring,
        ),
      );
    }

    return allExpenseList;
  }

  bool hasSavedExpenses() {
    return _myBox.containsKey('ALL_EXPENSE');
  }

  // save incomes
  Future<void> saveIncomes(List<IncomeItem> allIncomes) async {
    List<Map<String, dynamic>> incomesConverted = [];
    for (var income in allIncomes) {
      incomesConverted.add(income.toMap());
    }
    await _myBox.put('ALL_INCOMES', incomesConverted);
  }

  // load incomes
  List<IncomeItem> loadIncomes() {
    List savedIncomes = _myBox.get('ALL_INCOMES') ?? [];
    List<IncomeItem> allIncomesList = [];

    for (var income in savedIncomes) {
      allIncomesList.add(IncomeItem.fromMap(income));
    }

    return allIncomesList;
  }

  bool hasSavedIncomes() {
    return _myBox.containsKey('ALL_INCOMES');
  }

  // save budget data
  Future<void> saveBudgetData(String monthlyIncome) async {
    await _myBox.put('MONTHLY_INCOME', monthlyIncome);
  }

  // load budget data
  String loadBudgetData() {
    return _myBox.get('MONTHLY_INCOME') ?? '0.0';
  }

  bool hasSavedBudget() {
    return _myBox.containsKey('MONTHLY_INCOME');
  }

  Future<bool> boxExists() async {
    return Hive.boxExists('expense_data');
  }
}
