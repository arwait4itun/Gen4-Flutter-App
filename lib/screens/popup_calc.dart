import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/provider_service.dart';

class popUpUI extends StatefulWidget {
  const popUpUI({Key? key}) : super(key: key);

  @override
  _popUpUIState createState() => _popUpUIState();
}

class _popUpUIState extends State<popUpUI> {

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
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Delivery Mtrs per Min:\t${delivery_mtr_min.toStringAsFixed(2)??"-"}',
              style:
              TextStyle(color: Colors.black, fontSize:  15),
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

    double FR_CIRCUMFERENCE = 94.248;

    flyerMotorRPM = _spindleSpeed*1.476;
    delivery_mtr_min = (_spindleSpeed/_twistPerInch) * 0.0254;
    
    double FR_RPM = (delivery_mtr_min*1000)/FR_CIRCUMFERENCE;
    
    FR_MotorRPM = (FR_RPM *5);
    
    BR_MotorRPM = ((FR_RPM * 23.562)/(_draft/1.5));

     var maxLayers_1 = (_maxHeightOfContent/_rovingWidth); // for stroke Ht != 0
    
     var maxLayers_2 = ((140 - _bareBobbinDia)/_deltaBobbinDia); // for bobbin Circumference= max Width
   
    if (maxLayers_1 >= maxLayers_2){
      maxLayers = maxLayers_2  - 5;
    }else{
      maxLayers = maxLayers_1  - 5;
    }

    double layerNo = 0;//change this
    
    var bobbinDia = _bareBobbinDia + layerNo * _deltaBobbinDia;
    
    var deltaRpm_Spindle_Bobbin = (delivery_mtr_min*1000)/(bobbinDia * 3.14159);
    
    var bobbinRPM = _spindleSpeed + deltaRpm_Spindle_Bobbin;
    bobbinMotorRPM = bobbinRPM * 1.476;

    var strokeHeight = _maxHeightOfContent - (_rovingWidth * layerNo);
    var strokeDistperSec = (deltaRpm_Spindle_Bobbin * _rovingWidth)/60.0;
    var strokeTime = strokeHeight/strokeDistperSec;
    liftMotorRPM = (strokeDistperSec *60.0/4)*15.3;
    
    //calculate time for input layers


    double totalTime_s = 0;
    totalRunTime_Min = 0;
    
    for (int i=0;i<maxLayers; i++){
      bobbinDia = _bareBobbinDia + i*_deltaBobbinDia;
      var deltaRPM = (delivery_mtr_min*1000)/(bobbinDia * 3.14159);

      strokeHeight = _maxHeightOfContent - (_rovingWidth * i);
      var strokeDist_sec = (deltaRPM * _rovingWidth)/60.0;
      strokeTime = strokeHeight/strokeDist_sec;
      totalTime_s += strokeTime;
    }
    totalRunTime_Min = totalTime_s/60.0;
    
  }


}


/*


String delivery_mtr_min;
String maxLayers;

inputLayers:
strokeTime for input Layers in min: ( use function)

layerNo:(default 0)
bobbinDia
strokeDistperSec


flyerMotorRPM
bobbinMotorRPM
FR_MotorRPM
BR_MotorRPM
liftMotorRPM



/**********************************/

flyerMotorRPM = spindleSpeed*1.476;
delivery_mtr_min = (spindleSpeed/tpi) * 0.0254;
FR_RPM = (double)(delivery_mtr_min*1000)/FR_CIRCUMFERENCE;
FR_MotorRPM = ()(FR_RPM *FRMOTOR_TO_FR_RATIO);
BR_MotorRPM = ()((FR_RPM * BR_CONSTANT)/(tensionDraft/1.5));

 maxLayers_1 = ()(contentHeight/rovingWidth); // for stroke Ht != 0
 maxLayers_2 = ()((MAX_CONTENT_DIA_MM - bareBobbinDia)/deltaBobbinDia); // for bobbin Circumference= max Width
if (maxLayers_1 >= maxLayers_2){
maxLayers = maxLayers_2  - 5;
}else{
maxLayers = maxLayers_1  - 5;
}

layerNo = 0;
bobbinDia = BareBobbinDia + layerNo * deltaBobbinDia;
deltaRpm_Spindle_Bobbin = delivery_mtr_min*1000)/(bobbinDia * 3.14159);
bobbinRPM = spindleSpeed + deltaRpm_Spindle_Bobbin;
bobbinMotorRPM = bobbinRPM * 1.476;

strokeHeight = contentHeight - (rovingWidth * layerNo);
strokeDistperSec = (deltaRpm_Spindle_Bobbin * rovingWidth)/60.0;
strokeTime = strokeHeight/strokeDistperSec;
liftMotorRPM = ()((double)(strokeDistperSec *60.0)/4)*LIFT_MOTOR_TO_LIFT_SCREW_RATIO;



//
void CalculateTotalRunTime(machineSettingsTypeDef *ms ,machineParamsTypeDef *mp){

double bobbinDia;
double deltaRPM;

double strokeHeight;
double strokeDist_sec;
double strokeTime;
double totalTime_s;

totalTime_s = 0;
for (int i=0;i<maxLayers; i++){
bobbinDia = bareBobbinDia + i*deltaBobbinDia;
deltaRPM = (delivery_mtr_min*1000)/(bobbinDia * 3.14159);
strokeHeight = contentHeight - (rovingWidth * i);
strokeDist_sec = (deltaRPM * rovingWidth)/60.0;
strokeTime = strokeHeight/strokeDist_sec;
totalTime_s += strokeTime;
}
totalRunTime_Min = totalTime_s/60.0;
}

 */