import 'package:app_1/models/exchange_rate.dart';

class CurrencyConverter {
  static const String baseCurrency = 'EUR';
  static const List<String> supportedCurrencies = ['BAM', 'EUR', 'USD', 'GBP'];
  static const Map<String, String> currencySymbols = {
    'BAM': 'KM',
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
  };

  static double convert(
    double amount,
    String fromCurrency,
    String toCurrency,
    ExchangeRate exchangeRate,
  ) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    final rate = exchangeRate.getRate(fromCurrency, toCurrency);
    return amount * rate;
  }

  static String formatCurrency(double amount, String currency) {
    final symbol = currencySymbols[currency] ?? currency;
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatCurrencyCompact(double amount, String currency) {
    final symbol = currencySymbols[currency] ?? currency;
    if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String getCurrencySymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }

  static bool isValidCurrency(String currency) {
    return supportedCurrencies.contains(currency);
  }
}
