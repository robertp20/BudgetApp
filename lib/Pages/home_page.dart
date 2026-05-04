import 'package:app_1/components/expense_summary.dart';
import 'package:app_1/components/expense_tile.dart';
import 'package:app_1/data/expense_data.dart';
import 'package:app_1/models/expense_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controller
  late final TextEditingController newExpenseNameController;
  late final TextEditingController newExpenseEuroController;
  late final TextEditingController newExpenseCentController;

  //expense data instance
  late final ExpenseData expenseData;

  @override
  void initState() {
    super.initState();
    newExpenseNameController = TextEditingController();
    newExpenseEuroController = TextEditingController();
    newExpenseCentController = TextEditingController();
    expenseData = ExpenseData();

    expenseData.prepareData().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    newExpenseNameController.dispose();
    newExpenseEuroController.dispose();
    newExpenseCentController.dispose();
    super.dispose();
  }

  //Add new expense

  void addNewExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add new expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //expense name
            TextField(
              controller: newExpenseNameController,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            SizedBox(height: 10),
            //expense amount - euros and cents
            Row(
              children: [
                Text('€'),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: newExpenseEuroController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Euro'),
                  ),
                ),
                SizedBox(width: 10),
                Text('.'),
                SizedBox(width: 5),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: newExpenseCentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Cent'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          //Save button
          MaterialButton(
            onPressed: () => save(dialogContext),
            child: Text('Save'),
          ),
          //Cancel button
          MaterialButton(
            onPressed: () => cancel(dialogContext),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //delete expense
  Future<void> deleteExpense(ExpenseItem expenese) async {
    await expenseData.deleteNewExpense(expenese);
    setState(() {});
  }

  //Save
  void save(BuildContext dialogContext) async {
    String name = newExpenseNameController.text.trim();
    String euros = newExpenseEuroController.text.trim();
    String cents = newExpenseCentController.text.trim();

    if (name.isEmpty || euros.isEmpty) {
      return;
    }

    // Default cents to 0 if empty
    if (cents.isEmpty) {
      cents = '0';
    }

    // Ensure cents are 2 digits
    if (cents.length == 1) {
      cents = '0$cents';
    }

    String amount = '$euros.$cents';

    //create new expense item
    ExpenseItem newExpense = ExpenseItem(
      name: name,
      amount: amount,
      dateTime: DateTime.now(),
    );

    //add new expense to the list
    await expenseData.addNewExpense(newExpense);

    //clear controllers
    newExpenseNameController.clear();
    newExpenseEuroController.clear();
    newExpenseCentController.clear();

    //close dialog
    Navigator.of(dialogContext).pop();

    //refresh UI
    setState(() {});
  }

  //Cancel
  void cancel(BuildContext dialogContext) {
    //clear controllers
    newExpenseNameController.clear();
    newExpenseEuroController.clear();
    newExpenseCentController.clear();

    //close dialog
    Navigator.of(dialogContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewExpense(context),
        child: Icon(Icons.add),
      ),
      body: ListView(
        children: [
          //weekly expense summary
          Container(
            padding: EdgeInsets.only(top: 10),
            height: 200,
            color: const Color.fromARGB(255, 240, 240, 240),
            child: Center(
              child: ExpenseSummary(
                startOfWeek: expenseData.startOfWeekDate(),
                expenseData: expenseData,
              ),
            ),
          ),
          //list of expenses
          ...expenseData.GetAllExpenseList().map(
            (expense) => ExpenseTile(
              name: expense.name,
              amount: expense.amount,
              dateTime: expense.dateTime,
              deleteTapped: (context) => deleteExpense(expense),
            ),
          ),
        ],
      ),
    );
  }
}
