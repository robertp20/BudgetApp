import 'package:app_1/Pages/home_page.dart';
import 'package:app_1/Pages/profile.dart';
import 'package:app_1/Pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

class FirstPage extends StatefulWidget {
   const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedIndex = 0;

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
      ),

      home: Scaffold(
        
        appBar: AppBar(
          title: Text("Test"),
          backgroundColor: Colors.lightGreenAccent[200],
          elevation: 0,
          leading: Icon(Icons.menu),
          actions: [
            IconButton(onPressed: () {},
             icon: Icon(Icons.logout))
          ],
        ),

        body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          backgroundColor: Colors.lightGreenAccent[200],
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

