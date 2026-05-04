import 'package:flutter/material.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  final void Function(BuildContext)? deleteTapped;

  const ExpenseTile({
    super.key,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
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
        title: Text(name),
        subtitle: Text(ExpenseData().getDayName(dateTime)),
        trailing: Text('$amount€'),
      ),
    );
  }
}
