import 'package:app_1/models/exchange_rate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _baseCurrency = 'EUR';
  static const List<String> _targetCurrencies = ['BAM', 'USD', 'GBP'];

  Future<ExchangeRate?> fetchExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$_baseCurrency'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;

        final filteredRates = <String, double>{};
        for (var currency in _targetCurrencies) {
          if (rates.containsKey(currency)) {
            filteredRates[currency] = (rates[currency] as num).toDouble();
          }
        }

        return ExchangeRate(
          baseCurrency: _baseCurrency,
          rates: filteredRates,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    }
    return null;
  }
}
