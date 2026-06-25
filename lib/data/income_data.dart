import 'package:app_1/data/hive_database.dart';
import 'package:app_1/models/income_item.dart';

class IncomeData {
  List<IncomeItem> incomeList = [];

  final db = HiveDatabase();

  Future<void> prepareData() async {
    if (await db.boxExists() && db.hasSavedIncomes()) {
      incomeList = db.loadIncomes();
    }
  }

  List<IncomeItem> getAllIncomes() {
    return incomeList;
  }

  Future<void> addNewIncome(IncomeItem item) async {
    incomeList.add(item);
    await db.saveIncomes(incomeList);
  }

  Future<void> deleteIncome(IncomeItem item) async {
    incomeList.remove(item);
    await db.saveIncomes(incomeList);
  }

  // Calculate total income
  double getTotalIncome() {
    return incomeList.fold(
      0.0,
      (double sum, IncomeItem income) => sum + (double.tryParse(income.amount) ?? 0.0),
    );
  }

  // Get recurring income only
  double getRecurringIncome() {
    return incomeList
        .where((income) => income.isRecurring)
        .fold(
          0.0,
          (double sum, IncomeItem income) => sum + (double.tryParse(income.amount) ?? 0.0),
        );
  }

  // Get one-time income only
  double getOneTimeIncome() {
    return incomeList
        .where((income) => !income.isRecurring)
        .fold(
          0.0,
          (double sum, IncomeItem income) => sum + (double.tryParse(income.amount) ?? 0.0),
        );
  }

  // Get total income for current month (all recurring + one-time from this month)
  double getCurrentMonthIncome() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return incomeList
        .where((income) =>
            income.isRecurring ||
            (income.dateAdded.month == currentMonth && income.dateAdded.year == currentYear))
        .fold(
          0.0,
          (double sum, IncomeItem income) => sum + (double.tryParse(income.amount) ?? 0.0),
        );
  }
}
