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
}
