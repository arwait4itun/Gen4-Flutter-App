import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/im_paired.dart';
import 'package:flyer/screens/Dashboard.dart';
import 'package:flyer/services/provider_service.dart';
import 'package:flyer/services/snackbar_service.dart';
import 'package:provider/provider.dart';

import 'DiscoveryPage.dart';
import 'SelectBondedDevicePage.dart';
import 'package:flyer/globals.dart' as globals;


class BluetoothPage extends StatefulWidget {

  BluetoothPage({Key? key}) : super(key: key);



  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

 // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
   // _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(title: const Text('General',style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.w400),)),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
              activeColor: Colors.lightGreen,
            ),
            ListTile(
              title: const Text('Adapter address',),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Adapter name',),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            Divider(),
            ListTile(title: const Text('Device Settings', style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.w400),)),
            SwitchListTile(
              title: const Text('Auto-try specific pin when pairing'),
              subtitle: const Text('Pin 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(
                          (BluetoothPairingRequest request) {
                        print("Trying to auto-pair with Pin 1234");
                        if (request.pairingVariant == PairingVariant.Pin) {
                          return Future.value("1234");
                        }
                        return Future.value(null);
                      });
                } else {
                  FlutterBluetoothSerial.instance
                      .setPairingRequestHandler(null);
                }
              },
              activeColor: Colors.lightGreen,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                      onPressed: () async {


                        final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DiscoveryPage();
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          print('Discovery -> selected ' + selectedDevice.address);

                          globals.isConnected = true;

                          ConnectionProvider().setConnection(true);

                          globals.selectedDevice = selectedDevice;
                          BluetoothConnection connection = await BluetoothConnection.toAddress(selectedDevice.address);

                          //impaired message
                          connection!.output!.add(ascii.encode(ImPaired().createPacket()));
                          connection!.output.allSent;

                          Provider.of<ConnectionProvider>(context,listen: false).setConnection(true);

                          SnackBar _sb = SnackBarService(message: "Connected!", color: Colors.green).snackBar();

                          await ScaffoldMessenger.of(context).showSnackBar(_sb);

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context){
                                return DashboardScaffold(connection: connection);
                              })
                          );

                        } else {
                          print('Discovery -> no device selected');

                          SnackBar _sb = SnackBarService(message: "No Device Selected!", color: Colors.red).snackBar();

                          ScaffoldMessenger.of(context).showSnackBar(_sb);
                        }

                      },
                      child: const Text('Discover Devices')
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: ElevatedButton(
                  child: const Text('Paired Devices'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                  onPressed: () async {

                    final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {

                      try {
                        print('Connect -> selected ' + selectedDevice.address);
                        globals.isConnected = true;
                        ConnectionProvider().setConnection(true);
                        globals.selectedDevice = selectedDevice;
                        BluetoothConnection connection = await BluetoothConnection.toAddress(selectedDevice.address);

                        //im paired message
                        connection!.output!.add(ascii.encode(ImPaired().createPacket()));
                        await connection!.output.allSent;

                        Provider.of<ConnectionProvider>(context,listen: false).setConnection(true);

                        SnackBar _sb = SnackBarService(message: "Connected!", color: Colors.green).snackBar();

                        await ScaffoldMessenger.of(context).showSnackBar(_sb);

                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context){
                            return DashboardScaffold(connection: connection);
                          })
                        );

                      }
                      catch(e){

                        print("Error pairing: paired devices: "+e.toString());
                        globals.isConnected = false;
                        ConnectionProvider().setConnection(false);

                        SnackBar _sb = SnackBarService(message: "Error Pairing", color: Colors.red).snackBar();

                        ScaffoldMessenger.of(context).showSnackBar(_sb);
                      }
                    } else {
                      print('Connect -> no device selected');

                      SnackBar _sb = SnackBarService(message: "No Device Selected!", color: Colors.red).snackBar();

                      ScaffoldMessenger.of(context).showSnackBar(_sb);
                    }


                  },
                ),
                ),
              ],
            ),

            /*
            ListTile(
              title: ElevatedButton(
                child: const Text('send'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                onPressed: () async {


                  //final BluetoothConnection? connection = globals.connection;

                  /*
                  globals.connection!.input!.listen((data) {
                    print('Data incoming!!!!!!!!!!!!!!!: ${ascii.decode(data)}');
                  });

                   */



                  globals.connection!.output.add(Uint8List.fromList(utf8.encode("hahaha")));

                  await globals.connection!.output!.allSent;



                },
              ),
            ),

             */
          ],
        ),
      ),
    );
  }



  AppBar _appBar(){

    return AppBar(
      title: const Text("Bluetooth"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          print("exit");
          SystemNavigator.pop();
        },
      ),
    );
  }
}
