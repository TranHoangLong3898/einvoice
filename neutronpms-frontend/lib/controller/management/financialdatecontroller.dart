import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../manager/generalmanager.dart';

class FinancialDateController extends ChangeNotifier {
  DateTime? now, date;
  late bool isLoading;

  FinancialDateController() {
    isLoading = false;
    now = GeneralManager.hotel!.financialDate!;
    date = now;
  }

  void setDate(DateTime value) {
    if (date == value) return;
    date = value;
    notifyListeners();
  }

  Future<String> updateFinancialDate() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateFinancialDate')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'date': date != null ? date.toString() : '',
    }).then((value) {
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      return value.data;
    }).onError((error, stackTrace) {
      print(error);

      return (error as FirebaseFunctionsException).message;
    }).whenComplete(() {
      isLoading = false;
      notifyListeners();
    });
  }
}
