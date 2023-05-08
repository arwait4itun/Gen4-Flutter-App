import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/enums.dart';
import 'package:flyer/message/statusMessage.dart';
import 'package:provider/provider.dart';

import '../services/provider_service.dart';

class PhoneStatusPageUI extends StatefulWidget {

  Stream<Uint8List>? statusStream;

  PhoneStatusPageUI({required this.statusStream});

  @override
  _PhoneStatusPageUIState createState() => _PhoneStatusPageUIState();
}

class _PhoneStatusPageUIState extends State<PhoneStatusPageUI> {

  String _substate = "pause";

  String _errorSource = "";
  String _errorAction = "";
  String _errorInformation = "";

  String _layer = "";

  String _pauseReason = "UHFSLIUEGAHF";



  bool hasError = false;
  bool running = false;
  bool homing = false;
  bool pause = true;

  double _liftLeft = 0;
  double _liftRight = 0;


  Stream<Uint8List>? statusStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    statusStream = widget.statusStream;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    statusStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Uint8List>(
        stream: statusStream,
        builder: (context, snapshot) {

          if(snapshot.hasData){
            var data = snapshot.data;
            String _d = utf8.decode(data!);
            print("\nStatus: data: "+_d);
            print(snapshot.data);


            try{

              hasError = false;
              running = false;
              homing = false;

              Map<String,String> _statusResponse = StatusMessage().decode(_d);
              print("HERE!!!!!!!!!!!!!!: $_statusResponse");

              _substate = _statusResponse["substate"]!;

              switch(_substate){

                case "run":
                  running = true;
                  break;
                case "homing":
                  homing = true;
                  break;
                case "error":
                  hasError = true;
                  break;
                case "pause":
                  pause = true;
                  break;
                default:
                  break;
              }

              if(running || homing){

                //disable settings and diagnostic pages when running to prevent errors

                if( Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed){
                  Provider.of<ConnectionProvider>(context,listen: false).setSettingsChangeAllowed(false);
                }

              }
              else{

                if(!Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed){
                  Provider.of<ConnectionProvider>(context,listen: false).setSettingsChangeAllowed(true);
                }

              }

              if(_statusResponse.containsKey("leftLiftDistance") && _statusResponse.containsKey("rightLiftDistance")){
                _liftLeft = double.parse(_statusResponse["leftLiftDistance"]!);
                _liftRight = double.parse(_statusResponse["rightLiftDistance"]!);
              }

              if(hasError){

                _errorInformation = _statusResponse["errorInformation"]!;
                _errorSource = _statusResponse["errorSource"]!;
                _errorAction = _statusResponse["errorAction"]!;

              }
              else if(running){
                _layer = _statusResponse["layer"]!;
              }
              else if(pause){
                _pauseReason = _statusResponse["pauseReason"]!;
              }
            }

            catch(e){
              print("status1: ${e.toString()}");
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _mainUI(),
          );
        }
    );

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
      return Container();
    }
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
                ),
              ),
            ),
          ],
        ),

        _liftAnimation(_liftLeft,_liftRight),

      ],
    );
  }

  Widget _homingUI(){
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

        _liftAnimation(_liftLeft,_liftRight),

      ],
    );
  }

  Widget _pauseUI(){
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
                  fontSize: 14,
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
                _errorInformation,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
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
        Text(
            'title'
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
                  Icon(
                    Icons.arrow_downward_sharp,
                  ),
                  Text(
                    "L: $left",
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_sharp,
                  ),
                  Text(
                    "R: $right",

                  )
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }
}
