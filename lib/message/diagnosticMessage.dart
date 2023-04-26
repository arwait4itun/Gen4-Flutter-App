import 'enums.dart';
import 'hexa_to_double.dart';

class DiagnosticMessage{

  String testTypeChoice;
  String motorNameChoice;
  String controlTypeChoice;
  String target;
  String targetRPM;
  String testRuntime;


  DiagnosticMessage({
  required this.testTypeChoice,
  required this.motorNameChoice,
  required this.controlTypeChoice,
  required this.target,
  required this.targetRPM,
  required this.testRuntime
  });

  String createPacket(){

    String packet = "";

    String packetLength = "";
    String attributeCount =  "06";

  //  packet += packetLength;

    packet += Information.diagnostics.hexVal;
    packet += Substate.run.hexVal; // doesnt matter for this usecase
    packet += attributeCount;


  
    //attribute count
  //  packet += "5";

    if(this.testTypeChoice == "MOTOR"){


      String _motorId;

      switch(motorNameChoice){

        case "FLYER":
          _motorId = MotorId.flyer.hexVal;
          break;
        case "BOBBIN":
          _motorId = MotorId.bobbin.hexVal;
          break;
        case "FRONT ROLLER":
          _motorId = MotorId.frontRoller.hexVal;
          break;
        case "BACK ROLLER":
          _motorId = MotorId.backRoller.hexVal;
          break;
        case "DRAFTING":
          _motorId = MotorId.drafting.hexVal;
          break;
        case "WINDING":
          _motorId = MotorId.winding.hexVal;
          break;
        default:
          _motorId = MotorId.flyer.hexVal;
      }

      //motor id
      packet += attribute(DiagnosticAttributeType.motorID.hexVal,"02",_motorId);


      String _controlType;

      String subpacket = "";

      if(controlTypeChoice == "OPEN LOOP"){
        _controlType = ControlType.openLoop.hexVal;

       // target = "0000";//doesnt matter for open loop
        subpacket += attribute(DiagnosticAttributeType.targetPercent.hexVal, "04", padding(target.toString(), 4)); //doesnt matter
        subpacket += attribute(DiagnosticAttributeType.testTime.hexVal, "04", padding(testRuntime,4));

      }
      else{
        _controlType = ControlType.closedLoop.hexVal;

        targetRPM = "1500";

        int t = double.parse(target).toInt();

        int val = (int.parse(targetRPM)*t/100).toInt();


        subpacket += attribute(DiagnosticAttributeType.targetPercent.hexVal, "04", padding(val.toString(), 4));
        subpacket += attribute(DiagnosticAttributeType.testTime.hexVal, "04", padding(testRuntime,4));

      }


      //control type
      packet += attribute(DiagnosticAttributeType.kindOfTest.hexVal,"02",_controlType);
      packet += subpacket;



    }
    else{

      //finish this
      packet += attribute(DiagnosticAttributeType.kindOfTest.hexVal, "01", "01"); //01 subassembly
    }

    packet += Separator.eof.hexVal;

    packetLength = padding(packet.length.toString(),2);

    packet = Separator.sof.hexVal+packetLength+packet;

    print(packet.toUpperCase());

    return packet.toUpperCase();
  }
  
  String attribute(String attributeType, String attributeLength,String attributeValue){
    
    return attributeType+attributeLength+attributeValue;
  }

  String padding(String str,int no){

    //pad with 4 and hex conversion
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
      s="0"+s;
    }

    return s;
  }


}

class DiagnosticMessageResponse{

  Map<String, double> decode(String packet) {
    //decodes packet after settings request is sent

    //print("packet: $packet");

    Map<String, double> _settings = new Map<String, double>();


    String sof = packet.substring(0,2); //7E start of frame

    int len = int.parse(packet.substring(2,4),radix: 16); //Packet Length

    String _diagnosticResponse = packet.substring(4,6);
    String _ss = packet.substring(6,8); //not necessary

    int _attributeLength = int.parse(packet.substring(8,10));

    //print(_attributeLength);

    int start = 10; //len("7EPL03AL")
    int end = start + len-8;

    if(sof!="7E"){
      throw FormatException("Diagnostic Message: Invalid Start Of Frame");
    }

    if(_diagnosticResponse!="05"){
      throw FormatException("Diagnostic Message: Invalid Diagnostic Response Code");
    }




    for(int i=start; i<end;){

      String t = packet.substring(i,i+2);


      int l = int.parse(packet.substring(i+2,i+4));

      String val = packet.substring(i+4,i+4+l);

      String key = attributeName(t);

      double v; //int or double

      if(key == ""){
        throw FormatException("Diagnostic Message: Invalid Attribute Type");
      }

      if(l==4){

        v = int.parse(val,radix: 16).toDouble();
      }
      else{
        v = convert(val);
      }

      //print("t: $t, l: $l, v: $val");
      _settings[key] = v;

      i=i+4+l;
    }
    print(_settings);
    return _settings;
  }

  String attributeName(String t){


    if(t==DiagnosticResponse.speedRPM.hexVal){
      return DiagnosticResponse.speedRPM.name;
    }
    else if(t==DiagnosticResponse.signalVoltage.hexVal){
      return DiagnosticResponse.signalVoltage.name;
    }
    else{
      return "";
    }
  }
}