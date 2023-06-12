import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flyer/globals.dart' as globals;
import 'package:flyer/message/acknowledgement.dart';
import 'package:flyer/message/request_settings.dart';
import 'package:flyer/message/settingsMessage.dart';
import 'package:flyer/screens/FlyerScreens/popup_calc.dart';
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import '../../services/snackbar_service.dart';


class FlyerSettingsPage extends StatefulWidget {

  BluetoothConnection connection;

  Stream<Uint8List> settingsStream;

  FlyerSettingsPage({required this.connection, required this.settingsStream});

  @override
  _FlyerSettingsPageState createState() => _FlyerSettingsPageState();
}

class _FlyerSettingsPageState extends State<FlyerSettingsPage> {

  final TextEditingController _spindleSpeed = TextEditingController();
  final TextEditingController _draft = TextEditingController();
  final TextEditingController _twistPerInch = TextEditingController();
  final TextEditingController _RTF = TextEditingController();
  final TextEditingController _layers = TextEditingController();
  final TextEditingController _maxHeightOfContent = TextEditingController();
  final TextEditingController _rovingWidth = TextEditingController();
  final TextEditingController _deltaBobbinDia = TextEditingController();
  final TextEditingController _bareBobbinDia = TextEditingController();
  final TextEditingController _rampupTime = TextEditingController();
  final TextEditingController _rampdownTime = TextEditingController();
  final TextEditingController _changeLayerTime = TextEditingController();


  List<String> _data = List<String>.empty(growable: true);
  bool newDataReceived = false;

  late BluetoothConnection connection;
  late Stream<Uint8List> settingsStream;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try{
      connection = widget.connection;
      settingsStream = widget.settingsStream;
    }
    catch(e){
      print("Settings: Connection init: ${e.toString()}");
    }


    if(!Provider.of<ConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<ConnectionProvider>(context,listen: false).settings;

      _spindleSpeed.text = _s["spindleSpeed"].toString();
      _draft.text =  _s["draft"].toString();
      _twistPerInch.text = _s["twistPerInch"].toString();
      _RTF.text = _s["RTF"].toString();
      _layers.text=_s["layers"].toString();
      _maxHeightOfContent.text  = _s["maxHeightOfContent"].toString();
      _rovingWidth.text = _s["rovingWidth"].toString();
      _deltaBobbinDia.text = _s["deltaBobbinDia"].toString();
      _bareBobbinDia.text = _s["bareBobbinDia"].toString();
      _rampupTime.text= _s["rampupTime"].toString();
      _rampdownTime.text = _s["rampdownTime"].toString();
      _changeLayerTime.text = _s["changeLayerTime"].toString();

    }


    try{
      settingsStream!.listen(_onDataReceived).onDone(() {});
    }
    catch(e){

      print("Settings: Listening init: ${e.toString()}");
    }



  }

  @override
  void dispose() {
    // TODO: implement dispose
    _data.clear();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHt  = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;


    if(connection!.isConnected){
      bool _enabled = Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed;

      return SingleChildScrollView(
        padding: EdgeInsets.only(left:screenHt *0.02,top: screenHt*0.01 ,bottom: screenHt*0.02, right: screenWidth*0.02),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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
                _customRow("Layers (m)", _layers, isFloat: false,defaultValue: "",enabled: _enabled),
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

              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,

              child: Row(
                mainAxisAlignment: _settingsButtons().length==1? MainAxisAlignment.end: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: _settingsButtons(),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return _checkConnection();
    }



  }

  List<Widget> _settingsButtons(){

    if(Provider.of<ConnectionProvider>(context,listen: false).settingsChangeAllowed){
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                  _requestSettings();
                },
                icon: Icon(Icons.input, color: Theme.of(context).primaryColor,)
            ),
            Text(
              "Input",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                //hard coded change
                _spindleSpeed.text =  "650";
                _draft.text =  "8.8";
                _twistPerInch.text = "1.4";
                _RTF.text = "1";
                _layers.text="50";
                _maxHeightOfContent.text = "280";
                _rovingWidth.text = "1.2";
                _deltaBobbinDia.text = "1.1";
                _bareBobbinDia.text = "48";
                _rampupTime.text= "12";
                _rampdownTime.text = "12";
                _changeLayerTime.text = "800";

                SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);

                ConnectionProvider().setSettings(_sm.toMap());
                Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

              },
              icon: Icon(Icons.settings_backup_restore,color: Theme.of(context).primaryColor,),
            ),
            Text(
              "Default",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                String _valid = isValidForm();
                if(_valid == "valid"){

                  //run calculate to prevent rpm from exceeding limit
                  try{
                    calculate();
                  }
                  on CustomException catch(e){

                    //handle these exceptions separately

                    print("Settings: onSave custom: ${e.toString()}");

                    SnackBar _sb = SnackBarService(message: e.toString(), color: Colors.red).snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_sb);
                  }
                  catch(e){
                    print("Settings: onSave: ${e.toString()}");
                    SnackBar _sb = SnackBarService(message: "Settings Not Saved", color: Colors.red).snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_sb);
                  }



                  SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);
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
            Text(
              "Save",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                try{

                  String _err = isValidForm();

                  if(_err!="valid"){
                    //if error in form
                    SnackBar _snack = SnackBarService(message: _err, color: Colors.red).snackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_snack);

                    throw FormatException(_err);
                  }

                  SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);

                  ConnectionProvider().setSettings(_sm.toMap());
                  Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

                  showDialog(
                      context: context,
                      builder: (context) {
                        return _popUpUI();
                      }
                  );
                }
                catch(e){
                  print("Settings: search icon button: ${e.toString()}");
                }
              },
              icon: Icon(Icons.search,color: Theme.of(context).primaryColor,),
            ),
            Text(
              "Parameters",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

      ];
    }
    else{
      return [

        IconButton(
          onPressed: (){
            try{

              String _err = isValidForm();

              if(_err!="valid"){
                //if error in form
                SnackBar _snack = SnackBarService(message: _err, color: Colors.red).snackBar();
                ScaffoldMessenger.of(context).showSnackBar(_snack);

                throw FormatException(_err);
              }

              SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);

              ConnectionProvider().setSettings(_sm.toMap());
              Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());

              showDialog(
                  context: context,
                  builder: (context) {
                    return _popUpUI();
                  }
              );
            }
            catch(e){
              print("Settings: search icon button: ${e.toString()}");
            }
          },
          icon: Icon(Icons.search,color: Theme.of(context).primaryColor,),
        ),
      ];
    }
  }


  Dialog _popUpUI(){

    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height*0.8,
        width: MediaQuery.of(context).size.width*0.9,
        color: Colors.white,
        child: FlyerPopUpUI(),
      ),
    );
  }


  void _onDataReceived(Uint8List data) {

    try {
      String _d = utf8.decode(data);

      if(_d==null || _d==""){
        throw FormatException('Invalid Packet');
      }

      if(_d.substring(4,6)=="02" || _d == Acknowledgement().createPacket() || _d == Acknowledgement().createPacket(error: true)){

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

    if(_layers.text.trim() == "" ){
      errorMessage = "Layers is Empty!";
      return errorMessage;
    }
    else{
      List range = globals.settingsLimits["layers"]!;
      double val = double.parse(_layers.text.trim());

      if(val < range[0] || val > range[1]){
        errorMessage = "Layers values should be within $range";
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
      await Future.delayed(Duration(seconds: 1)); //wait for acknowlegement
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
        _layers.text = settings["layers"]!.toInt().toString();
        _maxHeightOfContent.text = settings["maxHeightOfContent"]!.toInt().toString();
        _rovingWidth.text = settings["rovingWidth"].toString();
        _deltaBobbinDia.text = settings["deltaBobbinDia"].toString();
        _bareBobbinDia.text = settings["bareBobbinDia"]!.toInt().toString();
        _rampupTime.text = settings["rampupTime"]!.toInt().toString();
        _rampdownTime.text = settings["rampdownTime"]!.toInt().toString();
        _changeLayerTime.text = settings["changeLayerTime"]!.toInt().toString();

        newDataReceived = false;


        SettingsMessage _sm = SettingsMessage(spindleSpeed: _spindleSpeed.text, draft: _draft.text, twistPerInch: _twistPerInch.text, RTF: _RTF.text, layers: _layers.text, maxHeightOfContent: _maxHeightOfContent.text, rovingWidth: _rovingWidth.text, deltaBobbinDia: _deltaBobbinDia.text, bareBobbinDia: _bareBobbinDia.text, rampupTime: _rampupTime.text, rampdownTime: _rampdownTime.text, changeLayerTime: _changeLayerTime.text);
        ConnectionProvider().setSettings(_sm.toMap());
        Provider.of<ConnectionProvider>(context,listen: false).setSettings(_sm.toMap());


        SnackBar _sb = SnackBarService(message: "Settings Received", color: Colors.green).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

        setState(() {

        });
      }
      else{
        SnackBar _sb = SnackBarService(message: "Settings Not Received", color: Colors.red).snackBar();
        ScaffoldMessenger.of(context).showSnackBar(_sb);

      }

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


  void calculate(){

    //calculates rpm
    //always run this function in try catch
    double FR_CIRCUMFERENCE = 94.248;
    
    var maxRPM = 1500;
    var strokeDistLimit = 5.5;
    
    var flyerMotorRPM = double.parse(_spindleSpeed.text) * 1.476;
    var delivery_mtr_min = (double.parse(_spindleSpeed.text)/ double.parse(_twistPerInch.text)) * 0.0254;

    double FR_RPM = (delivery_mtr_min * 1000) / FR_CIRCUMFERENCE;

    var FR_MotorRPM = (FR_RPM * 5);

    var BR_MotorRPM = ((FR_RPM * 23.562) / (double.parse(_draft.text)/ 1.5));


    double layerNo = 0; //change this

    var bobbinDia = double.parse(_bareBobbinDia.text)+ layerNo * double.parse(_deltaBobbinDia.text);

    var deltaRpm_Spindle_Bobbin = (delivery_mtr_min * 1000) /
        (bobbinDia * 3.14159);

    var bobbinRPM = double.parse(_spindleSpeed.text) + deltaRpm_Spindle_Bobbin;
    var bobbinMotorRPM = bobbinRPM * 1.476;

    var strokeHeight = double.parse(_maxHeightOfContent.text) - (double.parse(_rovingWidth.text) * layerNo);
    var _strokeDistperSec = (deltaRpm_Spindle_Bobbin * double.parse(_rovingWidth.text)) / 60.0; //5.5
    var liftMotorRPM = (_strokeDistperSec * 60.0 / 4) * 15.3;
  

    if(flyerMotorRPM > maxRPM){
      throw CustomException("Flyer Motor RPM (${flyerMotorRPM.toInt()}) Exceeds $maxRPM");
    }
    if(FR_MotorRPM > maxRPM){
      throw CustomException("FR Motor RPM (${FR_MotorRPM.toInt()}) Exceeds $maxRPM");
    }
    if(BR_MotorRPM > maxRPM){
      throw CustomException("BR Motor RPM (${BR_MotorRPM.toInt()}) Exceeds $maxRPM");
    }
    if(bobbinMotorRPM > maxRPM){
      throw CustomException("Bobbin Motor RPM (${bobbinMotorRPM.toInt()}) Exceeds $maxRPM");
    }
    if(_strokeDistperSec > strokeDistLimit){
      throw CustomException("Stroke Dist Per Sec (${_strokeDistperSec.toStringAsFixed(2)}) Exceeds $strokeDistLimit");
    }
    if(liftMotorRPM> maxRPM){
      throw CustomException("Lift Motor RPM (${liftMotorRPM.toInt()}) Exceeds $maxRPM");
    }

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

class CustomException implements Exception{
  String message;

  CustomException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    return message;
  }
}




