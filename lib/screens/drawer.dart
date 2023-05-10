import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/screens/bluetoothPage.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import '../services/snackbar_service.dart';

class DrawerPage extends StatefulWidget {

  BluetoothConnection connection;

  DrawerPage({required this.connection});


  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  late String _password;
  late String _deviceName;
  late TextEditingController _passwordController;
  late TextEditingController _deviceNameController;

  late BluetoothConnection connection;

  @override
  void initState() {
    // TODO: implement initState

    _password = "";
    _passwordController = new TextEditingController();

    _deviceName = "";
    _deviceNameController = new TextEditingController();

    connection = widget.connection;
    super.initState();
  }

  void _bluetooth(){
    print("bluetooth");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context){
        return BluetoothPage();
      })
    );
  }

  void _enablePID(){
    print("pid");

    _displayTextInputDialog(context);
  }





  void _exitApp(){
    print("exit");
    SystemNavigator.pop();
  }

  void _changeDeviceName(){

    print("change name");

    _displayChangeName(context);
  }


  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.08,
            ),

            MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.bluetooth,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Change Device Name",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _changeDeviceName();
              },
            ),
            Divider(),
            MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.exit_to_app,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Exit App",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _exitApp();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Password To Enable PID'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              controller: _passwordController,
              decoration: InputDecoration(hintText: "Enter Password"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                ),
                child: Text('OK'),
                onPressed: () {
                  setState(() {

                    if(getHashedPassword(_password) == globals.password){
                      globals.pidEnabled = true;

                      SnackBar _sb = SnackBarService(message: "PID enabled", color: Colors.green).snackBar();

                      Provider.of<ConnectionProvider>(context,listen: false).setPID(true);

                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                      Navigator.pop(context);
                    }
                    else{
                      SnackBar _sb = SnackBarService(message: "Wrong Password", color: Colors.red).snackBar();

                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                      print("wrong password");
                    }

                  });
                },
              ),

            ],
          );
        });
  }


  Future<void> _displayChangeName(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change Name of Device:'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _deviceName = value;
                });
              },
              controller: _deviceNameController,
              decoration: InputDecoration(hintText: "Enter New Device Name"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                ),
                child: Text('OK'),
                onPressed: () {
                  setState(() {

                    if(_deviceName=="" || _deviceName==" " || _deviceName.length > 10){


                      SnackBar _sb = SnackBarService(message: "Invalid Name", color: Colors.red).snackBar();


                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                      Navigator.pop(context);
                    }
                    else{

                      FlutterBluetoothSerial.instance.changeName(_deviceName);

                      SnackBar _sb = SnackBarService(message: "Device Name Changed", color: Colors.red).snackBar();

                      ScaffoldMessenger.of(context).showSnackBar(_sb);

                    }

                  });
                },
              ),

            ],
          );
        });
  }

  String getHashedPassword(String p){
    var bytes = utf8.encode(p); // data being hashed

    var digest = sha1.convert(bytes);

    return digest.toString();
  }
}

