import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../modal/service/service.dart';
import '../../util/dateutil.dart';

class ServiceManagementController extends ChangeNotifier {
  late DateTime date, startDate, endDate;

  List<Service> services = [];
  late List<String> cats, statues;
  late String selectedCat, selectedStatus;

  bool? isLoading = false, forward;
  StreamSubscription? subscription, subscriptionTotalMoney;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;

  final int pageSize = 10;
  num totalMoneyService = 0, totalMoneyServiceOfCurrentPage = 0;

  ServiceManagementController() {
    date = Timestamp.now().toDate();
    startDate = DateUtil.to0h(date);
    endDate = DateUtil.to24h(date);
    services = [];
    selectedCat = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    selectedStatus = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    cats = [
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
      ...ServiceManager.cats
    ];
    statues = [
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
      PaymentMethodManager.statusOpen,
      PaymentMethodManager.statusPass,
      PaymentMethodManager.statusFailed
    ];
    loadServices();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > const Duration(days: 7)) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 7)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to24h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  Query getInitQueryServiceByUsedRange() {
    Query queryFilter = FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('used', isGreaterThanOrEqualTo: startDate)
        .where('used', isLessThanOrEqualTo: endDate)
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .orderBy('used');

    if (selectedCat != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryFilter = queryFilter.where('cat', isEqualTo: selectedCat);
    }
    if (selectedStatus != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryFilter = queryFilter.where('status', isEqualTo: selectedStatus);
    }

    return queryFilter;
  }

  void setCat(String newCat) {
    if (newCat == selectedCat) return;
    selectedCat = newCat;
    services.clear();
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        getInitQueryServiceByUsedRange().limit(pageSize).snapshots().listen(
      (QuerySnapshot querySnapshot) {
        updateServicesAndQueries(querySnapshot);
      },
    );
  }

  void setStatus(String newStatus) {
    if (selectedStatus == newStatus) return;
    selectedStatus = newStatus;
    services.clear();
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        getInitQueryServiceByUsedRange().limit(pageSize).snapshots().listen(
      (QuerySnapshot querySnapshot) {
        updateServicesAndQueries(querySnapshot);
      },
    );
  }

  void updateServicesAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryServiceByUsedRange()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryServiceByUsedRange()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      services.clear();
      snapshotTepm = querySnapshot;
      for (var documentSnapshot in querySnapshot.docs) {
        services.add(Service.fromSnapshot(documentSnapshot));
      }
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryServiceByUsedRange()
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          nextQuery = getInitQueryServiceByUsedRange()
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
          preQuery = null;
        }
      } else {
        nextQuery = getInitQueryServiceByUsedRange()
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryServiceByUsedRange()
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    if (services.isNotEmpty) {
      totalMoneyServiceOfCurrentPage = services.fold(
          0, (previousValue, element) => previousValue + element.total!);
    } else {
      totalMoneyServiceOfCurrentPage = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  void loadServices() {
    services.clear();
    isLoading = true;
    notifyListeners();
    getTotal();
  }

  void cancelStream() {
    subscription?.cancel();
    subscriptionTotalMoney?.cancel();
    services.clear();
  }

  void getServicesReportNextPage() {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    services.clear();
    subscription?.cancel();
    subscription = nextQuery!.snapshots().listen((value) {
      updateServicesAndQueries(value);
    });
  }

  void getServicesReportPreviousPage() {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    services.clear();
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((value) {
      updateServicesAndQueries(value);
    });
  }

  void getServicesReportFirstPage() {
    isLoading = true;
    notifyListeners();
    services.clear();
    subscription?.cancel();
    subscription =
        getInitQueryServiceByUsedRange().limit(pageSize).snapshots().listen(
      (QuerySnapshot querySnapshot) {
        updateServicesAndQueries(querySnapshot);
        preQuery = null;
      },
    );
  }

  void getServicesReportLastPage() {
    isLoading = true;
    notifyListeners();
    services.clear();
    subscription?.cancel();
    subscription = getInitQueryServiceByUsedRange()
        .limitToLast(pageSize)
        .snapshots()
        .listen(
      (QuerySnapshot querySnapshot) {
        updateServicesAndQueries(querySnapshot);
        nextQuery = null;
      },
    );
  }

  void getTotal() async {
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);

    if (inMonthId == outMonthId) {
      subscriptionTotalMoney?.cancel();
      subscriptionTotalMoney = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .doc(inMonthId)
          .snapshots()
          .listen((snapshots) {
        if (snapshots.exists) {
          final result = getTotalMoneyFromSnapshot(snapshots, inDay, outDay);
          totalMoneyService = result;
        }
        subscription?.cancel();
        subscription =
            getInitQueryServiceByUsedRange().limit(pageSize).snapshots().listen(
          (QuerySnapshot querySnapshot) {
            updateServicesAndQueries(querySnapshot);
          },
        );
      });
    } else {
      subscriptionTotalMoney?.cancel();
      subscriptionTotalMoney = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .where(FieldPath.documentId, whereIn: [inMonthId, outMonthId])
          .snapshots()
          .listen((snapshots) {
            num totalService = 0;
            if (snapshots.docs.first.exists) {
              totalService =
                  getTotalMoneyFromSnapshot(snapshots.docs.first, inDay, '');
            }
            if (snapshots.docs.last.exists) {
              totalService +=
                  getTotalMoneyFromSnapshot(snapshots.docs.last, inDay, '');
            }
            totalMoneyService = totalService;
            subscription?.cancel();
            subscription = getInitQueryServiceByUsedRange()
                .limit(pageSize)
                .snapshots()
                .listen((QuerySnapshot querySnapshot) {
              updateServicesAndQueries(querySnapshot);
            });
          });
    }
  }

  num getTotalMoneyFromSnapshot(
      DocumentSnapshot snapshot, String inDay, String outDay) {
    List<dynamic> serviceList = [];
    List<dynamic> dataOfMonth = [];
    num result = 0;
    final data = snapshot.get('data') as Map<String, dynamic>;
    if (outDay == '') {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) >= num.parse(inDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    } else if (inDay == '') {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) <= num.parse(outDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    } else {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) >= num.parse(inDay) &&
            num.parse(keyOfData) <= num.parse(outDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    }

    for (var item in dataOfMonth) {
      if (item['service'] != null) serviceList.add(item['service']);
    }

    result = serviceList.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.values.fold(0,
                (previousValue, element) => previousValue + element['total']));

    return result;
  }

  Future<String?> updateStatus(Service service, String newStatus) async {
    if (newStatus == service.status) return null;
    String result = await service.updateStatus(newStatus);
    return MessageUtil.getMessageByCode(result);
  }
}
