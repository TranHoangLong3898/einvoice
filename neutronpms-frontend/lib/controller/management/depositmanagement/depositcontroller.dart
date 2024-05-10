import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class DepositController extends ChangeNotifier {
  TextEditingController? sidTeController, noteTeController, teName, teRemain;
  String? paymentMethod, id;
  int? status;
  NeutronInputNumberController? amountInput;
  DateTime? createTime;
  List<DepositHistory>? history;
  bool isAddFeature = true, isLoading = false;
  BookingDeposit? oldDeposit;
  DepositController(BookingDeposit? deposit) {
    if (deposit == null) {
      isAddFeature = true;
      amountInput =
          NeutronInputNumberController(TextEditingController(text: ''));
      sidTeController = TextEditingController(text: '');
      noteTeController = TextEditingController(text: '');
      teName = TextEditingController(text: '');
      id = NumberUtil.getRandomString(8);
      paymentMethod = UITitleCode.NO;
      createTime = DateTime.now();
      history = [];
      status = DepositStatus.DEPOSIT;
    } else {
      isAddFeature = false;
      oldDeposit = deposit;
      id = deposit.id;
      sidTeController = TextEditingController(text: deposit.sid);
      noteTeController = TextEditingController(text: deposit.note);
      teName = TextEditingController(text: deposit.name);
      teRemain = TextEditingController(text: deposit.remain.toString());
      paymentMethod = deposit.paymentMethod;
      createTime = deposit.createTime;
      history = deposit.history;
      status = deposit.status;
      amountInput = NeutronInputNumberController(
          TextEditingController(text: deposit.amount.toString()));
    }
  }

  void setEndDate(DateTime newTime) {
    createTime = newTime;
    notifyListeners();
  }

  void setPaymentMethod(String newValue) {
    if (newValue == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
      paymentMethod = UITitleCode.NO;
    } else {
      paymentMethod = PaymentMethodManager().getPaymentMethodIdByName(newValue);
    }
    notifyListeners();
  }

  void setStatus(String value) {
    status = value == UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEPOSIT)
        ? DepositStatus.DEPOSIT
        : DepositStatus.REFUND;
    notifyListeners();
  }

  Future<String> updateDeposit() async {
    final String newSid = sidTeController!.text.trim();
    final double newAmount = double.tryParse(
            amountInput!.controller.text.trim().replaceAll(RegExp(','), '')) ??
        0;
    String result;
    if (newSid == '') {
      return MessageCodeUtil.SID_CAN_NOT_BE_EMPTY;
    }
    if (teName!.text.isEmpty || teName!.text == '') {
      return MessageCodeUtil.INPUT_NAME;
    }
    if (newSid.contains("/")) {
      return MessageCodeUtil.SID_MUST_NOT_CONTAIN_SPECIFIC_CHAR;
    }
    if (newAmount <= 0) {
      return MessageCodeUtil.TEXTALERT_MONEY_AMOUNT_MUST_BE_POSITIVE;
    }
    if (paymentMethod == UITitleCode.NO) {
      return MessageCodeUtil.PAYMENT_METHOD_CAN_NOT_BE_EMPTY;
    }
    isLoading = true;
    notifyListeners();
    if (isAddFeature) {
      result = await FirebaseFunctions.instance
          .httpsCallable('bookingdeposit-addBookingDeposit')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'sid': newSid,
            'create': createTime.toString(),
            'payment_method': paymentMethod,
            'amount': newAmount,
            'name': teName!.text.trim(),
            'deposit_status': status,
            'note': noteTeController!.text.trim()
          })
          .then((value) => value.data)
          .onError((error, stackTrace) {
            print(error);
            return (error as FirebaseFunctionsException).message;
          });
    } else {
      BookingDeposit newDeposit = BookingDeposit(
          id: id!,
          amount: newAmount,
          sid: newSid,
          name: teName!.text.trim(),
          paymentMethod: paymentMethod!,
          createTime: createTime!,
          status: status!,
          note: noteTeController!.text.trim(),
          history: oldDeposit!.history);
      // if (newDeposit == oldDeposit) {
      //   return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      // }
      if (oldDeposit!.isCanNotUpdate(newDeposit)) {
        return MessageCodeUtil.CAN_NOT_CHANGE_DATA_AND_STATUS_AT_THE_SAME_TIME;
      }
      result = await FirebaseFunctions.instance
          .httpsCallable('bookingdeposit-updateBookingDeposit')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'sid': newSid,
            'name': teName!.text.trim(),
            'create': createTime.toString(),
            'id_deposit': id,
            'payment_method': paymentMethod,
            'amount': newAmount,
            'deposit_status': status,
            'note': noteTeController!.text.trim()
          })
          .then((value) => value.data)
          .onError((error, stackTrace) {
            print(error);
            return (error as FirebaseFunctionsException).message;
          });
    }
    isLoading = false;
    notifyListeners();
    return result;
  }
}
