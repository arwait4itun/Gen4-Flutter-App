
enum SettingsAttribute{
  deliverySpeed,
  draft,
  lengthLimit,
  rampUpTime,
  rampDownTime
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.deliverySpeed:
        return "70";
      case SettingsAttribute.draft:
        return "71";
      case SettingsAttribute.lengthLimit:
        return "72";
      case SettingsAttribute.rampUpTime:
        return "73";
      case SettingsAttribute.rampDownTime:
        return "74";
    }
  }
}


enum MotorId{
  frontRoller,
  backRoller,
  creel,
  drafting,
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.frontRoller:
        return "01";
      case MotorId.backRoller:
        return "02";
      case MotorId.creel:
        return "03";
      case MotorId.drafting:
        return "05";
    }
  }
}
