
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