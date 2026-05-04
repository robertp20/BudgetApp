import 'package:app_1/data/budget_data.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final BudgetData budgetData;
  late final TextEditingController budgetController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    budgetData = BudgetData();
    budgetController = TextEditingController();
    budgetData.prepareData().then((_) {
      budgetController.text = budgetData.getMonthlyIncome();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    budgetController.dispose();
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
                  const Text(
                    'Monthly Income',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current salary: €${budgetData.getMonthlyIncome()}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Update your monthly income',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveBudget,
                    child: const Text('Save monthly income'),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This value is saved locally and will be available the next time you open the app.',
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
