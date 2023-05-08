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
import 'package:provider/provider.dart';
import '../services/provider_service.dart';
import '../services/snackbar_service.dart';
import 'popup_calc.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  @override
  void dispose() {
    // TODO: implement dispose

    widget.connection.finish();
    widget.connection.close();
    widget.connection.dispose();

    ConnectionProvider().clearSettings();
    Provider.of<ConnectionProvider>(context,listen: false).clearSettings();

    super.dispose();
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
      PhoneStatusPageUI(statusStream: multiStream,) : StatusPage(),
      SettingsPage(connection: connection, settingsStream: multiStream,),
      TestPage(connection: connection, testsStream: multiStream,),
    ];



    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(_scaffoldKey),
      bottomNavigationBar: navigationBar(),
      body: _pages[_selectedIndex],
      drawer: DrawerPage(),
    );
  }

  AppBar appBar(GlobalKey<ScaffoldState> _scaffoldKey){

    return AppBar(
      title: const Text("Flyer Frame"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,

      leading: IconButton(
        icon: Icon(Icons.bluetooth,color: Colors.white,),
        onPressed: (){
          widget.connection.finish();
          widget.connection.close();
          widget.connection.dispose();

          ConnectionProvider().clearSettings();
          Provider.of<ConnectionProvider>(context,listen: false).clearSettings();

          SnackBar _sb = SnackBarService(message: "Pair Again", color: Colors.green).snackBar();

          ScaffoldMessenger.of(context).showSnackBar(_sb);

          Navigator.of(context).pop();
        },
      ),

      actions: [
        IconButton(
            onPressed: (){
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.more_vert),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]),
        ),
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

