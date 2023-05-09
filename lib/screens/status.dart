import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flyer/globals.dart' as globals;
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'dart:async';
import 'dart:math' as math;

class Data{

  double x,y1,y2,y3;

  Data({required this.x,required this.y1,required this.y2, required this.y3});
}


class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {

  ChartSeriesController? _chartSeriesController;
  List<Data>? _data;
  late StreamSubscription s;
  late BluetoothConnection? connection=null;
  bool isConnected = false;



  @override
  void initState() {
    // TODO: implement initState

    _data = List<Data>.empty(growable: true);


    BluetoothConnection.toAddress(globals.selectedDevice?.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnected = true;
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });


    if(connection!=null && isConnected == true) {
      print("connections work");

      try {
        s = connection!.input!.listen((event) {
          _onDataReceived(event);
        });
        globals.isListening = true;
      }
      catch(e){
        print("Error in Listening: "+e.toString());
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    print("dispose");
    _data!.clear();
    _chartSeriesController = null;

    if(isConnected){
      s.cancel();
      connection!.dispose();
      connection = null;
    }
    super.dispose();
  }


  void _onDataReceived(Uint8List data){


    try {
      String _d = utf8.decode(data);

      //use regex to format data such that only numbers and [ABCDEF] and . remains
      //add hex digits also !!

      _d = _d.replaceAll(RegExp(r'[^0-9.,]'),'');

      List<String> _arr = _d.split(",");

      double _y1 = double.parse(_arr[0]);
      double _y2 = double.parse(_arr[1]);
      double _y3 = double.parse(_arr[2]);

      print('Data incoming!!!!!!!!!!!!!!!: ${_arr}');


      if(_arr.length ==3) {
        _data!.add(
            Data(x: _data!.length.toDouble(), y1: _y1, y2: _y2, y3: _y3));
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[_data!.length - 1],
        );
      }
    }
    catch(e){
      print(e.toString());
      print("Error parsing data: "+utf8.decode(data));
    }


  }

  @override
  Widget build(BuildContext context) {

    bool _connection = Provider.of<ConnectionProvider>(context).isConnected;

    return SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height*0.8,
            width: MediaQuery.of(context).size.width,
            child: _buildLiveLineChart(_connection),
        ),
    );
  }

  Widget _buildLiveLineChart(bool _connection) {



    if(!_connection){
      return Center(
        heightFactor: MediaQuery.of(context).size.width*0.1,
        widthFactor: MediaQuery.of(context).size.width*0.1,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),

            Container(
              height: MediaQuery.of(context).size.height*0.02,
            ),
            Text("Waiting for connection", style: TextStyle(color: Colors.grey, fontSize: 10.0),),
          ],
        ),

      );
    }
    else {
      return SfCartesianChart(
          zoomPanBehavior: ZoomPanBehavior(
          // Enables pinch zooming
            enablePinching: true
          ),

          tooltipBehavior: TooltipBehavior(enable: true),
          plotAreaBorderWidth: 0,
          primaryXAxis:
          NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
          primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0)),
          series: <LineSeries<Data,double>>[
            LineSeries<Data , double>(

              onRendererCreated: (ChartSeriesController controller){
                _chartSeriesController = controller;
              },
              dataSource: _data!,
              color: Colors.orangeAccent,
              xValueMapper: (Data d, _) => d.x,
              yValueMapper: (Data d, _) => d.y1,
              animationDuration: 0,
              markerSettings: MarkerSettings(
                  isVisible: true,
                  color: Colors.red,

              ),
            enableTooltip: true,
            ),
            LineSeries<Data , double>(

              onRendererCreated: (ChartSeriesController controller){
                _chartSeriesController = controller;
              },
              dataSource: _data!,
              color: Colors.blueAccent,
              xValueMapper: (Data d, _) => d.x,
              yValueMapper: (Data d, _) => d.y2,
              animationDuration: 0,
              markerSettings: MarkerSettings(
                isVisible: true,
                color: Colors.purple,

              ),
              enableTooltip: true,
            ),
            LineSeries<Data , double>(

              onRendererCreated: (ChartSeriesController controller){
                _chartSeriesController = controller;
              },
              dataSource: _data!,
              color: Colors.lightGreen,
              xValueMapper: (Data d, _) => d.x,
              yValueMapper: (Data d, _) => d.y3,
              animationDuration: 0,
              markerSettings: MarkerSettings(
                isVisible: true,
                color: Colors.yellow,

              ),
              enableTooltip: true,
            ),
          ]);
    }
  }
}


