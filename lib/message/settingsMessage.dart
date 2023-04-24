
import 'package:flyer/message/hexa_to_double.dart';

import 'enums.dart';

class SettingsMessage{
  
  String spindleSpeed;
  String draft;
  String twistPerInch;
  String RTF;
  String lengthLimit;
  String maxHeightOfContent;
  String rovingWidth;
  String deltaBobbinDia;
  String bareBobbinDia;
  String rampupTime;
  String rampdownTime;
  
  SettingsMessage({
  required this.spindleSpeed,
  required this.draft,
  required this.twistPerInch,
  required this.RTF,
  required this.lengthLimit,
  required this.maxHeightOfContent,
  required this.rovingWidth,
  required this.deltaBobbinDia,
  required this.bareBobbinDia,
  required this.rampupTime,
  required this.rampdownTime,
  });

  String createPacket(){

    String packet = "";

    String packetLength = "";
    String attributeCount =  "11";

    int bit4 = 4; //for padding
    String bit4s = "04";

    int bit8 = 8;
    String bit8s = "08";


    //  packet += packetLength;
    
    packet += Information.settingsFromApp.hexVal;
    packet += Substate.run.hexVal; // doesnt matter for this usecase
    packet += attributeCount;

    packet += attribute(SettingsAttribute.spindleSpeed.hexVal,bit4s,padding(spindleSpeed, bit4));
    packet += attribute(SettingsAttribute.draft.hexVal, bit8s, padding(draft, bit8));
    packet += attribute(SettingsAttribute.twistPerInch.hexVal, bit8s, padding(twistPerInch, bit8));
    packet += attribute(SettingsAttribute.RTF.hexVal, bit8s, padding(RTF, bit8));
    packet += attribute(SettingsAttribute.lengthLimit.hexVal,bit4s, padding(lengthLimit, bit4));
    packet += attribute(SettingsAttribute.maxHeightOfContent.hexVal, bit4s, padding(maxHeightOfContent, bit4));
    packet += attribute(SettingsAttribute.rovingWidth.hexVal, bit8s, padding(rovingWidth, bit8));
    packet += attribute(SettingsAttribute.deltaBobbinDia.hexVal, bit8s, padding(deltaBobbinDia,bit8));
    packet += attribute(SettingsAttribute.bareBobbinDia.hexVal, bit4s, padding(bareBobbinDia, bit4));
    packet += attribute(SettingsAttribute.rampupTime.hexVal, bit4s, padding(rampupTime, bit4));
    packet += attribute(SettingsAttribute.rampdownTime.hexVal, bit4s, padding(rampdownTime, bit4));


    packet += Separator.eof.hexVal;

    packetLength = padding(packet.length.toString(),2);

    packet = Separator.sof.hexVal + packetLength + packet;

    print(packet);
    return packet.toUpperCase();
  }

  String attribute(String attributeType, String attributeLength,String attributeValue){

    return attributeType+attributeLength+attributeValue;
  }

  String padding(String str,int no){

    //pad with 4

    String s;
    int len;

    if(no==4 || no == 2){

      s = double.parse(str).toInt().toString();
      s = int.parse(s).toRadixString(16);
      len = s.length;
    }
    else{
      //no==8 means its a floating point
      
      s = hexConvert(double.parse(str));
      len = s.length;
    }


    for(int i = 0;i < no-len;i++){
      s = "0"+s;
    }

    return s;
  }
}


void main(){

  String s ="12345678";

  print(s.substring(1,5));
}