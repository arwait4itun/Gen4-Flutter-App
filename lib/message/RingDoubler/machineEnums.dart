
enum SettingsAttribute{
  inputYarn,
  spindleSpeed,
  twistPerInch,
  packageHeight,
  diaBuildFactor,
  windingClosenessFactor,

}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.inputYarn:
        return "90";
      case SettingsAttribute.spindleSpeed:
        return "91";
      case SettingsAttribute.twistPerInch:
        return "92";
      case SettingsAttribute.packageHeight:
        return "93";
      case SettingsAttribute.diaBuildFactor:
        return "94";
      case SettingsAttribute.windingClosenessFactor:
        return "95";
    }
  }
}

enum MotorId{
  calender,
  lift,
  liftLeft,
  liftRight,
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.calender:
        return "01";
      case MotorId.lift:
        return "07";
      case MotorId.liftLeft:
        return "08";
      case MotorId.liftRight:
        return "09";

    }
  }
}
