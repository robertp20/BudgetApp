import 'package:app_1/data/hive_database.dart';

class BudgetData {
  // monthly income amount
  String monthlyIncome = '0.0';

  // prepare data to display
  final db = HiveDatabase();
  Future<void> prepareData() async {
    if (await db.boxExists() && db.hasSavedBudget()) {
      monthlyIncome = db.loadBudgetData();
    }
  }

  // set monthly income
  Future<void> setMonthlyIncome(String amount) async {
    monthlyIncome = amount;
    await db.saveBudgetData(monthlyIncome);
  }

  // get monthly income
  String getMonthlyIncome() {
    return monthlyIncome;
  }
}