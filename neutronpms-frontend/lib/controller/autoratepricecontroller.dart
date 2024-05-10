import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';

class AutoRatePriceController extends ChangeNotifier {
  late bool autoRate;
  bool isLoading = false;

  AutoRatePriceController() {
    autoRate = GeneralManager.hotel!.autoRate!;
  }

  setAutoRate(bool value) {
    if (autoRate == value) return;
    autoRate = value;
    notifyListeners();
  }

  Future<String> updateAutoRoomAssignment() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateautorate")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'auto_rate': autoRate,
    }).then((value) {
      isLoading = false;
      notifyListeners();
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      return value.data;
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      return (error as FirebaseFunctionsException).message;
    });
  }
}
