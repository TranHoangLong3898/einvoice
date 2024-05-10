import 'dart:collection';

import 'package:ihotel/modal/hotelservice/hotelservice.dart';

class RoomExtraHotelService extends HotelService {
  num? adultPrice;
  num? childPrice;
  SplayTreeMap<String, num>? earlyCheckIn;
  SplayTreeMap<String, num>? lateCheckOut;
  RoomExtraHotelService({
    this.adultPrice,
    this.childPrice,
    this.earlyCheckIn,
    this.lateCheckOut,
  }) : super(type: 'room_extra');

  factory RoomExtraHotelService.fromMap(dynamic doc) {
    num adultPriceInCloud = doc['adult'] ?? 0;
    num childPriceInCloud = doc['child'] ?? 0;
    SplayTreeMap<String, num> earlyCheckinInCloud =
        SplayTreeMap((a, b) => num.parse(a).compareTo(num.parse(b)));
    SplayTreeMap<String, num> lateCheckinInCloud =
        SplayTreeMap((a, b) => num.parse(a).compareTo(num.parse(b)));

    if (doc['early_check_in'] != null) {
      (doc['early_check_in'] as Map).forEach((key, value) {
        earlyCheckinInCloud[key] = value;
      });
    }
    if (doc['late_check_out'] != null) {
      (doc['late_check_out'] as Map).forEach((key, value) {
        lateCheckinInCloud[key] = value;
      });
    }

    return RoomExtraHotelService(
        adultPrice: adultPriceInCloud,
        childPrice: childPriceInCloud,
        earlyCheckIn: earlyCheckinInCloud,
        lateCheckOut: lateCheckinInCloud);
  }

  RoomExtraHotelService.empty({this.adultPrice = 0, this.childPrice = 0}) {
    earlyCheckIn = SplayTreeMap((a, b) => num.parse(a).compareTo(num.parse(b)));
    lateCheckOut = SplayTreeMap((a, b) => num.parse(a).compareTo(num.parse(b)));
  }
}
