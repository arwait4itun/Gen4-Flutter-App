
import 'package:flyer/message/Flyer/errorMessage.dart';
import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';

class StatusMessage{

  Map<String, String> decode(String packet) {

    //decodes packet for status

    //example 7E28060403010842DC70A4020842DE0000000400007E

    Map<String, String> _settings = Map<String, String>();

    String sof = packet.substring(0,2); //7E start of frame

    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length

    print(len);

    String _machineState = packet.substring(4,6);
    String _ss = packet.substring(6,8);

    int _attributeLength = int.parse(packet.substring(8,10)); //should be 3
    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      print("Status Message: Invalid Start Of Frame");
      return Map<String, String>();
      //throw FormatException("Status Message: Invalid Start Of Frame");
    }

    String _ssn = substateName(_ss);

    if(_ssn != ""){
      _settings["substate"] = _ssn;
    }
    else{
      print("Status Message: Invalid Substate");
      return Map<String, String>();
      //throw FormatException("Status Message: Invalid Substate");
    }

    if(_ssn=="error"){
      //written as a separate class -> errorMessage.dart
      return ErrorMessage().decode(packet);
    }

    if(_machineState!=Information.machineState.hexVal){
      print("Status Message: Invalid Request Settings Code");
      return Map<String, String>();
      //throw FormatException("Status Message: Invalid Request Settings Code");
    }


    for(int i=start; i<end;){
      String t = packet.substring(i,i+2);
      int l = int.parse(packet.substring(i+2,i+4));
      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(_ssn,t); //gives attribute name from substate

      double v; //int or double

      if(key == ""){
        i=i+4+l;
        continue;
        //throw FormatException("Invalid Attribute Type");
      }

      if(l==4){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

      if(key==Pause.pauseReason.name){
       if(val== pauseReason.userPaused.hexVal.padLeft(4,"0")){
          _settings[key] = "User Paused";
        }
        else if (val == pauseReason.creelSliverCut.hexVal.padLeft(4,"0")){
          _settings[key] = "Creel Sliver Cut";
        }else if(val == pauseReason.coilerSliverCut.hexVal.padLeft(4,"0")){
         _settings[key] = "Coiler Sliver Cut";
       }else if(val == pauseReason.lapping.hexVal.padLeft(4,"0")){
         _settings[key] = "Lapping";
       }else{
         _settings[key] = "UnknownReason for Pause";
       }
        i=i+4+l;
        continue;
      }

      //print("t: $t, l: $l, v: $val");
      _settings[key] = v.toString();
      i=i+4+l;
    }



    print(_settings);
    return _settings;
  }

  String substateName(String t){

    List<Substate> vals = Substate.values;

    for(int i=0; i<vals.length;i++){

      Substate v = vals[i];

      if(v.hexVal == t){
        return v.name;
      }
    }

    return "0";
  }

  String attributeName(String ss,String t){

    //chooses attribute based on substate
    if(ss==Substate.homing.name && t==Homing.rightLiftDistance.hexVal){
      return Homing.rightLiftDistance.name;
    }
    else if(ss==Substate.homing.name && t==Homing.leftLiftDistance.hexVal){
      return Homing.leftLiftDistance.name;
    }
    else if(ss==Substate.running.name && t==Running.leftLiftDistance.hexVal){
      return Running.leftLiftDistance.name;
    }
    else if(ss==Substate.running.name && t==Running.rightLiftDistance.hexVal){
      return Running.rightLiftDistance.name;
    }
    else if(ss==Substate.running.name && t==Running.layers.hexVal){
      return Running.layers.name;
    }
    else if(ss==Substate.pause.name && t==Pause.pauseReason.hexVal){
      return Pause.pauseReason.name;
    }
    else if(ss==Substate.error.name && t==Error.information.hexVal){
      return Error.information.name;
    }
    else if(ss==Substate.error.name && t==Error.source.hexVal){
      return Error.source.name;
    }
    else if(ss==Substate.error.name && t==Error.action.hexVal){
      return Error.action.name;
    }
    else{
      return "";
    }
  }
}