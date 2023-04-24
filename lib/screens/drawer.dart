import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyer/screens/bluetoothPage.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import '../services/snackbar_service.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  late String _password;
  late TextEditingController _passwordController;

  @override
  void initState() {
    // TODO: implement initState

    _password = "";
    _passwordController = new TextEditingController();
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
                  Text("Bluetooth",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _bluetooth();
              },
            ),
            Divider(),
            globals.pidEnabled?
            MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.query_stats,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Disable PID",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                globals.pidEnabled = false;
                Provider.of<ConnectionProvider>(context,listen: false).setPID(false);
                setState(() {

                });
                SnackBar _sb = SnackBarService(message: "PID disabled", color: Colors.green).snackBar();

                ScaffoldMessenger.of(context).showSnackBar(_sb);
              },
            )
            :MaterialButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(Icons.query_stats,color: Colors.grey[400],),
                  Container(
                    width: 30,
                  ),
                  Text("Enable PID",style: TextStyle(fontWeight: FontWeight.w400,color: Theme.of(context).primaryColor),)
                ],
              ),
              onPressed: () {
                _enablePID();
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

  String getHashedPassword(String p){
    var bytes = utf8.encode(p); // data being hashed

    var digest = sha1.convert(bytes);

    return digest.toString();
  }
}

