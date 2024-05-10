// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/rateplan.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/generalmanager.dart';

class AddRatePlanController extends ChangeNotifier {
  bool isLoading = false;
  late TextEditingController title;
  late TextEditingController teAmount;
  late TextEditingController teDecs;
  late bool isPercent;
  late bool isAddFeature;

  late String idRatePlan;

  AddRatePlanController(RatePlan? ratePlan) {
    if (ratePlan == null) {
      isAddFeature = true;
      idRatePlan = '';
      teAmount = TextEditingController(text: '');
      isPercent = false;
      title = TextEditingController(text: '');
      teDecs = TextEditingController(text: '');
    } else {
      isAddFeature = false;
      idRatePlan = (ratePlan != null ? ratePlan.title : '')!;
      teAmount = TextEditingController(
          text: ratePlan != null ? ratePlan.amount.toString() : '');
      isPercent = (ratePlan != null ? ratePlan.percent : false)!;
      title =
          TextEditingController(text: ratePlan != null ? ratePlan.title : '');
      teDecs =
          TextEditingController(text: ratePlan != null ? ratePlan.decs : '');
    }
  }

  Future<String> addRatePlan() async {
    if (isPercent) {
      double? amount = double.tryParse(teAmount.text.replaceAll(',', ''));
      if (amount! < -100 || amount > 100) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.OVER_PERCENTAGE_RANGE);
      }
    }
    try {
      isLoading = true;
      notifyListeners();
      if (idRatePlan == '') {
        HttpsCallable callable = FirebaseFunctions.instance
            .httpsCallable('hotelmanager-createRatePlan');
        final data = {
          'hotel_id': GeneralManager.hotelID,
          'rate_plan_id': title.text,
          'rate_plan_decs': teDecs.text,
          'rate_plan_amount': teAmount.text.replaceAll(',', ''),
          'is_percent': isPercent,
        };
        await callable(data);
        isLoading = false;
        notifyListeners();
        return '';
      } else {
        HttpsCallable callable = FirebaseFunctions.instance
            .httpsCallable('hotelmanager-editRatePlan');
        final data = {
          'hotel_id': GeneralManager.hotelID,
          'rate_plan_id': idRatePlan,
          'rate_plan_decs': teDecs.text,
          'rate_plan_amount': teAmount.text.replaceAll(',', ''),
          'is_percent': isPercent,
        };
        await callable(data);
        isLoading = false;
        notifyListeners();
        return '';
      }
    } on FirebaseFunctionsException catch (error) {
      isLoading = false;
      notifyListeners();
      return error.message!;
    }
  }

  void setPercent(bool isPercent) {
    this.isPercent = isPercent;
    notifyListeners();
  }
}
