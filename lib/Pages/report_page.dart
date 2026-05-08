import 'package:flutter/material.dart';
import 'package:app_1/components/time_period_summary.dart';
import 'package:app_1/data/expense_data.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final ExpenseData expenseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    expenseData = ExpenseData();
    
    expenseData.prepareData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TimePeriodSummary(expenseData: expenseData),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}