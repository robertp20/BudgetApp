import 'package:app_1/Pages/first_page.dart';
import 'package:app_1/Pages/home_page.dart';
import 'package:app_1/Pages/profile.dart';
import 'package:app_1/Pages/report_page.dart';
import 'package:app_1/data/exchange_rate_service.dart';
import 'package:app_1/data/currency_data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize hive
  await Hive.initFlutter();
  //open a hive box
  await Hive.openBox('expense_data');

  // Initialize currency data
  final currencyData = CurrencyData();
  await currencyData.prepareData();

  // Fetch exchange rates in background
  _initializeExchangeRates(currencyData);

  runApp(MyApp(currencyData: currencyData));
}

void _initializeExchangeRates(CurrencyData currencyData) {
  final service = ExchangeRateService();
  service.fetchExchangeRates().then((rate) {
    if (rate != null) {
      currencyData.setExchangeRate(rate);
    }
  });
}

class MyApp extends StatelessWidget {
  final CurrencyData currencyData;

  const MyApp({super.key, required this.currencyData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrencyData>.value(
      value: currencyData,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: FirstPage(),
        routes: {
          '/firstpage': (context) => FirstPage(),
          '/homepage': (context) => HomePage(),
          '/settingspage': (context) => SettingPage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}
