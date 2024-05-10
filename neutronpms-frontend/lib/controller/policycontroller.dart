import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../manager/generalmanager.dart';

class PolicyController extends ChangeNotifier {
  String policy = '';
  bool isLoading = false;

  PolicyController() {
    policy = GeneralManager.hotel!.policy!;
  }

  Future<String> addPolicy(String value) async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-addPolicyHotel")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'img': value,
    }).then((values) async {
      policy = value;
      isLoading = false;
      notifyListeners();
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      return values.data;
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      return (error as FirebaseFunctionsException).message;
    });
  }
}
