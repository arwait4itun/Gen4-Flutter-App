import 'enums.dart';

class Acknowledgement {

  String createPacket({bool error=false}){

    String s = error?"00":"01";

    return Separator.sof.hexVal+s+Separator.eof.hexVal;
  }
}
