import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/provider_service.dart';

class FlyerPopUpUI extends StatefulWidget {
  const FlyerPopUpUI({Key? key}) : super(key: key);

  @override
  _FlyerPopUpUIState createState() => _FlyerPopUpUIState();
}

class _FlyerPopUpUIState extends State<FlyerPopUpUI> {

  late double delivery_mtr_min;
  late double maxLayers;

  late double flyerMotorRPM,bobbinMotorRPM,FR_MotorRPM,BR_MotorRPM,liftMotorRPM,totalRunTime_Min;
  
  late double _spindleSpeed;
  late double _draft;
  late double _twistPerInch;
  late double _RTF;
  late double _layers;

  late double _maxHeightOfContent;

  late double _rovingWidth;

  late double _deltaBobbinDia,_bareBobbinDia,_rampupTime,_rampdownTime,_changeLayerTime;
  late double _strokeDistperSec;



  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(!Provider.of<ConnectionProvider>(context,listen: false).isSettingsEmpty){

      Map<String,String> _s = Provider.of<ConnectionProvider>(context,listen: false).settings;

      _spindleSpeed = double.parse(_s["spindleSpeed"].toString());
      _draft =  double.parse(_s["draft"].toString());
      _twistPerInch = double.parse(_s["twistPerInch"].toString());
      _RTF = double.parse(_s["RTF"].toString());
      _layers=double.parse(_s["layers"].toString());
      _maxHeightOfContent  = double.parse(_s["maxHeightOfContent"].toString());
      _rovingWidth = double.parse(_s["rovingWidth"].toString());
      _deltaBobbinDia = double.parse(_s["deltaBobbinDia"].toString());
      _bareBobbinDia = double.parse(_s["bareBobbinDia"].toString());
      _rampupTime = double.parse(_s["rampupTime"].toString());
      _rampdownTime = double.parse(_s["rampdownTime"].toString());
      _changeLayerTime = double.parse(_s["changeLayerTime"].toString());

    }

  }
  @override
  Widget build(BuildContext context) {

    if(Provider.of<ConnectionProvider>(context,listen: false).isSettingsEmpty){

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Empty',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
        ],
      );
    }
    else{

      try{
        calculate();
      }
      catch(e){
        print("pop up ui:  ${e.toString()}");
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Empty',
                style:
                TextStyle(color: Colors.black, fontSize:  15),
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Internal Parameters',
              style:
              TextStyle(color: Colors.black, fontSize:  18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Delivery:\t${delivery_mtr_min.toStringAsFixed(2)??"-"} m/min',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Stroke Velocity:\t\t${_strokeDistperSec.toStringAsFixed(2)??"-"} mm/s',
              style:
              TextStyle(
                  color: _strokeDistperSec>5.5? Colors.red: Colors.black,
                  fontSize:  15,
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Max Layers Possible:\t\t${maxLayers.ceil()??"-"}',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Runtime ${_layers.toInt()} layers:\t\t${totalRunTime_Min.toStringAsFixed(2)??"-"} min',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Flyer Motor RPM:\t\t\t\t${flyerMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: flyerMotorRPM <= 1400?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Bobbin Motor RPM:    ${bobbinMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: bobbinMotorRPM <= 1400?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'FR Motor RPM:    ${FR_MotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: FR_MotorRPM <= 1400?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'BR Motor RPM:    ${BR_MotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: BR_MotorRPM <= 1400?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Lift Motor RPM:    ${liftMotorRPM.ceil()??"-"}',
              style:
              TextStyle(
                  color: liftMotorRPM <= 1400?  Colors.black: Colors.red,
                  fontSize:  15
              ),
            ),
          ),
        ],
      );
    }


  }

  
  void calculate(){

    var maxRPM = 1450;
    var strokeDistLimit = 5.5;

    double frCircumference = 94.248;
    double frRollerToMotorGearRatio = 4.61;

    flyerMotorRPM = _spindleSpeed * 1.476;
    delivery_mtr_min = (_spindleSpeed/ _twistPerInch) * 0.0254;

    double frRpm = (delivery_mtr_min * 1000) / frCircumference;
    FR_MotorRPM = (frRpm * frRollerToMotorGearRatio);
    BR_MotorRPM = ((frRpm * 23.562) / (_draft/ 1.5));

    var maxLayers_1 = (_maxHeightOfContent/_rovingWidth); // for stroke Ht != 0
    var maxLayers_2 = ((140 - _bareBobbinDia)/_deltaBobbinDia); // for bobbin Circumference= max Width
    if (maxLayers_1 >= maxLayers_2){
      maxLayers = maxLayers_2  - 5;
    }else{
      maxLayers = maxLayers_1  - 5;
    }
    double layerNo = 0; //layer 0 has highest speed for bobbin RPM so calculate only for that
    var bobbinDia = _bareBobbinDia+ layerNo * _deltaBobbinDia;

    var deltaRpmSpindleBobbin = (delivery_mtr_min * 1000) /(bobbinDia * 3.14159);
    var bobbinRPM = _spindleSpeed + deltaRpmSpindleBobbin;
    bobbinMotorRPM = bobbinRPM * 1.476;

    var strokeHeight = _maxHeightOfContent - (_rovingWidth * layerNo);
    _strokeDistperSec = (deltaRpmSpindleBobbin * _rovingWidth) / 60.0; //5.5
    liftMotorRPM = (_strokeDistperSec * 60.0 / 4) * 15.3;

    //calculate time for input layers
    double totalTime_s = 0;
    totalRunTime_Min = 0;
    
    for (int i=0;i<maxLayers; i++){
      bobbinDia = _bareBobbinDia + i*_deltaBobbinDia;
      var deltaRPM = (delivery_mtr_min*1000)/(bobbinDia * 3.14159);

      strokeHeight = _maxHeightOfContent - (_rovingWidth * i); // to change this after cone Angle factor is added
      var strokeDist_sec = (deltaRPM * _rovingWidth)/60.0;
      double strokeTime = strokeHeight/strokeDist_sec;
      totalTime_s += strokeTime;
    }
    totalRunTime_Min = totalTime_s/60.0;
    
  }


}

