import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/screens/drawer.dart';
import 'package:flyer/screens/phone_status_page.dart';
import 'package:flyer/screens/settings.dart';
import 'package:flyer/screens/status.dart';
import 'package:flyer/screens/tests.dart';
import 'package:flyer/screens/utilities.dart';
import 'package:flyer/globals.dart' as globals;

class DashboardScaffold extends StatefulWidget {

  BluetoothConnection connection;

  DashboardScaffold({required this.connection});

  @override
  _DashboardScaffoldState createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {

  int _selectedIndex = 0;
  BluetoothConnection? connection;
  Stream<Uint8List>? multiStream; //for multiple stream

  @override
  void initState() {
    // TODO: implement initState


    if(widget.connection.isConnected){
      //if connection is already established
      connection = widget.connection;

      setState(() {});
    }
    else{
      //reconnect with the selected device's address
      BluetoothConnection.toAddress(globals.selectedDevice!.address).then((_connection) {
        print('Connected to the device');

        connection = _connection;

        setState(() {

        });
      });
    }

    try{
      multiStream = connection!.input!.asBroadcastStream();
    }
    catch(e){
      print("Dashboard: Broadcast stream: ${e.toString()}");
    }


    super.initState();
  }




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


    final List<Widget> _pages = <Widget>[
      //checks if the device is a phone or tablet based on screen size
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.shortestSide < 550 ?
      PhoneStatusPageUI() : StatusPage(),
      SettingsPage(connection: connection, settingsStream: multiStream,),
      TestPage(connection: connection, testsStream: multiStream,),
    ];



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

