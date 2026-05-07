import 'package:flutter/material.dart';
import 'package:app_1/models/income_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class IncomeTile extends StatelessWidget {
  final IncomeItem income;
  final void Function(BuildContext)? deleteTapped;

  const IncomeTile({
    Key? key,
    required this.income,
    required this.deleteTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: deleteTapped,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            income.isRecurring ? Icons.repeat : Icons.single_bed_outlined,
            color: Colors.green,
            size: 24,
          ),
        ),
        title: Text(income.name),
        subtitle: Row(
          children: [
            Text(income.isRecurring ? 'Recurring' : 'One-time'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+€${income.amount}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}
