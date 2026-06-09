class ExpenseItem{

  final String name;
  final String amount;
  final DateTime dateTime;
  final String category;
  final bool isRecurring;
  final String currency;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.category,
    required this.isRecurring,
    this.currency = 'EUR',
  });
}