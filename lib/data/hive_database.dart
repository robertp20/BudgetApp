import 'package:app_1/models/expense_item.dart';
import 'package:app_1/models/exchange_rate.dart';
import 'package:app_1/models/income_item.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      singleExpense.add(expense.currency);
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
      bool isRecurring = singleExpense.length > 4 ? singleExpense[4] : false;
      String currency = singleExpense.length > 5 ? singleExpense[5] : 'EUR';

      allExpenseList.add(
        ExpenseItem(
          name: name,
          amount: amount,
          dateTime: dateTime,
          category: category,
          isRecurring: isRecurring,
          currency: currency,
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

  // save exchange rates
  Future<void> saveExchangeRates(ExchangeRate exchangeRate) async {
    await _myBox.put('EXCHANGE_RATES', exchangeRate.toMap());
  }

  // load exchange rates
  ExchangeRate? loadExchangeRates() {
    final data = _myBox.get('EXCHANGE_RATES');
    if (data != null) {
      return ExchangeRate.fromMap(Map<String, dynamic>.from(data as Map));
    }
    return null;
  }

  // save selected currency
  Future<void> saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SELECTED_CURRENCY', currency);
  }

  // load selected currency
  String loadSelectedCurrency() {
    final box = Hive.box('expense_data');
    return box.get('SELECTED_CURRENCY', defaultValue: 'EUR') as String;
  }
}
