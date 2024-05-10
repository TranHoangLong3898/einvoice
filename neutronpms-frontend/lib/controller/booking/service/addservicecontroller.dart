import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../manager/generalmanager.dart';

abstract class AddServiceController extends ChangeNotifier {
  bool isLoading = false, isCheckEmail = false;

  void setEmailSaler(String value, String emailOld) {
    isCheckEmail = value == emailOld;
    notifyListeners();
  }

  void checkEmailExists(String teSaler) async {
    if (teSaler.isNotEmpty) {
      isLoading = true;
      notifyListeners();
      await FirebaseFunctions.instance
          .httpsCallable('booking-getUsersInHotel')
          .call({'hotel_id': GeneralManager.hotelID, 'email': teSaler}).then(
              (value) {
        isCheckEmail = (value.data as bool);
        isLoading = false;
        notifyListeners();
      }).onError((error, stackTrace) {
        isLoading = false;
        isCheckEmail = false;
        notifyListeners();
      });
    }
  }
}
