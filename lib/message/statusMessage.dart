
import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';

class StatusMessage{

  Map<String, String> decode(String packet) {

    //decodes packet for status


    Map<String, String> _settings = Map<String, String>();

    String sof = packet.substring(0,2); //7E start of frame
    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length

    String _machineState = packet.substring(4,6);
    String _ss = packet.substring(6,8); //not necessary

    int _attributeLength = int.parse(packet.substring(8,10)); //should be 3

    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      throw FormatException("Status Message: Invalid Start Of Frame");
    }

    if(substateName(_ss) != ""){
      _settings["substate"] = substateName(_ss);
    }
    else{
      throw FormatException("Status Message: Invalid Substate");
    }

    if(_machineState!=Information.machineState.hexVal){
      throw FormatException("Status Message: Invalid Request Settings Code");
    }

    /*
    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        throw FormatException("Invalid Attribute Type");
      }

      if(l==4){
        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

      //print("t: $t, l: $l, v: $val");
      _settings[key] = v.toString();

      i=i+4+l;
    }

     */

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

  String attributeName(String t){

    //CHANGE THIS TO STATUSattribute -> Create New Enum

    if(t==SettingsAttribute.spindleSpeed.hexVal){
      return SettingsAttribute.spindleSpeed.name;
    }
    else if(t==SettingsAttribute.draft.hexVal){
      return SettingsAttribute.draft.name;
    }
    else if(t==SettingsAttribute.draft.hexVal){
      return SettingsAttribute.draft.name;
    }
    else if(t==SettingsAttribute.twistPerInch.hexVal){
      return SettingsAttribute.twistPerInch.name;
    }
    else if(t==SettingsAttribute.RTF.hexVal){
      return SettingsAttribute.RTF.name;
    }
    else if(t==SettingsAttribute.lengthLimit.hexVal){
      return SettingsAttribute.lengthLimit.name;
    }
    else if(t==SettingsAttribute.maxHeightOfContent.hexVal){
      return SettingsAttribute.maxHeightOfContent.name;
    }
    else if(t==SettingsAttribute.rovingWidth.hexVal){
      return SettingsAttribute.rovingWidth.name;
    }
    else if(t==SettingsAttribute.deltaBobbinDia.hexVal){
      return SettingsAttribute.deltaBobbinDia.name;
    }
    else if(t==SettingsAttribute.bareBobbinDia.hexVal){
      return SettingsAttribute.bareBobbinDia.name;
    }
    else if(t==SettingsAttribute.rampupTime.hexVal){
      return SettingsAttribute.rampupTime.name;
    }
    else if(t==SettingsAttribute.rampdownTime.hexVal){
      return SettingsAttribute.rampdownTime.name;
    }
    else if(t==SettingsAttribute.changeLayerTime.hexVal){
      return SettingsAttribute.changeLayerTime.name;
    }
    else{
      return "";
    }
  }
}