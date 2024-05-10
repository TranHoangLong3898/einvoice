import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/paymentpackageversion.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';

class AddPaymentPackageController extends ChangeNotifier {
  TextEditingController? teDesc;
  bool isLoading = false;
  bool isStillInDebt = false;
  String selectMethod = "";

  List<String> listMedthod =
      PaymentMethodManager().getPaymentActiveMethodName();

  late NeutronInputNumberController teStillInDebt;
  PaymentPackageVersion? paymentPackageVersion;
  num? stillInDebtOld;
  String? descOld, methodOld;

  AddPaymentPackageController(this.paymentPackageVersion) {
    teStillInDebt = NeutronInputNumberController(TextEditingController(
        text: paymentPackageVersion?.stillInDebt.toString() ?? "0"));
    teDesc = TextEditingController(text: paymentPackageVersion?.desc ?? "");
    selectMethod = paymentPackageVersion != null
        ? PaymentMethodManager()
            .getPaymentMethodNameById(paymentPackageVersion!.method!)
        : PaymentMethodManager().getPaymentActiveMethodName().first;
    if (paymentPackageVersion != null) {
      stillInDebtOld = paymentPackageVersion?.stillInDebt;
      descOld = paymentPackageVersion?.desc;
      methodOld = PaymentMethodManager()
          .getPaymentMethodNameById(paymentPackageVersion!.method!);
    }
    notifyListeners();
  }

  void setPackageVersion(String value) {
    if (selectMethod == value) return;
    selectMethod = value;
    notifyListeners();
  }

  void setStillInDebt() {
    isStillInDebt = !isStillInDebt;
    notifyListeners();
  }

  Future<String> updatePackageVersion() async {
    if (teDesc!.text.isEmpty) {
      return MessageCodeUtil.INPUT_DESCRIPTION;
    }

    isLoading = true;
    notifyListeners();
    String result;
    if (paymentPackageVersion != null) {
      if (stillInDebtOld == double.parse(teStillInDebt.getRawString()) &&
          descOld == teDesc!.text &&
          methodOld == selectMethod) {
        isLoading = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await FirebaseFunctions.instance
          .httpsCallable('hotelmanager-updatePaymentPackageVersion')
          .call({
        'id_payment': paymentPackageVersion!.id,
        "hotel_id": GeneralManager.hotelID,
        "method": PaymentMethodManager().getPaymentMethodIdByName(selectMethod),
        "desc": teDesc!.text,
        'still_indebt': double.parse(teStillInDebt.getRawString()),
      }).then((value) {
        return value.data;
      }).onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    } else {
      result = await FirebaseFunctions.instance
          .httpsCallable('hotelmanager-addPaymentPackageVersion')
          .call({
        "hotel_id": GeneralManager.hotelID,
        "method": PaymentMethodManager().getPaymentMethodIdByName(selectMethod),
        "desc": teDesc!.text,
        'still_indebt': double.parse(teStillInDebt.getRawString()),
        'isstill_indebt': isStillInDebt,
      }).then((value) {
        return value.data;
      }).onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    }

    isLoading = false;
    notifyListeners();
    return result;
  }
}
