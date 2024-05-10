import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';

import '../modal/rateplan.dart';

class RatePlanManager extends ChangeNotifier {
  static final RatePlanManager _singleton = RatePlanManager._instance();

  factory RatePlanManager() {
    return _singleton;
  }
  bool isLoading = false;

  RatePlanManager._instance();

  List<RatePlan> ratePlans = [];
  String? statusServiceFilter;
  String standardRatePlan = 'Standard';
  String otaRatePlan = 'OTA';
  bool isRatePlanStandardOrOTA(String ratePlanTitle) {
    return ratePlanTitle == 'OTA' || ratePlanTitle == 'Standard';
  }

  void update(Map<String, dynamic> data) {
    ratePlans.clear();
    for (var item in data.entries) {
      final ratePlan = RatePlan.fromSnapShot(item.value);
      ratePlan.title = item.key;
      ratePlans.add(ratePlan);
    }
    ratePlans.sort((a, b) => a.title!.compareTo(b.title!));
    notifyListeners();
  }

  RatePlan getRatePLanDefault() {
    return ratePlans.firstWhere((element) => element.isDefault!);
  }

  List<String?> getTitleOfActiveRatePlans() {
    return ratePlans
        .where((element) => !element.isDelete!)
        .map((e) => e.title)
        .toList();
  }

  RatePlan getRatePlanByTitle(String title) {
    return ratePlans.firstWhere((element) => element.title == title);
  }

  List<num> getPriceWithRatePlanID(String ratePlanID, List<num> prices) {
    RatePlan ratePlan = getRatePlanByTitle(ratePlanID);
    List<num> result = [];
    if (ratePlan.percent!) {
      final amount = 1 + ratePlan.amount! / 100;
      for (var price in prices) {
        result.add(price * amount);
      }
    } else {
      for (var price in prices) {
        result.add(price + ratePlan.amount!);
      }
    }
    return result;
  }

  Future<String> deactiveRateplan(String title) async {
    isLoading = true;
    notifyListeners();
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('hotelmanager-deactiveRatePlan');
      final result = await callable(
          {'hotel_id': GeneralManager.hotelID, 'rate_plan_id': title});
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result.data);
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }

  Future<String> activeRateplan(String title) async {
    isLoading = true;
    notifyListeners();
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('hotelmanager-activeRatePlan');
      final result = await callable(
          {'hotel_id': GeneralManager.hotelID, 'rate_plan_id': title});
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result.data);
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }

  void setStatusFilter(String status) {
    if (statusServiceFilter == status) return;
    statusServiceFilter = status;
    notifyListeners();
  }

  Future<String> setDefaultRatePlan(String title) async {
    if (title == otaRatePlan) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OTA_RATE_PLAN_CANNOT_BE_SET_DEFAULT);
    }
    isLoading = true;
    notifyListeners();
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('hotelmanager-setdefaultrateplan');
      final result = await callable(
          {'hotel_id': GeneralManager.hotelID, 'rate_plan_id': title});
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result.data);
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }
}
