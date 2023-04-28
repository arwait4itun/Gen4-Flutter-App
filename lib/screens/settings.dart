import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/request_settings.dart';
import 'package:flyer/message/settingsMessage.dart';
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import '../services/snackbar_service.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController _spindleSpeed = TextEditingController();
  final TextEditingController _draft = TextEditingController();
  final TextEditingController _twistPerInch = TextEditingController();
  final TextEditingController _RTF = TextEditingController();
  final TextEditingController _lengthLimit = TextEditingController();
  final TextEditingController _maxHeightOfContent = TextEditingController();
  final TextEditingController _rovingWidth = TextEditingController();
  final TextEditingController _deltaBobbinDia = TextEditingController();
  final TextEditingController _bareBobbinDia = TextEditingController();
  final TextEditingController _rampupTime = TextEditingController();
  final TextEditingController _rampdownTime = TextEditingController();
  final TextEditingController _changeLayerTime = TextEditingController();

  BluetoothConnection? connection = null;

  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  bool isConnected = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    if(!Provider.of<ConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<ConnectionProvider>(context,listen: false).settings;

      _spindleSpeed.text = _s["spindleSpeed"].toString();
      _draft.text =  _s["draft"].toString();
      _twistPerInch.text = _s["twistPerInch"].toString();
      _RTF.text = _s["RTF"].toString();
      _lengthLimit.text=_s["lengthLimit"].toString();
      _maxHeightOfContent.text  = _s["maxHeightOfContent"].toString();
      _rovingWidth.text = _s["rovingWidth"].toString();
      _deltaBobbinDia.text = _s["deltaBobbinDia"].toString();
      _bareBobbinDia.text = _s["bareBobbinDia"].toString();
      _rampupTime.text= _s["rampupTime"].toString();
      _rampdownTime.text = _s["rampdownTime"].toString();
      _changeLayerTime.text = _s["changeLayerTime"].toString();

    }


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
    double screenHt  = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    bool _enabled = Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left:screenHt *0.02,top: screenHt*0.05 ,bottom: screenHt*0.01, right: screenWidth*0.02),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(0.55),
              1: FractionColumnWidth(0.35),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              _customRow("Spindle Speed (RPM)", _spindleSpeed, isFloat: false,defaultValue: "",enabled: _enabled),
              _customRow("Draft", _draft,defaultValue: "",enabled: _enabled),
              _customRow("Twists Per Inch", _twistPerInch,defaultValue: "",enabled: _enabled),
              _customRow("Initial RTF", _RTF,defaultValue: "",enabled: _enabled),
              _customRow("Length Limit (mtrs)", _lengthLimit, isFloat: false,defaultValue: "",enabled: _enabled),
              _customRow("Max Content Ht (mm)", _maxHeightOfContent, isFloat: false,defaultValue: "",enabled: _enabled),
              _customRow("Roving Width", _rovingWidth, defaultValue: "",enabled: _enabled),
              _customRow("Delta Bobbin-dia (mm)", _deltaBobbinDia,defaultValue: "",enabled: _enabled),
              _customRow("Bare Bobbin-dia (mm)", _bareBobbinDia, isFloat: false, defaultValue: "",enabled: _enabled),
              _customRow("Ramp Up Time (s)", _rampupTime, isFloat: false,defaultValue: "",enabled: _enabled),
              _customRow("Ramp Down Time (s)", _rampdownTime, isFloat: false, defaultValue: "",enabled: _enabled),
              _customRow("Change Layer Time (ms)", _changeLayerTime, isFloat: false, defaultValue: "",enabled: _enabled),
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

                    SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, lengthLimit: _lengthLimit.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);

                    ConnectionProvider().setSettings(_sm.toMap());
                    Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                  },
                  icon: Icon(Icons.settings_backup_restore,color: Theme.of(context).primaryColor,),
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


  TableRow _customRow(String label, TextEditingController controller, {bool isFloat=true, String defaultValue="0", bool enabled=true}){
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20),
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
            color: enabled? Colors.transparent : Colors.grey.shade400,
            child: TextField(
              enabled: enabled,
              controller: controller,
              inputFormatters:  <TextInputFormatter>[
              // for below version 2 use this

              isFloat?
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              : FilteringTextInputFormatter.allow(RegExp(r'^\d+')),

              FilteringTextInputFormatter.deny('-'),
              // for version 2 and greater you can also use this

              ],
              keyboardType: TextInputType.phone,

              decoration: InputDecoration(
                border: OutlineInputBorder(),
                //hintText: defaultValue,
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
        errorMessage = "Ramp Up Time values should be within $range";
        return errorMessage;
      }
    }

    if(_rampdownTime.text.trim() == "" ){
      errorMessage = "Ramp Down Time is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["rampdownTime"]!;
      double val = double.parse(_rampdownTime.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Ramp Down Time values should be within $range";
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
        errorMessage = "Change Layer values should be within $range";
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
      /*SnackBar _sb = SnackBarService(
          message: "Sent Request for Settings!", color: Colors.green)
          .snackBar();*/
      //ScaffoldMessenger.of(context).showSnackBar(_sb);


      if(newDataReceived){
        String _d = _data.last; //remember to make newDataReceived = false;

        Map<String, double> settings = RequestSettings().decode(_d);
        //settings = RequestSettings().decode(_d);


        if(settings.isEmpty){
          throw const FormatException("Settings Returned Empty");
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


        SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, lengthLimit: _lengthLimit.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);
        ConnectionProvider().setSettings(_sm.toMap());
        Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());


        setState(() {

        });
      }
      SnackBar _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
      ScaffoldMessenger.of(context).showSnackBar(_sb);
    }
    catch(e){
      print("Settings!: ${e.toString()}");
      //Remember to change this error suppression
      if(e.toString() !=  "Bad state: Stream has already been listened to."){
        SnackBar sb = SnackBarService(message: "Error in Receiving Settings", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }
      else{
        SnackBar sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(sb);
        setState(() {

        });
      }

    }

  }
}




