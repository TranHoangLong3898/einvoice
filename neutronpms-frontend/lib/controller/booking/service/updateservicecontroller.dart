import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../manager/generalmanager.dart';

abstract class UpdateServiceController extends ChangeNotifier {
  bool? updating = false, isLoading = false, isCheckEmail = false;

  //set keys and values of oldItem (oldItems are the items still not been changed)
  void saveOldItems();

  //get list types of service
  List<String>? getServiceItems();

  // return true if user changed amount of items in minibar
  // return false if user changed nothing
  bool? isServiceItemsChanged();

  void updateService();

  Future<String>? updateServiceToDatabase();

  void setProgressUpdating() {
    updating = true;
    notifyListeners();
  }

  void setProgressDone() {
    updating = false;
    notifyListeners();
  }

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
