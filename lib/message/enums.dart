import 'package:hex/hex.dart';

import 'dart:typed_data';


enum Separator {
  sof,
  eof
}

extension SeparatorExtension on Separator{

  String get hexVal {
    switch (this){

      case Separator.sof:
        return "7E";
      case Separator.eof:
        return "7E";
    }
  }
}


enum MachineId{
  cardingMachine,
  drawFrame,
  flyer,
  ringFrame,

}

//ignore
extension MachineIdExtension on MachineId{

  String get hexVal {
    switch (this){

      case MachineId.cardingMachine:
        return "01";
      case MachineId.drawFrame:
        return "02";
      case MachineId.flyer:
        return "03";
      case MachineId.ringFrame:
        return "04";

    }
  }
}


enum MotorId{
  flyer,
  bobbin,
  frontRoller,
  backRoller,
  drafting,
  winding,
  lift,
  liftLeft,
  liftRight
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.flyer:
        return "01";
      case MotorId.bobbin:
        return "02";
      case MotorId.frontRoller:
        return "03";
      case MotorId.backRoller:
        return "04";
      case MotorId.drafting:
        return "05";
      case MotorId.winding:
        return "06";
      case MotorId.lift:
        return "07";
      case MotorId.liftLeft:
        return "08";
      case MotorId.liftRight:
        return "09";
    }
  }
}



enum Information {
  impaired,
  requestSettings,
  settingsFromApp,
  settingsToApp,
  diagnostics,
  diagnosticResponse,
  updateRTF,
  machineState,
}

extension InformationExtension on Information{

  String get hexVal {
    switch (this){

      case Information.impaired:
        return "99";
      case Information.settingsFromApp:
        return "01";
      case Information.settingsToApp:
        return "02";
      case Information.requestSettings:
        return "03";
      case Information.diagnostics:
        return "04";
      case Information.diagnosticResponse:
        return "05";
      case Information.machineState:
        return "06";
      case Information.updateRTF:
        return "07";

    }
  }
}



enum Substate{
  idle,
  running,
  pause,
  stop,
  homing,
  inching,
  error,
}

extension SubstateExtension on Substate{

  String get hexVal {
    switch (this){

      case Substate.idle:
        return "00";
      case Substate.running:
        return "01";
      case Substate.pause:
        return "02";
      case Substate.stop:
        return "03";
      case Substate.homing:
        return "04";
      case Substate.inching:
        return "05";
      default:
        return "06";
    }
  }
}


enum ControlType{
  closedLoop,
  openLoop,
}

extension ControlTypeExtension on ControlType{

  String get hexVal {
    switch (this){

      case ControlType.closedLoop:
        return "02";
      case ControlType.openLoop:
        return "01";
    }
  }
}




enum DiagnosticAttributeType{
  kindOfTest,
  motorID,
  motorDirection,
  targetPercent,
  testTime,
  bedDistance,
}

extension DiagnosticAttributeTypeExtension on DiagnosticAttributeType{

  String get hexVal {
    switch (this){

      case DiagnosticAttributeType.kindOfTest:
        return "41";
      case DiagnosticAttributeType.motorID:
        return "40";
      case DiagnosticAttributeType.motorDirection:
        return "44";
      case DiagnosticAttributeType.targetPercent:
        return "42";
      case DiagnosticAttributeType.testTime:
        return "43";
      case DiagnosticAttributeType.bedDistance:
        return "45";
    }
  }
}

enum SettingsAttribute{
  spindleSpeed,
  draft,
  twistPerInch,
  RTF,
  layers,
  maxHeightOfContent,
  rovingWidth,
  deltaBobbinDia,
  bareBobbinDia,
  rampupTime,
  rampdownTime,
  changeLayerTime,
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.spindleSpeed:
        return "50";
      case SettingsAttribute.draft:
        return "51";
      case SettingsAttribute.twistPerInch:
        return "52";
      case SettingsAttribute.RTF:
        return "53";
      case SettingsAttribute.layers:
        return "54";
      case SettingsAttribute.maxHeightOfContent:
        return "55";
      case SettingsAttribute.rovingWidth:
        return "56";
      case SettingsAttribute.deltaBobbinDia:
        return "57";
      case SettingsAttribute.bareBobbinDia:
        return "58";
      case SettingsAttribute.rampupTime:
        return "59";
      case SettingsAttribute.rampdownTime:
        return "60";
      case SettingsAttribute.changeLayerTime:
        return "61";
    }
  }
}

enum DiagnosticResponse{
  speedRPM,
  signalVoltage,
  current,
  power,
  lift,
}

extension DiagnosticResponseExtension on DiagnosticResponse{

  String get hexVal {
    switch (this){

      case DiagnosticResponse.speedRPM:
        return "01";
      case DiagnosticResponse.signalVoltage:
        return "02";
      case DiagnosticResponse.current:
        return "03";
      case DiagnosticResponse.power:
        return "04";
      case DiagnosticResponse.lift:
        return "05";
    }
  }
}

enum MotorDirection{
  defaultDirection,
  reverseDirection
}

extension MotorDirectionExtension on MotorDirection{

  String get hexVal {
    switch (this){

      case MotorDirection.defaultDirection:
        return "00";
      case MotorDirection.reverseDirection:
        return "01";
    }
  }
}
