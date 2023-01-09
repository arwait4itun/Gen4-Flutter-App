import 'package:flutter/material.dart';

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


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5),
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
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[

              _customRow("Spindle Speed(RPM)", _spindleSpeed),
              _customRow("Draft", _draft),
              _customRow("Twist Per Inch", _twistPerInch),
              _customRow("RTF", _RTF),
              _customRow("Length Limit (mtrs)", _lengthLimit),
              _customRow("Max Height of Content", _maxHeightOfContent),
              _customRow("Roving Width", _rovingWidth),
              _customRow("Delta Bobbin-dia", _deltaBobbinDia),
              _customRow("Bare Bobbin-dia", _bareBobbinDia),
            ],
          ),
          _customButtons(),
        ],
      ),
    );


  }

  TableRow _customRow(String label, TextEditingController controller){

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

  Widget _customButtons(){

    return Container(
      margin: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height*0.1,
      width: MediaQuery.of(context).size.width,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.build,color: Theme.of(context).primaryColor,),

          ),
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.save,color: Theme.of(context).primaryColor,),
          ),
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.query_stats,color: Theme.of(context).primaryColor,),
          ),
        ],
      ),
    );
  }
}




