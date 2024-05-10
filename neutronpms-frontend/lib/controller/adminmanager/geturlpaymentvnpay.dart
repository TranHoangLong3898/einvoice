import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/manager/generalmanager.dart';

class GetUrlPaymentVNpay extends ChangeNotifier {
  bool isLoading = false;
  String textLinkIOS = "";

  void setLinksIOS(String value) {
    textLinkIOS = value;
    notifyListeners();
  }

  Future<String> getUrlPaymentVNPay() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable("vnpaypayment-PayemntVnPay")
        .call({
      'hotel_id': GeneralManager.hotelID,
    }).then((value) {
      isLoading = false;
      notifyListeners();
      return value.data;
    }).onError((error, stackTrace) {
      isLoading = false;
      notifyListeners();
      return (error as FirebaseFunctionsException).code;
    });
  }
}
