
enum SettingsAttribute{
  deliverySpeed,
  draft,
  cylSpeed,
  btrSpeed,
  cylFeedSpeed,
  btrFeedSpeed,
  trunkDelay,
  lengthLimit,
  rampTimes,
}

extension SettingsAttributeTypeExtension on SettingsAttribute{

  String get hexVal {
    switch (this){
      case SettingsAttribute.deliverySpeed:
        return "80";
      case SettingsAttribute.draft:
        return "81";
      case SettingsAttribute.cylSpeed:
        return "82";
      case SettingsAttribute.cylFeedSpeed:
        return "83";
      case SettingsAttribute.btrSpeed:
        return "84";
      case SettingsAttribute.btrFeedSpeed:
        return "85";
      case SettingsAttribute.trunkDelay:
        return "86";
      case SettingsAttribute.lengthLimit:
        return "87";
      case SettingsAttribute.rampTimes:
        return "88";
    }
  }
}


enum MotorId{
  cylinder,
  beater,
  cage,
  cylinderFeed,
  beaterFeed,
  coiler,
}

extension MotorIdExtension on MotorId{

  String get hexVal {
    switch (this){

      case MotorId.cylinder:
        return "01";
      case MotorId.beater:
        return "02";
      case MotorId.cage:
        return "03";
      case MotorId.cylinderFeed:
        return "04";
      case MotorId.beaterFeed:
        return "05";
      case MotorId.coiler:
        return "06";
    }
  }
}
