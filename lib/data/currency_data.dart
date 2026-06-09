import 'package:app_1/data/hive_database.dart';
import 'package:app_1/models/exchange_rate.dart';
import 'package:flutter/foundation.dart';

class CurrencyData extends ChangeNotifier {
  String _selectedCurrency = 'EUR';
  ExchangeRate? _exchangeRate;
  final HiveDatabase _db = HiveDatabase();

  String get selectedCurrency => _selectedCurrency;
  ExchangeRate? get exchangeRate => _exchangeRate;

  Future<void> prepareData() async {
    // Load selected currency
    _selectedCurrency = _db.loadSelectedCurrency();

    // Load cached exchange rates
    _exchangeRate = _db.loadExchangeRates();

    notifyListeners();
  }

  Future<void> setExchangeRate(ExchangeRate? rate) async {
    _exchangeRate = rate;
    if (rate != null) {
      await _db.saveExchangeRates(rate);
    }
    notifyListeners();
  }

  Future<void> setSelectedCurrency(String currency) async {
    if (_selectedCurrency != currency) {
      _selectedCurrency = currency;
      await _db.saveSelectedCurrency(currency);
      notifyListeners();
    }
  }

  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency || _exchangeRate == null) {
      return amount;
    }

    return amount * _exchangeRate!.getRate(fromCurrency, toCurrency);
  }
}
