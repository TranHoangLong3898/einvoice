import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class DepositRefundController extends ChangeNotifier {
  TextEditingController? noteTeController, sidTeController;
  NeutronInputNumberController? amountInput;
  DateTime? createTime;
  String? paymentMethod, id;
  bool isLoading = false;
  BookingDeposit deposit;
  bool isAddRefunf;
  bool transferBooking;
  DepositRefundController(
      this.deposit, this.isAddRefunf, this.transferBooking) {
    id = deposit.id;
    paymentMethod = isAddRefunf ? UITitleCode.NO : deposit.paymentMethod;
    noteTeController =
        TextEditingController(text: isAddRefunf ? "" : deposit.note);
    createTime = isAddRefunf ? DateTime.now() : deposit.createTime;
    sidTeController = TextEditingController(text: deposit.sid);
    amountInput = NeutronInputNumberController(TextEditingController(
        text: isAddRefunf
            ? deposit.remain.toString()
            : deposit.amount.toString()));
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

  Future<String> updateRefundDeposit() async {
    final double newAmount = double.tryParse(
            amountInput!.controller.text.trim().replaceAll(RegExp(','), '')) ??
        0;
    if (newAmount <= 0) {
      return MessageCodeUtil.TEXTALERT_MONEY_AMOUNT_MUST_BE_POSITIVE;
    }
    if (paymentMethod == UITitleCode.NO && !transferBooking) {
      return MessageCodeUtil.PAYMENT_METHOD_CAN_NOT_BE_EMPTY;
    }

    isLoading = true;
    notifyListeners();
    String result;
    if (isAddRefunf) {
      result = await FirebaseFunctions.instance
          .httpsCallable('bookingdeposit-addRefundDeposit')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'sid': sidTeController?.text.trim(),
            'create': createTime.toString(),
            'payment_method':
                transferBooking ? "transferdeposit" : paymentMethod,
            'amount': newAmount,
            'name': deposit.name,
            'note': noteTeController!.text.trim(),
            'id_deposit': deposit.id,
          })
          .then((value) => value.data)
          .onError((error, stackTrace) {
            print(error);
            return (error as FirebaseFunctionsException).message;
          });
    } else {
      if (transferBooking) {
        result = await FirebaseFunctions.instance
            .httpsCallable('bookingdeposit-updateTransferDeposit')
            .call({
              'hotel_id': GeneralManager.hotelID,
              'amount': newAmount,
              'note': noteTeController!.text.trim(),
              'id_deposit': deposit.id,
              'sid': sidTeController!.text.trim()
            })
            .then((value) => value.data)
            .onError((error, stackTrace) {
              print(error);
              return (error as FirebaseFunctionsException).message;
            });
      } else {
        result = await FirebaseFunctions.instance
            .httpsCallable('bookingdeposit-updateRefundDeposit')
            .call({
              'hotel_id': GeneralManager.hotelID,
              'sid': sidTeController?.text.trim(),
              'create': createTime.toString(),
              'payment_method': paymentMethod,
              'amount': newAmount,
              'name': deposit.name,
              'note': noteTeController!.text.trim(),
              'id_deposit': deposit.id,
            })
            .then((value) => value.data)
            .onError((error, stackTrace) {
              print(error);
              return (error as FirebaseFunctionsException).message;
            });
      }
    }
    isLoading = false;
    notifyListeners();
    return result;
  }
}
