// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/modal/payment.dart';
import 'package:ihotel/util/messageulti.dart';

import '../handler/firebasehandler.dart';
import 'generalmanager.dart';

class PaymentMethodManager extends ChangeNotifier {
  static final PaymentMethodManager _instance =
      PaymentMethodManager._singleton();
  static const String cashMethodID = 'ca';
  static const String bankMethodID = 'ba';
  static const String cardMethodID = 'cc';

  static const String statusOpen = 'open';
  static const String statusPass = 'passed';
  static const String statusFailed = 'failed';

  static const String transferMethodID = 'transfer';
  PaymentMethodManager._singleton();
  List<Payment> paymentMethodsActive = [];
  List<Payment> paymentMethods = [];
  bool isLoading = false;
  bool isStreaming = false;
  StreamSubscription? streamSubscription;
  TextEditingController? teId;
  TextEditingController? teName;
  List<TextEditingController> teStatus =
      List.generate(6, (index) => TextEditingController());
  Payment? payment;

  factory PaymentMethodManager() {
    return _instance;
  }

  factory PaymentMethodManager.addPayment(Payment? payment) {
    if (payment != null) {
      int count = 0;
      for (var item in payment.status!) {
        _instance.teStatus[count] = (TextEditingController(
            text: payment != null ? item.toString() : ''));
        count++;
      }
      _instance.payment = payment;
      _instance.teId = TextEditingController(text: payment.id);
      _instance.teName = TextEditingController(text: payment.name);
    } else {
      for (var i = 0; i < 6; i++) {
        if (i == 0 || i == 1 || i == 2) {
          _instance.teStatus[0] = (TextEditingController(text: 'open'));
          _instance.teStatus[1] = (TextEditingController(text: 'passed'));
          _instance.teStatus[2] = (TextEditingController(text: 'failed'));
        } else {
          _instance.teStatus[i] = (TextEditingController(text: ''));
        }
      }
      _instance.teId = TextEditingController(text: '');
      _instance.teName = TextEditingController(text: '');
    }
    return _instance;
  }

  Future<void> updatePaymentMothed() async {
    await getConfigurationFromCloud();
  }

  getConfigurationFromCloud() {
    try {
      if (isStreaming) return;
      isStreaming = true;
      print('asyncPaymentMethodManager: Init');
      streamSubscription?.cancel();
      streamSubscription = FirebaseFirestore.instance
          .collection('hotels')
          .doc(GeneralManager.hotelID)
          .collection(FirebaseHandler.colManagement)
          .doc('payment_methods')
          .snapshots()
          .listen((snapshots) {
        if (snapshots.exists) {
          update(snapshots.get('data'));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void cancelStream() {
    streamSubscription?.cancel();
    isStreaming = false;
    print('asyncPaymentMethodManager: Cancelled');
  }

  void update(Map<String, dynamic> data) {
    paymentMethods.clear();
    paymentMethodsActive.clear();
    for (var item in data.entries) {
      final Payment payment = Payment.fromJson(item.key, item.value);
      if (!payment.isDelete!) {
        paymentMethodsActive.add(payment);
      }
      paymentMethods.add(payment);
    }
    paymentMethods.sort(((a, b) => a.id!.compareTo(b.id!)));
    paymentMethodsActive.sort(((a, b) => a.id!.compareTo(b.id!)));
    isLoading = false;
    notifyListeners();
  }

  Future<String?> deletePayment(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('payment-deletePayment');
      await callable({
        'payment_method_id': id,
        'hotel_id': GeneralManager.hotelID,
      });
      return MessageCodeUtil.SUCCESS;
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }

  Future<String?> addPayment() async {
    isLoading = true;
    notifyListeners();
    final paymentData = {
      'hotel_id': GeneralManager.hotelID,
      'payment_method_id': payment != null ? payment!.id : teId!.text,
      'payment_method_name': teName!.text,
      'payment_method_status': teStatus
          .map((e) => e.text)
          .where((element) => element != '')
          .toList(),
    };
    HttpsCallable callable;
    try {
      if (payment != null) {
        callable =
            FirebaseFunctions.instance.httpsCallable('payment-editPayment');
      } else {
        callable =
            FirebaseFunctions.instance.httpsCallable('payment-createPayment');
      }
      await callable(paymentData);
      return MessageCodeUtil.SUCCESS;
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }

  List<String> getPaymentMethodName() =>
      paymentMethods.map((e) => e.name!).toList();

  List<String> getPaymentActiveMethodName() =>
      paymentMethodsActive.map((e) => e.name!).toList();

  List<String?> getPaymentMethodId() =>
      paymentMethods.map((e) => e.id).toList();

  List<String?> getPaymentActiveMethodId() =>
      paymentMethodsActive.map((e) => e.id).toList();

  String getPaymentMethodNameById(String paymentMethodId) =>
      paymentMethods.firstWhere((e) => e.id == paymentMethodId).name ?? "";

  String? getPaymentMethodIdByName(String paymentMethodName) =>
      paymentMethods.firstWhere((e) => e.name == paymentMethodName).id;

  List<String>? getStatusByPaymentID(String paymentID) => paymentMethods
      .firstWhere((e) => e.id == paymentID)
      .status
      ?.map((e) => e.toString())
      .toList();
}
