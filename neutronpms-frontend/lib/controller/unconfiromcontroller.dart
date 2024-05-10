import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../manager/generalmanager.dart';

class UnconfirmController extends ChangeNotifier {
  late bool unconfirmed;
  bool isLoading = false;

  UnconfirmController() {
    unconfirmed = GeneralManager.hotel!.unconfirmed!;
  }

  setNameSource(bool value) {
    if (unconfirmed == value) return;
    unconfirmed = value;
    notifyListeners();
  }

  Future<String> updateAutoRoomAssignment() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateunconfirm")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'unconfirmed': unconfirmed,
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
