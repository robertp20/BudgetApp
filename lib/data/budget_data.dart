import 'package:app_1/data/hive_database.dart';
import 'package:app_1/models/exchange_rate.dart';

class BudgetData {
  // monthly income amount
  String monthlyIncome = '0.0';
  String currency = 'EUR';

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

  // convert monthly income to target currency
  String getMonthlyIncomeInCurrency(String targetCurrency, ExchangeRate? exchangeRate) {
    if (exchangeRate == null || currency == targetCurrency) {
      return monthlyIncome;
    }

    final amount = double.tryParse(monthlyIncome) ?? 0.0;
    final converted = amount * exchangeRate.getRate(currency, targetCurrency);
    return converted.toStringAsFixed(2);
  }
}