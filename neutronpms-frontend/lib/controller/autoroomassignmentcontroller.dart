import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../manager/generalmanager.dart';

class AutoRoomAssignmentController extends ChangeNotifier {
  late bool autoRoomAssignment;
  bool isLoading = false;

  AutoRoomAssignmentController() {
    autoRoomAssignment = GeneralManager.hotel!.autoRoomAssignment!;
  }

  setNameSource(bool value) {
    if (autoRoomAssignment == value) return;
    autoRoomAssignment = value;
    notifyListeners();
  }

  Future<String> updateAutoRoomAssignment() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateautoroonassignment")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'auto_roon_assignment': autoRoomAssignment,
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
