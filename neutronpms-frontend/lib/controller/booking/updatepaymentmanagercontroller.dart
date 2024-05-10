import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../modal/service/deposit.dart';

class UpdatePaymentManagerController extends ChangeNotifier {
  final Deposit deposit;
  late String methodID;
  late String oldMethod;
  late num oldDeposit;
  late String oldDesc;
  late TextEditingController teDesc;
  late TextEditingController teAmount;
  late TextEditingController teNote;
  late TextEditingController teActualAmount;
  late TextEditingController teReferenceNumber;
  DateTime? referencDate, oldreferencDate;
  bool isLoading = false;
  final DateTime now = Timestamp.now().toDate();
  num? oldActualAmount;
  String? oldNote, oldReferenceNumber;
  List<String> methodNames = [];

  UpdatePaymentManagerController({required this.deposit}) {
    methodNames = PaymentMethodManager()
        .getPaymentActiveMethodName()
        .where((element) => element != "Transfer")
        .toList();

    teDesc = TextEditingController(text: deposit.desc);
    teAmount = TextEditingController(text: deposit.amount.toString());
    teActualAmount =
        TextEditingController(text: deposit.actualAmount.toString());
    teNote = TextEditingController(text: deposit.note);
    teReferenceNumber = TextEditingController(text: deposit.referenceNumber);
    referencDate = deposit.referencDate;
    oldActualAmount = deposit.actualAmount;
    oldNote = deposit.note;
    oldReferenceNumber = deposit.referenceNumber;
    oldreferencDate = deposit.referencDate;
    methodID = deposit.method!;
    oldMethod = deposit.method!;
    oldDeposit = deposit.amount!;
    oldDesc = deposit.desc!;
  }

  void setMethodID(String methodName) {
    if (PaymentMethodManager().getPaymentMethodIdByName(methodName) !=
        methodID) {
      methodID = PaymentMethodManager().getPaymentMethodIdByName(methodName)!;

      notifyListeners();
    }
  }

  void setReferencDate(DateTime newDate) {
    if (referencDate != null && DateUtil.equal(newDate, referencDate!)) return;
    referencDate = newDate;
    notifyListeners();
  }

  Future<String> updateDeposit() async {
    final newDeposit = num.tryParse(teAmount.text.replaceAll(',', ''));
    final newactualAmount =
        num.tryParse(teActualAmount.text.replaceAll(',', ''));
    if (newDeposit == oldDeposit &&
        teDesc.text == oldDesc &&
        newactualAmount == oldActualAmount &&
        teNote.text == oldNote &&
        methodID == oldMethod &&
        teReferenceNumber.text == oldReferenceNumber &&
        oldreferencDate == referencDate) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }
    isLoading = true;
    notifyListeners();
    deposit.setAmount(newDeposit ?? 0);
    deposit.setDesc(teDesc.text);
    deposit.setMethod(methodID);
    deposit.setActualAmount(newactualAmount ?? 0);
    deposit.setNote(teNote.text);
    deposit.setReferenceNumber(teReferenceNumber.text);
    deposit.setReferencDate(referencDate);

    final result = await deposit.updatePaymentManager();
    isLoading = false;
    notifyListeners();
    return result;
  }
}
