import 'package:flutter/material.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:app_1/data/category_data.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  final String category;
  final bool isRecurring;
  final void Function(BuildContext)? deleteTapped;

  const ExpenseTile({
    super.key,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.category,
    required this.isRecurring,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    final expenseCategory = CategoryData.getCategoryById(category);
    
    return Slidable(
      endActionPane: ActionPane(
        motion : const StretchMotion(),
        children: [
          //Delete button
          SlidableAction(onPressed:   deleteTapped,
          icon: Icons.delete,
          backgroundColor: Colors.red,
          borderRadius: BorderRadius.circular(4),)
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: expenseCategory.color.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(expenseCategory.icon, color: expenseCategory.color, size: 24),
        ),
        title: Text(name),
        subtitle: Row(
          children: [
            Text(ExpenseData().getDayName(dateTime)),
            const SizedBox(width: 8),
            Text(expenseCategory.name, 
              style: TextStyle(color: expenseCategory.color, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            if (isRecurring)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Recurring',
                  style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: Text('-$amount€'),
      ),
    );
  }
}
