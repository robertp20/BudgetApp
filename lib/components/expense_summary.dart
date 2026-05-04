import 'package:app_1/bar_graph/bar_graph.dart';
import 'package:app_1/date_time/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:app_1/data/expense_data.dart';

class ExpenseSummary extends StatelessWidget {
  final DateTime startOfWeek;
  final ExpenseData expenseData;

  const ExpenseSummary({super.key, required this.startOfWeek, required this.expenseData});

  //calculate max amount in bar graph
  double calculateMaxY(){
    final dailySummary = expenseData.calculateDailyExpenseSummary();
    double maxY = 0;
    dailySummary.forEach((key, value) {
      if(value > maxY){
        maxY = value;
      }
    });
    //add 20% to maxY for better visualization
   // maxY = maxY + (maxY * 0.2);
    return maxY;
  }

  //calculate week total
  double calculateWeekTotal(){
    final dailySummary = expenseData.calculateDailyExpenseSummary();
    double weekTotal = 0;
    dailySummary.forEach((key, value) {
      weekTotal += value;
    });
    return weekTotal;
  }

  @override
  Widget build(BuildContext context) {
    //get yyyymmdd 
    String sunday = convertDateTimeToSting(startOfWeek.add(Duration(days: 0)));
    String monday = convertDateTimeToSting(startOfWeek.add(Duration(days: 1)));
    String tuesday = convertDateTimeToSting(startOfWeek.add(Duration(days: 2)));
    String wednesday = convertDateTimeToSting(startOfWeek.add(Duration(days: 3)));
    String thursday = convertDateTimeToSting(startOfWeek.add(Duration(days: 4)));
    String friday = convertDateTimeToSting(startOfWeek.add(Duration(days: 5)));
    String saturday = convertDateTimeToSting(startOfWeek.add(Duration(days: 6)));

    final dailySummary = expenseData.calculateDailyExpenseSummary();

    return Column(
      children: [
        //week total

        Text(
          'Week total:  €${calculateWeekTotal().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),  

        SizedBox(
          height: 200-39,
          child: MyBarChart(
            maxY: calculateMaxY(),
            sunAmount: dailySummary[sunday] ?? 0,
            monAmount: dailySummary[monday] ?? 0,
            tueAmount: dailySummary[tuesday] ?? 0,
            wedAmount: dailySummary[wednesday] ?? 0,
            thuAmount: dailySummary[thursday] ?? 0,
            friAmount: dailySummary[friday] ?? 0,
            satAmount: dailySummary[saturday] ?? 0,
          ),
        ),
      ],
    );
  }
}
