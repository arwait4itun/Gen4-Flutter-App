import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flyer/screens/drawer.dart';
import 'package:flyer/screens/phone_status_page.dart';
import 'package:flyer/screens/settings.dart';
import 'package:flyer/screens/status.dart';
import 'package:flyer/screens/tests.dart';
import 'package:flyer/screens/utilities.dart';

class DashboardScaffold extends StatefulWidget {
  const DashboardScaffold({Key? key}) : super(key: key);

  @override
  _DashboardScaffoldState createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {

  int _selectedIndex = 0;


  final List<Widget> _pages = <Widget>[
    //checks if the device is a phone or tablet based on screen size
    MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.shortestSide < 550 ?
    PhoneStatusPageUI() : StatusPage(),
    const SettingsPage(),
    TestPage()
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTapFloatingActionButton(){
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context){
          return UtilitiesPage();
        });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      bottomNavigationBar: navigationBar(),
      body: _pages[_selectedIndex],
    );
  }

  AppBar appBar(){

    return AppBar(
      title: const Text("Flyer Frame"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,

      leading: IconButton(
        icon: Icon(Icons.bluetooth,color: Colors.white,),
        onPressed: (){
          Navigator.of(context).pop();
        },
      ),
    );
  }

  BottomNavigationBar navigationBar(){
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart,color: Colors.grey,),label: "status"),
        BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.grey,),label: "settings"),
        BottomNavigationBarItem(icon: Icon(Icons.build, color: Colors.grey,),label: "tests"),
      ],
      selectedItemColor: Colors.lightGreen,
      onTap: _onItemTapped,
    );
  }

}

