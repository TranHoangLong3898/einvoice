import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../manager/servicemanager.dart';
import '../../modal/service/service.dart';
import '../../util/dateutil.dart';

class ServiceReportController extends ChangeNotifier {
  late int maxTimePeriod;
  late DateTime date, startDate, endDate;

  List<Service> services = [];
  late String selectedCat;
  late List<String> cats;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward, isLoading = false;

  final int pageSize = 10;
  num totalMoneyService = 0, totalMoneyServiceCurrentPage = 0;

  ServiceReportController() {
    date = DateTime.now();
    startDate = DateUtil.to0h(date);
    endDate = DateUtil.to24h(date);
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    selectedCat = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    cats = [
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
      ...ServiceManager.cats
    ];
    loadServices();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;

    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > Duration(days: maxTimePeriod)) {
      endDate = DateUtil.to24h(startDate.add(Duration(days: maxTimePeriod)));
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
    Query query = FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('used', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('used', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .orderBy('used');

    if (selectedCat != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('cat', isEqualTo: selectedCat);
    }
    return query;
  }

  void updateServicesAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryServiceByUsedRange(startDate, endDate)
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryServiceByUsedRange(startDate, endDate)
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      for (var documentSnapshot in querySnapshot.docs) {
        services.add(Service.fromSnapshot(documentSnapshot));
      }
      snapshotTepm = querySnapshot;
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryServiceByUsedRange(startDate, endDate)
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQueryServiceByUsedRange(startDate, endDate)
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQueryServiceByUsedRange(startDate, endDate)
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryServiceByUsedRange(startDate, endDate)
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    if (services.isNotEmpty) {
      totalMoneyServiceCurrentPage = services.fold(
          0, (previousValue, element) => previousValue + element.total!);
    } else {
      totalMoneyServiceCurrentPage = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  void loadServices() async {
    isLoading = true;
    notifyListeners();
    await getTotal();
    services.clear();
    getInitQueryServiceByUsedRange(startDate, endDate)
        .limit(pageSize)
        .get()
        .then((QuerySnapshot querySnapshot) {
      updateServicesAndQueries(querySnapshot);
    });
  }

  void getServicesReportNextPage() async {
    if (nextQuery == null) return;
    isLoading = true;
    notifyListeners();
    services.clear();
    forward = true;
    await nextQuery!.get().then((value) => updateServicesAndQueries(value));
  }

  void getServicesReportPreviousPage() async {
    if (preQuery == null) return;
    services.clear();
    isLoading = true;
    notifyListeners();
    forward = false;
    await preQuery!.get().then((value) => updateServicesAndQueries(value));
  }

  void getServicesReportFirstPage() {
    services.clear();
    isLoading = true;
    notifyListeners();

    getInitQueryServiceByUsedRange(startDate, endDate)
        .limit(pageSize)
        .get()
        .then((value) => updateServicesAndQueries(value));
  }

  void getServicesReportLastPage() {
    services.clear();
    isLoading = true;
    notifyListeners();

    getInitQueryServiceByUsedRange(startDate, endDate)
        .limitToLast(pageSize)
        .get()
        .then((value) => updateServicesAndQueries(value));
  }

  void setCat(String cat) {
    if (cat == selectedCat) return;
    selectedCat = cat;
    services.clear();
    isLoading = true;
    notifyListeners();
    getInitQueryServiceByUsedRange(startDate, endDate)
        .limit(pageSize)
        .get()
        .then((value) => updateServicesAndQueries(value));
    notifyListeners();
  }

  Future<void> getTotal() async {
    final dailyData = await FirebaseHandler().getDailyData(startDate, endDate);
    if (dailyData.isEmpty) {
      totalMoneyService = 0;
      return;
    }

    final List<Map<String, dynamic>> serviceListFromDailyData = [];
    for (var item in dailyData) {
      if (item['service'] != null) {
        serviceListFromDailyData.add(item['service']);
      }
    }
    totalMoneyService = serviceListFromDailyData.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.values.fold(0,
                (previousValue, element) => previousValue + element['total']));
  }

  Future<List<Service>> getAllDetailService() async {
    List<Service> servicesExport = [];
    await getInitQueryServiceByUsedRange(startDate, endDate)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        servicesExport.add(Service.fromSnapshot(documentSnapshot));
      }
    });
    return servicesExport;
  }
}
