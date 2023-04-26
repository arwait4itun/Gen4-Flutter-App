import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/request_settings.dart';
import 'package:flyer/message/settingsMessage.dart';
import 'package:flyer/screens/pid_page.dart';
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import '../services/snackbar_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController _spindleSpeed = new TextEditingController();
  final TextEditingController _draft = new TextEditingController();
  final TextEditingController _twistPerInch = new TextEditingController();
  final TextEditingController _RTF = new TextEditingController();
  final TextEditingController _lengthLimit = new TextEditingController();
  final TextEditingController _maxHeightOfContent = new TextEditingController();
  final TextEditingController _rovingWidth = new TextEditingController();
  final TextEditingController _deltaBobbinDia = new TextEditingController();
  final TextEditingController _bareBobbinDia = new TextEditingController();
  final TextEditingController _rampupTime = new TextEditingController();
  final TextEditingController _rampdownTime = new TextEditingController();
  final TextEditingController _changeLayerTime = new TextEditingController();

  var settingsListenController = StreamController<Uint8List>.broadcast();
  BluetoothConnection? connection = null;

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  bool isConnected = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    BluetoothConnection.toAddress(globals.selectedDevice!.address).then((_connection) {
      print('Connected to the device');

      connection = _connection;
      isConnected = true;


      connection!.input!.listen(_onDataReceived).onDone(() {});

      setState(() {});
    }).catchError((error) {
      print('Settings: Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    connection?.dispose();
    connection = null;
    isConnected = false;
    _data.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    bool _pidEnabled = Provider.of<ConnectionProvider>(context).PIDEnabled;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 10,top: 7,bottom: 7, right: 7),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width,

            child: Center(
              child: Text("SETTINGS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
            ),
          ),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(0.5),
              1: FractionColumnWidth(0.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[

              _customRow("Spindle Speed(RPM)", _spindleSpeed, isFloat: false,defaultValue: "650"),
              _customRow("Draft", _draft,defaultValue: "8.8"),
              _customRow("Twist Per Inch", _twistPerInch,defaultValue: "1.4"),
              _customRow("RTF", _RTF,defaultValue: "1"),
              _customRow("Length Limit (mtrs)", _lengthLimit, isFloat: false,defaultValue: "1000"),
              _customRow("Max Height of Content", _maxHeightOfContent, isFloat: false,defaultValue: "280"),
              _customRow("Roving Width", _rovingWidth, defaultValue: "1.2"),
              _customRow("Delta Bobbin-dia", _deltaBobbinDia,defaultValue: "1.1"),
              _customRow("Bare Bobbin-dia", _bareBobbinDia, isFloat: false, defaultValue: "48"),
              _customRow("Rampup Time", _rampupTime, isFloat: false,defaultValue: "12"),
              _customRow("Rampdown Time", _rampdownTime, isFloat: false, defaultValue: "12"),
              _customRow("Change Layer Time (ms)", _changeLayerTime, isFloat: false, defaultValue: "800"),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                IconButton(
                    onPressed: () async {
                      _requestSettings();
                    },
                    icon: Icon(Icons.input, color: Theme.of(context).primaryColor,)
                ),
                IconButton(
                  onPressed: (){

                    //hard coded change

                    _spindleSpeed.text =  "650";
                    _draft.text =  "8.8";
                    _twistPerInch.text = "1.4";
                    _RTF.text = "1";
                    _lengthLimit.text="1000";
                    _maxHeightOfContent.text = "280";
                    _rovingWidth.text = "1.2";
                    _deltaBobbinDia.text = "1.1";
                    _bareBobbinDia.text = "48";
                    _rampupTime.text= "12";
                    _rampdownTime.text = "12";
                    _changeLayerTime.text = "800";
                  },
                  icon: Icon(Icons.build,color: Theme.of(context).primaryColor,),
                ),
                IconButton(
                  onPressed: () async {

                    String _valid = isValidForm();

                    if(_valid == "valid"){

                      SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, lengthLimit: _lengthLimit.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);

                      String _msg = _sm.createPacket();


                      connection!.output.add(Uint8List.fromList(utf8.encode(_msg)));

                      await connection!.output!.allSent.then((v) {});

                      await Future.delayed(Duration(milliseconds: 500)); //wait for acknowledgement



                      if(newDataReceived){
                        String _d = _data.last;
                        print(_d);
                        if(_d == Acknowledgement().createPacket()){
                          //no eeprom error , acknowledge

                          SnackBar _sb = SnackBarService(message: "Settings Saved", color: Colors.green).snackBar();

                          ScaffoldMessenger.of(context).showSnackBar(_sb);
                        }
                        else{
                          //failed acknowledgement

                          SnackBar _sb = SnackBarService(message: "Settings Not Saved", color: Colors.red).snackBar();

                          ScaffoldMessenger.of(context).showSnackBar(_sb);
                        }

                        newDataReceived = false;
                        setState(() {

                        });

                      }

                    }
                    else{
                      SnackBar _sb = SnackBarService(message: _valid, color: Colors.red).snackBar();

                      ScaffoldMessenger.of(context).showSnackBar(_sb);
                    }

                  },
                  icon: Icon(Icons.save,color: Theme.of(context).primaryColor,),
                ),
              ],
            ),
          ),
        ],
      ),
    );


  }

  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      setState(() {
        _data.add(_d);
        newDataReceived = true;
      });
    }
    catch (e){

      print("Settings: onDataReceived: ${e.toString()}");
    }
  }

  TableRow _customRow(String label, TextEditingController controller, {bool isFloat=true, String defaultValue="0"}){

    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 5),
            child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child:
          Container(
            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.01,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            child: TextField(
              controller: controller,
              inputFormatters:  <TextInputFormatter>[
              // for below version 2 use this

              isFloat?
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              : FilteringTextInputFormatter.allow(RegExp(r'^\d+')),

              FilteringTextInputFormatter.deny('-'),
              // for version 2 and greater youcan also use this

              ],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: defaultValue,
              ),
            ),
          ),
        ),

      ],
    );
  }

  String isValidForm(){

    //checks if the entered values in the form are valid
    //returns appropriate error message if form is invalid
    //returns valid! if form is valid

    String errorMessage = "valid";

    if(_spindleSpeed.text.trim() == "" ){
      errorMessage = "Spindle Speed is Empty!";
      return errorMessage;
    }
    else{

      List range = globals.settingsLimits["spindleSpeed"]!;
      double val = double.parse(_spindleSpeed.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Spindle Speed values should be within $range";
        return errorMessage;
      }
    }

    if(_draft.text.trim() == "" ){
      errorMessage = "Draft is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["draft"]!;
      double val = double.parse(_draft.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Draft values should be within $range";
        return errorMessage;
      }
    }

    if(_twistPerInch.text.trim() == "" ){
      errorMessage = "Twist per Inch is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["twistPerInch"]!;
      double val = double.parse(_twistPerInch.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Twist per Inch values should be within $range";
        return errorMessage;
      }
    }

    if(_RTF.text.trim() == "" ){
      errorMessage = "RTF is Empty!";
      return errorMessage;
    }
    else{

      List range = globals.settingsLimits["RTF"]!;
      double val = double.parse(_RTF.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "RTF values should be within $range";
        return errorMessage;
      }
    }

    if(_lengthLimit.text.trim() == "" ){
      errorMessage = "Length Limit is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["lengthLimit"]!;
      double val = double.parse(_lengthLimit.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Length Limit values should be within $range";
        return errorMessage;
      }
    }

    if(_maxHeightOfContent.text.trim() == "" ){
      errorMessage = "Max Height is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["maxHeightOfContent"]!;
      double val = double.parse(_maxHeightOfContent.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Max Height values should be within $range";
        return errorMessage;
      }
    }

    if(_rovingWidth.text.trim() == "" ){
      errorMessage = "Roving Width is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["rovingWidth"]!;
      double val = double.parse(_rovingWidth.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Roving Width values should be within $range";
        return errorMessage;
      }

    }

    if(_deltaBobbinDia.text.trim() == "" ){
      errorMessage = "Delta Bobbin Dia is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["deltaBobbinDia"]!;
      double val = double.parse(_deltaBobbinDia.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Delta Bobbin Dia values should be within $range";
        return errorMessage;
      }
    }

    if(_bareBobbinDia.text.trim() == "" ){
      errorMessage = "Bare Bobbin Dia is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["bareBobbinDia"]!;
      double val = double.parse(_bareBobbinDia.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Bare Bobbin Dia values should be within $range";
        return errorMessage;
      }
    }

    if(_rampupTime.text.trim() == "" ){
      errorMessage = "Rampup Time is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["rampupTime"]!;
      double val = double.parse(_rampupTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Rampup Time values should be within $range";
        return errorMessage;
      }
    }

    if(_rampdownTime.text.trim() == "" ){
      errorMessage = "Rampdown Time is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["rampdownTime"]!;
      double val = double.parse(_rampdownTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Rampdown Time values should be within $range";
        return errorMessage;
      }
    }

    if(_changeLayerTime.text.trim() == "" ){
      errorMessage = "Change Layer Time is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["changeLayerTime"]!;
      double val = double.parse(_changeLayerTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Rampdown Time values should be within $range";
        return errorMessage;
      }
    }

    return errorMessage;
  }


  void _requestSettings() async {
    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(RequestSettings().createPacket())));

      await connection!.output!.allSent;

      await Future.delayed(Duration(milliseconds: 500)); //wait for acknowlegement

      SnackBar _sb = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();

      //ScaffoldMessenger.of(context).showSnackBar(_sb);


      if(newDataReceived){
        String _d = _data.last; //remember to make newDataReceived = false;

        //print("here: $_d");
        Map<String, double> settings = RequestSettings().decode(_d);

        if (settings.isEmpty) {
          throw FormatException("Settings Returned Empty");
        }

        _spindleSpeed.text = settings["spindleSpeed"]!.toInt().toString();
        _draft.text = settings["draft"].toString();
        _twistPerInch.text = settings["twistPerInch"].toString();
        _RTF.text = settings["RTF"].toString();
        _lengthLimit.text = settings["lengthLimit"]!.toInt().toString();
        _maxHeightOfContent.text = settings["maxHeightOfContent"]!.toInt().toString();
        _rovingWidth.text = settings["rovingWidth"].toString();
        _deltaBobbinDia.text = settings["deltaBobbinDia"].toString();
        _bareBobbinDia.text = settings["bareBobbinDia"]!.toInt().toString();
        _rampupTime.text = settings["rampupTime"]!.toInt().toString();
        _rampdownTime.text = settings["rampdownTime"]!.toInt().toString();
        _changeLayerTime.text = settings["changeLayerTime"]!.toInt().toString();

        newDataReceived = false;
        setState(() {

        });
      }

      _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();

      ScaffoldMessenger.of(context).showSnackBar(_sb);
    }
    catch(e){
      print("Settings!: ${e.toString()}");

      //Remember to change this error suppression
      if(e.toString() !=  "Bad state: Stream has already been listened to."){


        SnackBar _sb = SnackBarService(message: "Error in Receiving Settings", color: Colors.red).snackBar();

        ScaffoldMessenger.of(context).showSnackBar(_sb);

      }
      else{
        SnackBar _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();

        ScaffoldMessenger.of(context).showSnackBar(_sb);
      }

    }

  }
}




