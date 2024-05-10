import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../manager/generalmanager.dart';
import '../modal/status.dart';
import '../util/messageulti.dart';
import '../util/uimultilanguageutil.dart';
import 'currentbookingcontroller.dart';

class DisplayNameSourceBookingController extends ChangeNotifier {
  String displayOfBooking = '';
  String statusNameSource = "";
  bool isLoading = false;

  DisplayNameSourceBookingController() {
    displayOfBooking = GeneralManager.hotel!.showNameSource ==
            TypeNameSource.nameSource
        ? "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}"
        : GeneralManager.hotel!.showNameSource == TypeNameSource.name
            ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)
            : "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)}";
  }

  setNameSource(String value) {
    if (displayOfBooking == value) return;
    displayOfBooking = value;
    statusNameSource = displayOfBooking ==
            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}"
        ? TypeNameSource.nameSource
        : displayOfBooking ==
                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)}"
            ? TypeNameSource.sourceName
            : TypeNameSource.name;
    notifyListeners();
  }

  Future<String> updateShowNameOrNameSource() async {
    if (GeneralManager.hotel!.showNameSource == statusNameSource) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateshownamesource")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'show_namesource': statusNameSource,
    }).then((value) {
      isLoading = false;
      notifyListeners();
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      CurrentBookingsController().init();
      return value.data;
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      return (error as FirebaseFunctionsException).message;
    });
  }
}
