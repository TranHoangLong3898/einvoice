import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/modal/discount.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../modal/booking.dart';

class DiscountController extends ChangeNotifier {
  StreamSubscription? streamSubscription;
  Booking? booking;
  Discount? discountOfBooking;
  late bool isLoading;
  bool? isBookingGroup;

  DiscountController({this.booking, this.isBookingGroup}) {
    isLoading = true;
    notifyListeners();
    initialize();
  }

  void initialize() async {
    streamSubscription?.cancel();
    streamSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(booking!.id!)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data()!.containsKey('discount')) {
        discountOfBooking = Discount(
            total: snapshot.get('discount.total') ?? 0,
            discountDetail: snapshot.get('discount.details') ?? {});
      } else {
        discountOfBooking = null;
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void cancel() {
    streamSubscription?.cancel();
  }

  Future<String> deleteDiscountOfBooking(String discountId) async {
    if (isLoading) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isLoading = true;
    notifyListeners();
    String result = await booking!
        .deleteDiscount(discountId)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    isLoading = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class AddDiscountController extends ChangeNotifier {
  TextEditingController? amountController;
  late TextEditingController descController;

  Booking? booking;
  dynamic discountDetail;
  String? discountId;

  late num oldDiscountAmount;
  late String oldDiscountDesc;

  bool saving = false;

  late bool isAddingFeature;

  AddDiscountController({this.booking, this.discountDetail, this.discountId}) {
    if (discountDetail == null && discountId == null) {
      isAddingFeature = true;
      amountController = TextEditingController(text: '');
      descController = TextEditingController(text: '');
    } else {
      isAddingFeature = false;
      oldDiscountAmount = discountDetail['amount'];
      oldDiscountDesc = discountDetail['desc'];
      amountController =
          TextEditingController(text: oldDiscountAmount.toString());
      descController = TextEditingController(text: oldDiscountDesc);
    }
  }

  Future<String> saveDiscount() async {
    if (descController.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_DESCRIPTION);
    }
    num? amount = num.tryParse(amountController!.text.replaceAll(',', ''));
    amount ??= -1;
    if (amount <= 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INPUT_POSITIVE_AMOUNT);
    }
    final desc = descController.text;
    if (saving) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    saving = true;
    notifyListeners();
    String result;
    if (isAddingFeature) {
      result = await booking!
          .addDiscount(amount, desc)
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    } else {
      if (oldDiscountAmount == amount && oldDiscountDesc == desc) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
      }
      result = await booking!
          .updateDiscount(amount, desc, discountId!)
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    }
    saving = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
