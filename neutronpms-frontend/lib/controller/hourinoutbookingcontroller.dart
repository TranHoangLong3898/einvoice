import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/status.dart';

import '../util/uimultilanguageutil.dart';

class HourInOutBookingMonthlyController extends ChangeNotifier {
  late int hourBookingMonthly;
  bool isLoading = false;
  List<String> listHourInOut = [
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOUR_IN_OUT_DEFAULT),
    UITitleUtil.getTitleByCode(UITitleCode.ABLEHEADER_HOUR_IN_OUT_MONTHLY),
  ];
  String selectHurInOut = "";

  HourInOutBookingMonthlyController() {
    hourBookingMonthly = GeneralManager.hotel!.hourBookingMonthly!;
    selectHurInOut = getStringInOut();
  }

  String getStringInOut() {
    switch (hourBookingMonthly) {
      case BookingInOutByHour.monthly:
        return UITitleUtil.getTitleByCode(
            UITitleCode.ABLEHEADER_HOUR_IN_OUT_MONTHLY);
      default:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_HOUR_IN_OUT_DEFAULT);
    }
  }

  int getStatusInOut() {
    if (UITitleUtil.getTitleByCode(
            UITitleCode.ABLEHEADER_HOUR_IN_OUT_MONTHLY) ==
        selectHurInOut) {
      return BookingInOutByHour.monthly;
    } else {
      return BookingInOutByHour.defaul;
    }
  }

  setHourBookingMontnly(String value) {
    if (selectHurInOut == value) return;
    selectHurInOut = value;
    hourBookingMonthly = getStatusInOut();
    notifyListeners();
  }

  Future<String> updateHourInOutBookingMonthly() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateHourBookingMontnly")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'hour_bookingmonthly': hourBookingMonthly,
    }).then((value) {
      isLoading = false;
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      GeneralManager.hotel!.hourBookingMonthly = hourBookingMonthly;
      notifyListeners();
      return value.data;
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      return (error as FirebaseFunctionsException).message;
    });
  }
}
