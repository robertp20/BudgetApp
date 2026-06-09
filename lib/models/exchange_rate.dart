class ExchangeRate {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime timestamp;

  ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      baseCurrency: map['baseCurrency'] as String,
      rates: Map<String, double>.from(map['rates'] as Map),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  bool isStale({int maxAgeHours = 24}) {
    final now = DateTime.now();
    final age = now.difference(timestamp).inHours;
    return age > maxAgeHours;
  }

  double getRate(String fromCurrency, String toCurrency) {
    if (fromCurrency == baseCurrency && rates.containsKey(toCurrency)) {
      return rates[toCurrency]!;
    }
    if (toCurrency == baseCurrency && rates.containsKey(fromCurrency)) {
      return 1.0 / rates[fromCurrency]!;
    }
    if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
      return rates[toCurrency]! / rates[fromCurrency]!;
    }
    return 1.0;
  }
}
