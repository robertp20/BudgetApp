import 'package:app_1/bar_graph/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarChart extends StatelessWidget {
 
  final double? maxY ;
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thuAmount;
  final double friAmount;
  final double satAmount;

 const MyBarChart({super.key, 
 this.maxY, 
 required this.sunAmount, 
 required this.monAmount, 
 required this.tueAmount, 
 required this.wedAmount, 
 required this.thuAmount, 
 required this.friAmount, 
 required this.satAmount});


  @override
  Widget build(BuildContext context) {

    //initialaize bar data
    BarData myBarData = BarData(
      sunAmount: sunAmount, 
      monAmount: monAmount, 
      tueAmount: tueAmount, 
      wedAmount: wedAmount, 
      thuAmount: thuAmount, 
      friAmount: friAmount, 
      satAmount: satAmount
    );
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta){
                String text = '';
                switch(value.toInt()){
                  case 0:
                    text = 'S';
                    break;
                  case 1:
                    text = 'M';
                    break;
                  case 2:
                    text = 'T';
                    break;
                  case 3:
                    text = 'W';
                    break;
                  case 4:
                    text = 'T';
                    break;
                  case 5:
                    text = 'F';
                    break;
                  case 6:
                    text = 'S';
                    break;
                }
                return Text(text);
              }
            )
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false)
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: myBarData.allBars.map(
          (data) => BarChartGroupData(
            x: data.x, 
            barRods: [
              BarChartRodData(
                toY: data.y, 
                color: Colors.blue, 
                width: 20,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData:  BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.grey[300],
                )
              )
            ]
          )
        ).toList()
      )

    );
  }
}