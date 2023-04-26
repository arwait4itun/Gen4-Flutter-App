library my_prj.globals;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool isRecording = false;
bool isConnected = false;
bool pidEnabled = false;
bool isListening = false;
BluetoothDevice? selectedDevice;

String password = "7110eda4d09e062aa5e4a390b0a572ac0d2c0220";

Map<String,List> settingsLimits = {

   "spindleSpeed":[500,1000],
   "draft":[5,9.9],
   "twistPerInch":[1,1.6],
   "RTF":[0.25,2],
   "lengthLimit":[100,6000],
   "maxHeightOfContent":[250,300],
   "rovingWidth":[1,4],
   "deltaBobbinDia":[1,2.5],
   "bareBobbinDia":[46,52],
   "rampupTime":[5,20],
   "rampdownTime":[5,20],
   "changeLayerTime": [200,2500],
};