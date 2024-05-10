import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/service/minibar.dart';

import '../../../manager/servicemanager.dart';
import '../../../util/dateutil.dart';

class MinibarReportManagerController extends ChangeNotifier {
  int? maxTimePeriod;
  late DateTime date, startDate, endDate;

  bool? forward, isLoading = false;
  Map<String, int> mapService = {};
  List<Minibar> servicesData = [];
  Map<String, Map<String, dynamic>> mapMinibar = {};

  num totalMoneyService = 0;

  MinibarReportManagerController() {
    date = DateTime.now();
    startDate = DateUtil.to0h(date);
    endDate = DateUtil.to24h(date);
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    loadServices();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > Duration(days: maxTimePeriod!)) {
      endDate = DateUtil.to24h(startDate.add(Duration(days: maxTimePeriod!)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to24h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  Query getInitQueryServiceByUsedRange(DateTime start, DateTime end) {
    return FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .where('used', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('used', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('cat', isEqualTo: ServiceManager.MINIBAR_CAT);
  }

  void loadServices() async {
    isLoading = true;
    notifyListeners();
    totalMoneyService = 0;
    servicesData.clear();
    mapService.clear();
    mapMinibar.clear();
    await getAllServiceMinibar();
  }

  Future<void> getAllServiceMinibar() async {
    await getInitQueryServiceByUsedRange(startDate, endDate)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        servicesData.add(Minibar.fromSnapshot(documentSnapshot));
      }
    });
    for (var service in servicesData) {
      DateTime dateTime = service.created!.toDate();
      int day = dateTime.day;
      int month = dateTime.month;
      int year = dateTime.year;
      for (var item in service.getItems()!) {
        String key = "${service.getPrice(item)}-$item";
        if (mapMinibar.containsKey("$year-$month-$day")) {
          if (mapMinibar["$year-$month-$day"]!.containsKey(key)) {
            mapMinibar["$year-$month-$day"]![key] += service.getAmount(item);
          } else {
            mapMinibar["$year-$month-$day"]![key] = service.getAmount(item);
          }
        } else {
          mapMinibar["$year-$month-$day"] = {key: service.getAmount(item)};
        }
        mapService.containsKey(key)
            ? mapService[key] = (mapService[key]! + service.getAmount(item))
            : mapService[key] = service.getAmount(item);
      }
    }
    mapService.forEach((key, value) {
      totalMoneyService += (value * double.parse(key.split("-")[0]));
    });
    isLoading = false;
    notifyListeners();
  }
}
