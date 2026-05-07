import 'package:app_1/Pages/home_page.dart';
import 'package:app_1/Pages/profile.dart';
import 'package:app_1/Pages/report_page.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

class FirstPage extends StatefulWidget {
   const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkTheme = false;
  String _selectedCurrency = 'USD';

  void _navigateBottomBar (int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    HomePage(),
    ProfilePage(),
    SettingPage()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      // 🔥 OVO VAŽNO — link prema DevicePreview
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,

      home: Scaffold(
        key: _scaffoldKey,
        
        appBar: AppBar(
          title: Text("Test", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.lightGreenAccent[200],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.settings),
            color: Colors.black,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.logout),
              color: Colors.black,
            )
          ],
        ),

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent[200],
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text('Dark Theme'),
                trailing: Switch(
                  value: _isDarkTheme,
                  onChanged: (bool value) {
                    setState(() {
                      _isDarkTheme = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      items: <String>['BAM','EUR', 'USD', 'GBP']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCurrency = newValue ?? 'USD';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          backgroundColor: Colors.lightGreenAccent[200],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            )
          ],
        ),

        

        backgroundColor: Colors.lightGreen[100],
        
      ),
    );
  }
}

