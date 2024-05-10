import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/util/dateutil.dart';

class DepositManagementController extends ChangeNotifier {
  static const int rangeQuery = 10;
  late int maxTimePeriod = 30;
  late DateTime startDate, endDate;
  bool isDescending = true;
  bool? isLoading = false, forward;
  List<BookingDeposit> deposits = [];
  StreamSubscription? subscription;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  TextEditingController searchTeController = TextEditingController(text: '');
  int queryStatus = DepositStatus.DEPOSIT;
  DepositManagementController() {
    startDate = DateUtil.to0h(DateTime.now());
    endDate = DateUtil.to24h(DateTime.now());
    loadDeposits();
  }

  Query getInitQueryColDepositsByTimeRange() {
    Query queryFilter = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookingDeposits)
        .where('created', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('created', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('status', whereIn: [
      DepositStatus.DEPOSIT,
      if (queryStatus == 1) DepositStatus.REFUND
    ]);

    if (searchTeController.text.trim() != '') {
      queryFilter =
          queryFilter.where('sid', isEqualTo: searchTeController.text.trim());
    }

    return queryFilter.orderBy('created', descending: isDescending);
  }

  void loadDeposits() async {
    isLoading = true;
    notifyListeners();
    deposits.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByTimeRange()
        .limit(rangeQuery)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  void updateDepositsAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryColDepositsByTimeRange()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(rangeQuery);
      } else {
        preQuery = null;
        nextQuery = getInitQueryColDepositsByTimeRange()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(rangeQuery);
      }
    } else {
      deposits.clear();
      snapshotTepm = querySnapshot;
      for (var documentSnapshot in querySnapshot.docs) {
        deposits.add(BookingDeposit.fromSnapshot(documentSnapshot));
      }
      if (querySnapshot.size < rangeQuery) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryColDepositsByTimeRange()
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(rangeQuery);
        } else {
          preQuery = null;
          nextQuery = getInitQueryColDepositsByTimeRange()
              .startAfterDocument(querySnapshot.docs.last)
              .limit(rangeQuery);
        }
      } else {
        nextQuery = getInitQueryColDepositsByTimeRange()
            .startAfterDocument(querySnapshot.docs.last)
            .limit(rangeQuery);
        preQuery = getInitQueryColDepositsByTimeRange()
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(rangeQuery);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > Duration(days: maxTimePeriod)) {
      endDate = DateUtil.to24h(DateUtil.getLastDateOfMonth(startDate));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to24h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  void getDepositNextPage() {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    deposits.clear();
    subscription?.cancel();
    subscription = nextQuery!.snapshots().listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  void getDepositPreviousPage() {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    deposits.clear();
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  void getDepositLastPage() {
    isLoading = true;
    notifyListeners();
    deposits.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByTimeRange()
        .limitToLast(rangeQuery)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      nextQuery = null;
    });
  }

  void getDepositFirstPage() {
    isLoading = true;
    notifyListeners();
    deposits.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByTimeRange()
        .limit(rangeQuery)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      preQuery = null;
    });
  }

  void sortByTime() {
    isDescending = !isDescending;
    if (isDescending) {
      deposits.sort(
        (a, b) => b.createTime.compareTo(a.createTime),
      );
    } else {
      deposits.sort(
        (a, b) => a.createTime.compareTo(b.createTime),
      );
    }
    notifyListeners();
  }

  List<BookingDeposit> filter() {
    if (searchTeController.text.trim() != '') {
      return deposits
          .where(
              (element) => element.sid.contains(searchTeController.text.trim()))
          .toList();
    }
    return deposits;
  }

  setQueryStatus(int index) {
    queryStatus = index;
    notifyListeners();
  }

  search() {
    notifyListeners();
  }

  Future<String> deteleDepositPayment(BookingDeposit e) async {
    isLoading = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('bookingdeposit-deleteBookingPayment')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'sid': e.sid,
          'id_deposit': e.id,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        });

    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<String> deteleRefundDepositPayment(BookingDeposit e) async {
    isLoading = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('bookingdeposit-deleteRefundDeposit')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'sid': e.sid,
          'id_deposit': e.id,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        });

    isLoading = false;
    notifyListeners();
    return result;
  }
}
