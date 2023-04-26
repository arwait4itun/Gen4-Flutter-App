import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/message/diagnosticMessage.dart';

import 'package:flyer/globals.dart' as globals;


class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  //run diagnose variables

  List<String> _testType = ["MOTOR","LIFT"];
  List<String> _motorName = ["FLYER","BOBBIN","FRONT ROLLER","BACK ROLLER","DRAFTING","WINDING"];
  List<String> _controlType = ["OPEN LOOP","CLOSED LOOP"];

  List<String> _liftMotors = ["BOTH","LEFT","RIGHT"];
  List<String> _bedDirection = ["UP","DOWN"];

  //bedTravelDistance : 2-250 mm

  late String _testTypeChoice = _testType.first;
  late String _motorNameChoice = _motorName.first;
  late String _controlTypeChoice = _controlType.first;

  late String _liftMotorsChoice = _liftMotors.first;
  late String _bedDirectionChoice = _bedDirection.first;


  late double _target = 10; //10-90%
 // final TextEditingController _targetRPM = new TextEditingController();
  late String _testRuntime = "20";
  late double _testRuntimeval = 20;

  final TextEditingController _bedTravelDistance = new TextEditingController();

  String _targetRPM="150";
  String _dutyPerc="10";
  String prev="0";


  //stop diagnose variables
  bool _running = false; //running true -> stop diagnose; else run diagnose

  String? _runningRPM;
  String? _runningSignalVoltage;

  BluetoothConnection? connection;
  bool isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    BluetoothConnection.toAddress(globals.selectedDevice!.address).then((_connection) {
      print('Connected to the device');

      connection = _connection;
      isConnected = true;
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    connection?.dispose();
    connection = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 10,top: 7,bottom: 7, right: 7),
        scrollDirection: Axis.vertical,
        child: _running? _stopDiagnoseUI() : _runDiagnoseUI(),
    );

  }


  Widget _stopDiagnoseUI(){

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: StreamBuilder<Uint8List>(
        stream: connection!.input,
        builder: (context, snapshot) {

          if(snapshot.hasData){
            var data = snapshot.data;
            String _d = utf8.decode(data!);
            print("\nTESTS: run diagnose data: "+_d);
            print(snapshot.data);

            Map<String,double> _diagResponse = DiagnosticMessageResponse().decode(_d);

            try{
              _runningRPM = _diagResponse["speedRPM"]!.toStringAsFixed(2);
              _runningSignalVoltage = _diagResponse["signalVoltage"]!.toStringAsFixed(2);
            }
            catch(e){
              print("tests1: ${e.toString()}");
            }
          }

          return Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width,

                child: Center(
                  child: Text("TEST RESULTS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
                ),
              ),
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.5),
                  1: FractionColumnWidth(0.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  _customRow("Speed in RPM", _runningRPM),
                  _customRow("Signal Voltage", _runningSignalVoltage),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: stopDiagnose,
                    child: Text("STOP DIAGNOSE"),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _runDiagnoseUI(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width,

            child: Center(
              child: Text("TESTS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
            ),
          ),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(0.5),
              1: FractionColumnWidth(0.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Test Type",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _testTypeChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _testTypeChoice = value!;
                          });
                        },
                        items: _testType.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),
              _testTypeChoice=="MOTOR"?
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Motor Name",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _motorNameChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _motorNameChoice = value!;
                          });
                        },
                        items: _motorName.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              )
                  :TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

              _testTypeChoice=="MOTOR"? TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Control Type",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _controlTypeChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _controlTypeChoice = value!;
                          });
                        },
                        items: _controlType.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ):
              TableRow(children: <Widget>[TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    "Control Type",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child:
                  Container(
                    height: MediaQuery.of(context).size.height*0.05,
                    width: MediaQuery.of(context).size.width*0.2,
                    margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                    child: Text("CLOSED LOOP"),
                  ),
                ),]),

              _testTypeChoice=="MOTOR"?
              _targetRow("Target(%)")
                  :  TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

              _testTypeChoice=="MOTOR" && _controlTypeChoice!="OPEN LOOP" ?
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Target RPM",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      margin: EdgeInsets.only(top:10,left: 5, right: 5,bottom: 10),
                      child: Text(
                        _targetRPM,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                ],
              )
                  :TableRow(
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          "Duty Percent",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child:
                      Container(
                        margin: EdgeInsets.only(top:10,left: 5, right: 5,bottom: 10),
                        child: Text(
                          _dutyPerc,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ]
              ),


              _testTypeChoice=="MOTOR" ?
              _testTimeRow("Test Run Time(s)")
                  :TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

              _testTypeChoice=="LIFT"?
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Lift Motors",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _liftMotorsChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _liftMotorsChoice = value!;
                          });
                        },
                        items: _liftMotors.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              )
                  :TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

              _testTypeChoice=="LIFT"?
              TableRow(
                children: <Widget>[

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Bed Direction",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: DropdownButton<String>(
                        value: _bedDirectionChoice,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _bedDirectionChoice = value!;
                          });
                        },
                        items: _bedDirection.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              )
                  :TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

              _testTypeChoice=="LIFT"?
              _customRow2("Bed Travel Distance(mm)", _bedTravelDistance)
                  :TableRow(
                  children: <Widget>[
                    TableCell(child: Container()),
                    TableCell(child: Container()),
                  ]
              ),

            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 10),
            child: Center(
              child: ElevatedButton(
                onPressed: runDiagnose,
                child: Text("RUN DIAGNOSE"),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor)),
              ),
            ),
          ),


        ],
      ),
    );
  }

  String getTargetRPM(String _target){

    double perc = 0;
    double num = 1500;


    if(_target != null || _target != ""){

      try {
        perc = double.parse(_target);
      }
      catch(e){
        perc = 0;
      }

      if(perc > 100){
        perc = 100;
      }

      if(perc < 0){
        perc = 0;
      }
    }

    perc = (perc * num)/100;

    return ((perc/10.0).ceil()*10).toString();

  }



  TableRow _customRow2(String label, TextEditingController controller){

    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
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
            width: MediaQuery.of(context).size.width*0.2,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ),

      ],
    );
  }

  TableRow _customRow(String label,String? attribute){

    //attribute will change
    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
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
            width: MediaQuery.of(context).size.width*0.2,
            margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
            padding: EdgeInsets.only(left: 5, top: 11),
            child: Text(attribute ?? "--", ),
          ),
        ),

      ],
    );
  }


  TableRow _targetRow(String label){

    //slider row

    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: EdgeInsets.only(left:0),
            margin: EdgeInsets.only(left: 0, right: 10),
            child: Slider(
              value: _target,
              max: 90.0,
              min: 10.0,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (val){
                setState(() {
                  _target = (val/5).ceil()*5;
                  _targetRPM = getTargetRPM(_target.toString());
                  _dutyPerc = ((val/5).ceil()*5).toString()+"%";
                });
              },
            ),
          ),
        ),

      ],
    );
  }

  TableRow _testTimeRow(String label){

    //slider row

    return TableRow(
      children: <Widget>[

        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: EdgeInsets.only(left:0),
            margin: EdgeInsets.only(left: 0, right: 10),
            child: Slider(
              value: _testRuntimeval,
              max: 310.0,
              min: 20.0,
              activeColor: Theme.of(context).primaryColor,
              label: _testRuntime.toString(),
              onChanged: (val){
                setState(() {
                  _testRuntimeval = (val/10).ceil()*10;
                  _testRuntime = _testRuntimeval.toString();

                  if(_testRuntimeval>300){
                    _testRuntime = "infinity";
                  }
                });
              },
            ),
          ),
        ),

      ],
    );
  }


  void runDiagnose() async {

    try {

      if(!isConnected || connection==null){
        connection = reconnect();
        isConnected = true;
      }

      DiagnosticMessage _dm = DiagnosticMessage(
          testTypeChoice: _testTypeChoice,
          motorNameChoice: _motorNameChoice,
          controlTypeChoice: _controlTypeChoice,
          target: _target.toString(),
          targetRPM: _targetRPM,
          testRuntime: _testRuntimeval.toString()
      );


      String _m = _dm.createPacket();


      connection!.output.add(Uint8List.fromList(utf8.encode(_m)));

      await connection!.output!.allSent;
      //globals.connection!.close();

      setState(() {
        _running = true;
      });
    }
    catch(e){

      print("Tests2: ${e.toString()}");
    }

  }


  BluetoothConnection? reconnect(){
    BluetoothConnection.toAddress(globals.selectedDevice!.address).then((_connection) {
      print('Reconnected to the device');

      connection = _connection;
      return connection;
    });
  }

  void stopDiagnose() async {

    try{
      setState(() {
        connection!.dispose();
        connection = null;

        isConnected = false;
        _running = false;
      });
    }
    catch(e){
      print("Tests3: ${e.toString()}");
    }
  }
}



