
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
  coneAngleFactor,
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
      case SettingsAttribute.coneAngleFactor:
        return "62";
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
  liftRight,
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
