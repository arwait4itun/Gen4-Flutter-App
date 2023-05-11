import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/statusMessage.dart';
import 'package:flyer/screens/running_carousel.dart';
import 'package:provider/provider.dart';

import '../services/provider_service.dart';

class PhoneStatusPageUI extends StatefulWidget {


  BluetoothConnection connection;
  Stream<Uint8List> statusStream;

  PhoneStatusPageUI({required this.connection,required this.statusStream});

  @override
  _PhoneStatusPageUIState createState() => _PhoneStatusPageUIState();
}

class _PhoneStatusPageUIState extends State<PhoneStatusPageUI> {

  String _substate = "";

  String _errorSource = "";
  String _errorAction = "";
  String _errorInformation = "";
  String _errorCode = "";

  String _layer = "";

  String _pauseReason = "";



  bool hasError = false;
  bool running = false;
  bool homing = false;
  bool pause = false;
  bool idle = false;

  double _liftLeft = 2;
  double _liftRight = 0;


  late Stream<Uint8List> statusStream;
  late BluetoothConnection connection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    statusStream = widget.statusStream;
    connection = widget.connection;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    try{
      if (running || homing || pause || hasError) {
        //disable settings and diagnostic pages when running to prevent errors

        if (Provider
            .of<ConnectionProvider>(context, listen: false)
            .settingsChangeAllowed) {
          Provider.of<ConnectionProvider>(context, listen: false)
              .setSettingsChangeAllowed(false);
        }
      }
      else {
        if (!Provider
            .of<ConnectionProvider>(context, listen: false)
            .settingsChangeAllowed) {
          try {
            Provider.of<ConnectionProvider>(
                context, listen: false)
                .setSettingsChangeAllowed(true);
          }
          catch (e) {
            print("Status: ${e.toString()}");
          }
        }
      }
    }
    catch(e){
      print("Status: Changing state error: ${e.toString()}");
    }

    if(connection.isConnected){

      try {
        return StreamBuilder<Uint8List>(
            stream: statusStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                String _d = utf8.decode(data!);
                print("\nStatus: data: " + _d);
                print(snapshot.data);


                try {
                  print("here status!!!!!: $_d");
                  Map<String, String> _statusResponse = StatusMessage().decode(
                      _d);
                  print("HERE!!!!!!!!!!!!!!: $_statusResponse");

                  if (!_statusResponse.isEmpty) {
                    _substate = _statusResponse["substate"]!;

                    switch (_substate) {
                      case "running":
                        hasError = false;
                        running = true;
                        homing = false;
                        pause = false;
                        idle = false;
                        break;
                      case "homing":
                        hasError = false;
                        running = false;
                        homing = true;
                        pause = false;
                        idle = false;
                        break;
                      case "error":
                        hasError = true;
                        running = false;
                        homing = false;
                        pause = false;
                        idle = false;
                        break;
                      case "pause":
                        hasError = false;
                        running = false;
                        homing = false;
                        pause = true;
                        idle = false;
                        break;
                      default:
                        hasError = false;
                        running = false;
                        homing = false;
                        pause = false;
                        idle = true;
                        break;
                    }



                    if (_statusResponse.containsKey("leftLiftDistance") &&
                        _statusResponse.containsKey("rightLiftDistance")) {
                      _liftLeft =
                          double.parse(_statusResponse["leftLiftDistance"]!);
                      _liftRight =
                          double.parse(_statusResponse["rightLiftDistance"]!);
                    }

                    if (hasError) {
                      _errorInformation = _statusResponse["errorReason"]!;
                      _errorCode = _statusResponse["errorCode"]!;
                      _errorSource = _statusResponse["errorSource"]!;
                      _errorAction = "Action";
                    }
                    else if (running) {
                      _layer = double.parse(_statusResponse["layers"]!)
                          .toInt()
                          .toString();
                    }
                    else if (pause) {
                      _pauseReason = _statusResponse["pauseReason"]!;
                    }
                  }
                }

                catch (e) {
                  print("status1: ${e.toString()}");
                }
              }

              return Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: _mainUI(),
              );
            }
        );
      }
      catch(e){
        return _placeHolder();
      }
    }
    else{
      return _checkConnection();
    }

  }


  Widget _mainUI(){
    //decides which ui should be used based on substate

    if(hasError){
      return _errorUI();
    }
    else if(running){
      return _runUI();
    }
    else if(homing){
      return _homingUI();
    }
    else if(pause){
      return _pauseUI();
    }
    else{
      //idle
      return _placeHolder();
    }
  }

  Widget _placeHolder(){
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width*0.9,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _substate.toUpperCase()??"--",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _runUI(){

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Layer",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _layer,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        _liftAnimation(_liftLeft,_liftRight),

        RunningCarousel(connection: connection, multistream: statusStream),
      ],
    );
  }

  Widget _homingUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width*0.9,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _substate.toUpperCase(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        _liftAnimation(_liftLeft,_liftRight),

      ],
    );
  }

  Widget _pauseUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        SizedBox(
          height: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 50,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reason For Pause",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.08,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _pauseReason,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _errorUI(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _substate.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Information",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                "$_errorInformation (${_errorCode})",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Source",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _errorSource,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Error Action",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _errorAction,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )


      ],
    );
  }

  Widget _liftAnimation(double left, double right){

    //dir = +ve if l > r
    //dir = -ve if r > l
    //dir = 0 if r==l

    double direction = (left-right)/4;



    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.01,
        ),

        Text(
            'Δ (mm) = ${(left-right).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            '(Δ = L - R)',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.04,
        ),

        Container(
          height: MediaQuery.of(context).size.height*0.05,
          width: MediaQuery.of(context).size.width*0.95,
          padding: EdgeInsets.all(10),


          child: Transform.rotate(

            angle: (direction)*math.pi/40,
            child: Container(
              height: MediaQuery.of(context).size.height*0.05,
              width: MediaQuery.of(context).size.width*0.95,
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),

        Container(
          width: MediaQuery.of(context).size.width*0.95,
          height: MediaQuery.of(context).size.height*0.08,
          padding: EdgeInsets.all(7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "L",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    left.toStringAsFixed(2),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "R",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    right.toStringAsFixed(2),
                  )
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Container _checkConnection(){

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Please Reconnect...", style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 15),),
          ],
        ),
      ),
    );
  }
}
