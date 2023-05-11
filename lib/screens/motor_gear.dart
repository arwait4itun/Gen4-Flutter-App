import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/gearBoxMessage.dart';
import 'package:flyer/screens/status.dart';
import 'package:flyer/services/snackbar_service.dart';
import 'package:provider/provider.dart';
import '../services/provider_service.dart';

import 'package:rxdart/rxdart.dart';

class MotorGearPageUI extends StatefulWidget {

  BluetoothConnection connection;
  Stream<Uint8List> stream;

  MotorGearPageUI({required this.connection, required this.stream});

  @override
  _MotorGearPageUIState createState() => _MotorGearPageUIState();
}

class _MotorGearPageUIState extends State<MotorGearPageUI> {

  bool start = true;
  bool stop = false;
  bool left = false;
  bool right = false;

  late bool firstTimeFlag;

  String? leftData, rightData;



  Map<String,String> _ldata = new Map<String,String>();

  Map<String,String> _rdata = new Map<String,String>();

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> stream;


  @override
  void initState() {
    // TODO: implement initState

    firstTimeFlag = true;

    connection = widget.connection;
    stream = widget.stream;


    try{
      stream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
    }

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _data.clear();
    _rdata.clear();
    _ldata.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    start = (Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed && Provider.of<ConnectionProvider>(context,listen: false).hasGBStarted);

    print("$start");

    if(start && firstTimeFlag){

      stop = false;
      left = false;
      right = false;

      firstTimeFlag = false;
    }
    else if(start && !firstTimeFlag){

      stop = false;
      left = true;
      right = true;
      firstTimeFlag = false;
    }
    else{

      left = false;
      right = false;
      stop = true;
      firstTimeFlag = false;
    }


    try{
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Container(
              height: MediaQuery.of(context).size.height*0.05,

              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 5),
              child: Text(
                "Gear Box Calibration",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30),

            _leftAndRight(),

            SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [


                Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed? _customButton("START", start, _start): Container(),
                Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed? _customButton("STOP", stop, _stop): Container(),
              ],
            ),
          ],
        ),
      );
    }
    catch(e){

      print("GB: BUILD: ${e.toString()}");
      return Container(

          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,

          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                    height: MediaQuery.of(context).size.height*0.05,

                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      "Gear Box Calibration",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ]
          ),
      );
    }
  }

  Widget _customRow(String label, String val, bool enabled,VoidCallback function){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Container(

          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(left: 5),

          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        Container(

          height: MediaQuery.of(context).size.height*0.05,
          width: MediaQuery.of(context).size.width*0.4,
          padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),

          child: Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        enabled?
        IconButton(
            onPressed: (){
              function();
            },
            color: Theme.of(context).highlightColor,
            icon: Icon(Icons.arrow_forward,)
        )
        :IconButton(
            onPressed: (){
              print("gb: disabled");
            },
            color: Colors.grey,
            icon: Icon(Icons.arrow_forward,)
        ),
      ],
    );

  }

  Widget _customButton(String label, bool enabled, VoidCallback function){

    if(enabled){
      return Container(
        height: MediaQuery.of(context).size.height*0.05,
        width: MediaQuery.of(context).size.width*0.40,
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue,Colors.lightGreen]
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              function();
            },
            child: Text(label,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),

          ),
        ),
      );
    }
    else{
      return Container(
        height: MediaQuery.of(context).size.height*0.05,
        width: MediaQuery.of(context).size.width*0.40,
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey,
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: (){
              print("gb: btns: disabled");
            },
            child: Text(label,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),

          ),
        ),
      );
    }
  }


  Widget _leftAndRight(){

    if(start==true){
      //start state not enabled

      print(_ldata.length);
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          _customRow("Left ", _ldata.isEmpty? leftData??"-":_ldata["data"]??"-", left, _sendLeft),

          SizedBox(height: 20,),
          _customRow("Right", _rdata.isEmpty? rightData??"-": _rdata["data"]??"-", right, _sendRight),
        ],
      );
    }
    else{

      return StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {


            if(snapshot.hasData){

              var data = snapshot.data;
              String _d = utf8.decode(data!);
              print("\nStatus: data: "+_d);
              print(snapshot.data);

              try{
                var _gbStatus = GearBoxMessage().decode(_d);


                leftData = _gbStatus["start"];
                rightData = _gbStatus["stop"];

                if(leftData!=null){
                  _ldata["data"] = leftData!;
                  _ldata["data"] = leftData!;
                }

                if(rightData!=null){
                  _rdata["data"] = rightData!;
                }

              }
              catch(e){
                print("GB: L&R: ${e.toString()}");
              }

            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                _customRow("Left ", leftData??"-", left, _sendLeft),

                SizedBox(height: 20,),
                _customRow("Right", rightData??"-", right, _sendRight),
              ],
            );
          }
      );
    }
  }


  void _sendLeft() async {


    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().left())));
      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 500));

      if(newDataReceived){

        String _d = _data.last;

        if (_d == null || _d == "") {
          SnackBar _sb = SnackBarService(
              message: "Invalid Packet", color: Colors.red).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);

          print("GB: Send LEFT: Invalid Packet");

          throw FormatException("GB: Send LEFT: Invalid Packet");
        }

        if (_d == Acknowledgement().createPacket()) {
          SnackBar _sb = SnackBarService(
              message: "Saved Left Data", color: Colors.green).snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);
        }
        else {
          SnackBar _sb = SnackBarService(
              message: "Failed To Save Left Data", color: Colors.red)
              .snackBar();
          ScaffoldMessenger.of(context).showSnackBar(_sb);

          print("GB: Send Left: Failed");

          throw FormatException("GB: Send Left: Failed");
        }
      }
    }
    catch(e){

      SnackBar _sb = SnackBarService(message: "Failed To Save Left Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);

      print("GB: SEND LEFT ${e.toString()}");
    }


  }

  void _sendRight() async {

    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().right())));
      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 500));



        if(newDataReceived){

          String _d = _data.last;

          if(_d==null || _d==""){

            SnackBar _sb = SnackBarService(message: "Invalid Packet", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("GB: Send Right: Invalid Packet");

            throw FormatException("GB: Send right: Invalid Packet");

          }

          else if(_d==Acknowledgement().createPacket()){
            SnackBar _sb = SnackBarService(message: "Saved Right Data", color: Colors.green).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);
          }
          else{
            SnackBar _sb = SnackBarService(message: "Failed To Save Right Data", color: Colors.red).snackBar();
            ScaffoldMessenger.of(context).showSnackBar(_sb);

            print("GB: Send Right: Failed");

            throw FormatException("GB: Send Right: Failed");

          }

          newDataReceived = false;
          setState(() {});
        }


    }
    catch(e){
      SnackBar _sb = SnackBarService(message: "Failed To Save Right Data", color: Colors.red).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
      print("GB: SEND RIGHT ${e.toString()}");
    }

  }

  void _start() async {

    connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().start())));
    await connection!.output!.allSent;
    await Future.delayed(Duration(milliseconds: 250));


    Provider.of<ConnectionProvider>(context,listen: false).setGBStart(false);

    setState(() {

    });
  }

  void _stop() async {

    connection!.output.add(Uint8List.fromList(utf8.encode(GearBoxMessage().stop())));
    await connection!.output!.allSent;
    await Future.delayed(Duration(milliseconds: 100));


    Provider.of<ConnectionProvider>(context,listen: false).setGBStart(true);

    setState(() {

    });
  }

  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

        //Allow if:
        //request settins data
        // or if acknowledgement (error or no error )

        _data.add(_d);
        newDataReceived = true;
      }

      //else ignore data

    }
    catch (e){

      print("Settings: onDataReceived: ${e.toString()}");
    }
  }

}
