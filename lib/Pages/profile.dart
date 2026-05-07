import 'package:app_1/data/budget_data.dart';
import 'package:app_1/data/income_data.dart';
import 'package:app_1/models/income_item.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final BudgetData budgetData;
  late final IncomeData incomeData;
  late final TextEditingController budgetController;
  late final TextEditingController incomeNameController;
  late final TextEditingController incomeEuroController;
  late final TextEditingController incomeCentController;
  bool isLoading = true;
  bool isRecurringIncome = true;

  @override
  void initState() {
    super.initState();
    budgetData = BudgetData();
    incomeData = IncomeData();
    budgetController = TextEditingController();
    incomeNameController = TextEditingController();
    incomeEuroController = TextEditingController();
    incomeCentController = TextEditingController();
    
    Future.wait([budgetData.prepareData(), incomeData.prepareData()]).then((_) {
      budgetController.text = budgetData.getMonthlyIncome();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    budgetController.dispose();
    incomeNameController.dispose();
    incomeEuroController.dispose();
    incomeCentController.dispose();
    super.dispose();
  }

  Future<void> saveBudget() async {
    String input = budgetController.text.trim();
    if (input.isEmpty) {
      return;
    }

    // Normalize the value to a valid decimal string
    if (!input.contains('.')) {
      input = '$input.00';
    } else {
      final parts = input.split('.');
      if (parts.length == 2) {
        final cents = parts[1].padRight(2, '0');
        input = '${parts[0]}.$cents';
      }
    }

    await budgetData.setMonthlyIncome(input);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Monthly budget saved: €$input')),
    );
  }

  void addIncomeDialog() {
    isRecurringIncome = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: incomeNameController,
                  decoration: const InputDecoration(
                    hintText: 'Income source (e.g., Salary)',
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('€'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: incomeEuroController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Euro'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('.'),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: incomeCentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Cent'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Recurring income?',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Switch(
                      value: isRecurringIncome,
                      onChanged: (value) {
                        setStateDialog(() {
                          isRecurringIncome = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () {
                saveIncome();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveIncome() async {
    String name = incomeNameController.text.trim();
    String euros = incomeEuroController.text.trim();
    String cents = incomeCentController.text.trim();

    if (name.isEmpty || euros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (cents.isEmpty) {
      cents = '0';
    }

    if (cents.length == 1) {
      cents = '0$cents';
    }

    String amount = '$euros.$cents';

    IncomeItem newIncome = IncomeItem(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      isRecurring: isRecurringIncome,
      dateAdded: DateTime.now(),
    );

    await incomeData.addNewIncome(newIncome);
    
    incomeNameController.clear();
    incomeEuroController.clear();
    incomeCentController.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Income added: €$amount')),
    );
  }

  Future<void> deleteIncome(IncomeItem income) async {
    await incomeData.deleteIncome(income);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Monthly Income Section (Legacy)
                  /*Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Legacy: Monthly Income',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current salary: €${budgetData.getMonthlyIncome()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: budgetController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Salary amount',
                              prefixText: '€',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: saveBudget,
                            child: const Text('Save monthly income'),
                          ),
                        ],
                      ),
                    ),
                  ),*/
                  const SizedBox(height: 20),

                  // Income Management Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Income Sources',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '€${incomeData.getTotalIncome().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (incomeData.getAllIncomes().isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Text(
                                  'No income sources yet',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: incomeData.getAllIncomes().map((income) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ListTile(
                                      leading: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            income.isRecurring
                                                ? Icons.repeat
                                                : Icons.receipt,
                                            color: income.isRecurring
                                                ? Colors.blue
                                                : Colors.orange,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        income.name,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        income.isRecurring ? 'Recurring' : 'One-time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+€${income.amount}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => deleteIncome(income),
                                            iconSize: 20,
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.only(left: 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: addIncomeDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Income'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Add multiple income sources (salary, freelance, etc.)',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Mark recurring incomes that come every month',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• All data is saved locally on your device',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Total income updates the budget gauge on home',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
