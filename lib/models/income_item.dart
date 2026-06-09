class IncomeItem {
  final String id;
  final String name;
  final String amount;
  final bool isRecurring;
  final DateTime dateAdded;
  final String currency;

  IncomeItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.isRecurring,
    required this.dateAdded,
    this.currency = 'EUR',
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'isRecurring': isRecurring,
      'dateAdded': dateAdded.toIso8601String(),
      'currency': currency,
    };
  }

  // Create from map
  factory IncomeItem.fromMap(Map<dynamic, dynamic> map) {
    return IncomeItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as String,
      isRecurring: map['isRecurring'] as bool? ?? true,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      currency: map['currency'] as String? ?? 'EUR',
    );
  }
}
