import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/roomextrahotelservice.dart';

class RoomExtraManager {
  RoomExtraHotelService? roomExtraConfigs;

  static final RoomExtraManager _instance = RoomExtraManager._singleton();
  RoomExtraManager._singleton();
  factory RoomExtraManager() {
    return _instance;
  }

  void update() {
    roomExtraConfigs = ConfigurationManagement().roomExtra;
  }

  num getEarlyCheckInPercentByHours(num hours) {
    try {
      if (hours == 0) return 0;
      return roomExtraConfigs?.earlyCheckIn![roomExtraConfigs!
              .earlyCheckIn!.keys
              .firstWhere((time) => hours <= num.tryParse(time)!)] ??
          0;
    } catch (e) {
      return 1;
    }
  }

  num getLateCheckOutPercentByHours(num hours) {
    try {
      if (hours == 0) return 0;

      return roomExtraConfigs!.lateCheckOut![roomExtraConfigs!
              .lateCheckOut!.keys
              .firstWhere((time) => hours <= num.tryParse(time)!)] ??
          1;
    } catch (e) {
      return 1;
    }
  }

  num getExtraGuestPrice(String type) {
    if (type == 'adult') return roomExtraConfigs!.adultPrice ?? 0;
    if (type == 'child') return roomExtraConfigs!.childPrice ?? 0;
    return 0;
  }
}
