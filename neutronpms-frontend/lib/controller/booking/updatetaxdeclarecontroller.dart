import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/modal/booking.dart';

import '../../manager/generalmanager.dart';

class UpdateTaxDeclareController extends ChangeNotifier {
  late Booking booking;
  late bool isLoading, selectedStatus;

  UpdateTaxDeclareController(this.booking) {
    isLoading = false;
    selectedStatus = booking.isTaxDeclare!;
  }

  setNewStatus(bool newStatus) => selectedStatus = newStatus;

  Future<String> update() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('booking-updateTaxDeclare')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': booking.id,
          'booking_sid': booking.sID,
          'is_group': booking.group,
          'tax_declare': selectedStatus,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }
}
