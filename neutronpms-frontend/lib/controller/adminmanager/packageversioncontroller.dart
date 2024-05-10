import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class PackageVersionController extends ChangeNotifier {
  Map<String, dynamic> dataMap = {};
  bool isLoading = false;
  String idPackage = "";
  String selectStatus = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  StreamSubscription? subscription;

  List<String> listStatus = [
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE),
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE),
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
  ];

  PackageVersionController() {
    getMapDataPackageVersion();
  }

  getMapDataPackageVersion() async {
    await subscription?.cancel();
    subscription = FirebaseHandler.hotelRef.snapshots().listen((event) {
      dataMap.clear;
      final data = event.data() as Map<String, dynamic>;
      dataMap = data.containsKey('package_version')
          ? event.get('package_version')
          : {};
      notifyListeners();
    });
  }

  void cancelStream() {
    subscription?.cancel();
  }

  void setStatus(String status) {
    if (selectStatus == status) return;
    selectStatus = status;
    notifyListeners();
  }

  Future<String> updatePackageVersion(String id) async {
    isLoading = true;
    idPackage = id;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-deletePackageVersion')
        .call({
      "hotel_id": GeneralManager.hotelID,
      "id_package": id,
    }).then((value) {
      return value.data;
    }).onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<String> updateDefaultPackageVersion(String id) async {
    isLoading = true;
    idPackage = id;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateDefaultPackageVersion')
        .call({
      "hotel_id": GeneralManager.hotelID,
      "id_package": id,
    }).then((value) {
      return value.data;
    }).onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isLoading = false;
    notifyListeners();
    return result;
  }

  String getPackageVersion(int value) {
    switch (value) {
      case 0:
        return "1 Tháng";
      case 1:
        return "1 Năm";
      default:
        return "";
    }
  }
}
