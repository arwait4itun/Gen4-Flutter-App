import 'package:flutter/material.dart';


class PIDPage extends StatefulWidget {
  const PIDPage({Key? key}) : super(key: key);

  @override
  _PIDPageState createState() => _PIDPageState();
}

class _PIDPageState extends State<PIDPage> {

  TextEditingController _kp = new TextEditingController();
  TextEditingController _ki = new TextEditingController();
  TextEditingController _pwmOffset =  new TextEditingController();

  List<String> _motorName = ["FLYER","BOBBIN","FRONT ROLLER","BACK ROLLER"];
  late String _motorChoice = _motorName.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 50,top: 7,bottom: 7, right: 7),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: Center(
                child: Text("SETTINGS",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Theme.of(context).primaryColor),),
              ),
            ),
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.3),
                1: FractionColumnWidth(0.4),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[

                TableRow(
                  children: <Widget>[

                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 5),
                        child: Text(
                          "Options",
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
                          value: _motorChoice,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.lightGreen),
                          underline: Container(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _motorChoice = value!;
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
                ),
                _customRow("Kp", _kp),
                _customRow("Ki", _ki),
                _customRow("Starting PWM Offset", _pwmOffset),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.15, bottom: 10,left: 10,right: 10),
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  IconButton(
                    onPressed: () async {

                    },
                    icon: Icon(Icons.refresh,color: Theme.of(context).primaryColor,),
                  ),
                  IconButton(
                    onPressed: (){

                    },
                    icon: Icon(Icons.save,color: Theme.of(context).primaryColor,),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _customRow(String label, TextEditingController controller){

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
              keyboardType: TextInputType.number,
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

  AppBar appBar(){

    return AppBar(
      title: const Text("PID"),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1.0,
      shadowColor: Theme.of(context).highlightColor,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
