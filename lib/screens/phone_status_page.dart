import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/enums.dart';
import 'package:flyer/message/statusMessage.dart';

class PhoneStatusPageUI extends StatefulWidget {

  Stream<Uint8List>? statusStream;

  PhoneStatusPageUI({required this.statusStream});

  @override
  _PhoneStatusPageUIState createState() => _PhoneStatusPageUIState();
}

class _PhoneStatusPageUIState extends State<PhoneStatusPageUI> {

  String _substate = "";

  String _errorValue = "None";
  String _errorInformation = "None";


  bool hasError = false;
  bool running = false;
  bool homing = false;


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
                default:
                  break;
              }

            }
            catch(e){
              print("status1: ${e.toString()}");
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: hasError? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceAround,
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


                running || homing? _liftAnimation(0.1,0.1): Container(),


                hasError?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Error Value",
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
                        _errorValue,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
                :Container(),

                hasError?
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
                      height: MediaQuery.of(context).size.height*0.15,
                      width: MediaQuery.of(context).size.width*0.9,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        _errorInformation,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
                    :Container(),
              ],
            ),
          );
        }
    );

  }

  Widget _liftAnimation(double left, double right){

    //dir = +ve if l > r
    //dir = -ve if r > l
    //dir = 0 if r==l

    double direction;

    if(left>right){
      direction = 1;
    }
    else if(right > left){
      direction = -1;
    }
    else{
      direction = 0;
    }

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

            angle: direction*math.pi/40,
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
