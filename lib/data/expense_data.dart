import 'package:app_1/data/hive_database.dart';
import 'package:app_1/date_time/date_time_helper.dart';
import 'package:app_1/models/expense_item.dart';

class ExpenseData {
  //list of ALL expenses
  List<ExpenseItem> overallExpenseList = [];

  //get expenses
  List<ExpenseItem> GetAllExpenseList() {
    return overallExpenseList;
  }

  //prepare data to display
  final db = HiveDatabase();
  Future<void> prepareData() async {
    if (await db.boxExists() && db.hasSavedExpenses()) {
      overallExpenseList = db.loadData();
    }
  }

  //add new expense
  Future<void> addNewExpense(ExpenseItem item) async {
    overallExpenseList.add(item);
    await db.saveData(overallExpenseList);
  }

  //delete expense
  Future<void> deleteNewExpense(ExpenseItem item) async {
    overallExpenseList.remove(item);
    await db.saveData(overallExpenseList);
  }

  //get weekday
  String getDayName(DateTime datetime) {
    switch (datetime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return ' ';
    }
  }

  //get the date for the start of the week
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;
    //get date
    DateTime today = DateTime.now();

    //Find sunday
    for (var i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

  //convert overral list of expenses into daily list
  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {};

    for (var expense in overallExpenseList) {
      String date = convertDateTimeToSting(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }

  //get expenses filtered by category
  List<ExpenseItem> getExpensesByCategory(String category) {
    return overallExpenseList.where((expense) => expense.category == category).toList();
  }

  //get all unique categories from expenses
  List<String> getAllCategoriesFromExpenses() {
    final categories = <String>{};
    for (var expense in overallExpenseList) {
      categories.add(expense.category);
    }
    return categories.toList();
  }

  //calculate total expense by category
  Map<String, double> calculateCategoryTotals() {
    Map<String, double> categoryTotals = {};

    for (var expense in overallExpenseList) {
      double amount = double.parse(expense.amount);

      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] = categoryTotals[expense.category]! + amount;
      } else {
        categoryTotals[expense.category] = amount;
      }
    }
    return categoryTotals;
  }

  //get recurring expenses only
  List<ExpenseItem> getRecurringExpenses() {
    return overallExpenseList.where((expense) => expense.isRecurring).toList();
  }

  //get one-time expenses only
  List<ExpenseItem> getOneTimeExpenses() {
    return overallExpenseList.where((expense) => !expense.isRecurring).toList();
  }

  //calculate total monthly recurring expenses
  double getTotalRecurringExpenses() {
    return getRecurringExpenses().fold(
      0.0,
      (double sum, ExpenseItem expense) => sum + (double.tryParse(expense.amount) ?? 0.0),
    );
  }

  //calculate total one-time expenses (current month)
  double getTotalOneTimeExpenses() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return getOneTimeExpenses()
        .where((expense) => expense.dateTime.month == currentMonth && expense.dateTime.year == currentYear)
        .fold(
          0.0,
          (double sum, ExpenseItem expense) => sum + (double.tryParse(expense.amount) ?? 0.0),
        );
  }

  //calculate monthly expense summary for the current year
  Map<String, double> calculateMonthlySummary() {
    Map<String, double> monthlySummary = {
      'Jan': 0,
      'Feb': 0,
      'Mar': 0,
      'Apr': 0,
      'May': 0,
      'Jun': 0,
      'Jul': 0,
      'Aug': 0,
      'Sep': 0,
      'Oct': 0,
      'Nov': 0,
      'Dec': 0,
    };

    final currentYear = DateTime.now().year;

    for (var expense in overallExpenseList) {
      if (expense.dateTime.year == currentYear) {
        double amount = double.parse(expense.amount);
        final monthName = _getMonthName(expense.dateTime.month);
        monthlySummary[monthName] = (monthlySummary[monthName] ?? 0) + amount;
      }
    }
    return monthlySummary;
  }

  //calculate yearly expense summary (last 12 months)
  Map<String, double> calculateYearlySummary() {
    Map<String, double> yearlySummary = {};
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final year = now.year - (i ~/ 12);
      final month = 12 - (11 - i);
      final date = DateTime(year, month);
      yearlySummary['${date.year}-${date.month.toString().padLeft(2, '0')}'] = 0;
    }

    for (var expense in overallExpenseList) {
      double amount = double.parse(expense.amount);
      final key = '${expense.dateTime.year}-${expense.dateTime.month.toString().padLeft(2, '0')}';
      if (yearlySummary.containsKey(key)) {
        yearlySummary[key] = yearlySummary[key]! + amount;
      }
    }
    return yearlySummary;
  }

  //helper method to get month name
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
