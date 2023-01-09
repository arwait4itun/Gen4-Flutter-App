import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {


  List<String> _testType = ["MOTOR","SUBASSEMBLY"];
  List<String> _motorName = ["FLYER","BOBBIN","FRONT ROLLER","BACK ROLLER"];
  List<String> _subAssemblyName = ["DRAFTING","WINDING","LIFT"];
  List<String> _controlType = ["OPEN LOOP","CLOSED LOOP"];

  late String _testTypeChoice = _testType.first;
  late String _motorNameChoice = _motorName.first;
  late String _subAssemblyChoice = _subAssemblyName.first;
  late String _controlTypeChoice = _controlType.first;


  final TextEditingController _target = new TextEditingController();
  final TextEditingController _targetRPM = new TextEditingController();
  final TextEditingController _signalVoltage = new TextEditingController();
  final TextEditingController _testRuntime = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(7),
        scrollDirection: Axis.vertical,
        child: Container(
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
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
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
                            underline: Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width*0.1,
                              color: Theme.of(context).highlightColor,
                            ),
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
                            underline: Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width*0.1,
                              color: Theme.of(context).highlightColor,
                            ),
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
                  : TableRow(
                    children: <Widget>[

                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "Subassembly Name",
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
                            value: _subAssemblyChoice,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.lightGreen),
                            underline: Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width*0.1,
                              color: Theme.of(context).highlightColor,
                            ),
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                _subAssemblyChoice = value!;
                                _controlTypeChoice = "CLOSED LOOP";
                              });
                            },
                            items: _subAssemblyName.map<DropdownMenuItem<String>>((String value) {
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
                            underline: Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width*0.1,
                              color: Theme.of(context).highlightColor,
                            ),
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
                  ): TableRow(children: <Widget>[TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        "Control Type",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                    Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.2,
                      margin: EdgeInsets.only(top: 2.5,bottom: 2.5),
                      child: Text("CLOSED LOOP"),
                    ),
                  ),]),

                  _customRow2("Target(%)", _target),
                  _customRow2("Target RPM", _targetRPM),
                  _customRow2("Signal Voltage(%)", _signalVoltage),
                  _customRow2("Test Run Time(s)", _testRuntime),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: ()=>{},
                    child: Text("RUN DIAGNOSE"),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor)),
                  ),
                ),
              ),


            ],
          ),
        ),
    );

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
            ),
          ),
        ),

      ],
    );
  }


}



