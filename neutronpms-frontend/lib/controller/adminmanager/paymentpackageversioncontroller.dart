import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/modal/paymentpackageversion.dart';
import 'package:ihotel/util/dateutil.dart';

class PaymentPackageController extends ChangeNotifier {
  final int pageSize = 10;
  late DateTime now, startDate, endDate;
  StreamSubscription? _streamSubscription;
  bool? isSortDsc, isLoading, forward;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  List<PaymentPackageVersion> paymentPackageVersion = [];

  PaymentPackageController() {
    isLoading = false;
    isSortDsc = false;
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    loadPaymentPackage();
  }

  Query getInitQuery() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colPaymentPackage)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .orderBy('created');
  }

  Future<void> loadPaymentPackage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshots) async {
      await updatePaymentPackageAndQueries(snapshots);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updatePaymentPackageAndQueries(
      QuerySnapshot querySnapshot) async {
    paymentPackageVersion.clear();
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQuery()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQuery()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      snapshotTepm = querySnapshot;
      for (var documentSnapshot in querySnapshot.docs) {
        paymentPackageVersion
            .add(PaymentPackageVersion.fromJson(documentSnapshot));
      }
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQuery()
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQuery()
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQuery()
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQuery()
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
  }

  void getPaymentPackageNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = nextQuery!.snapshots().listen((value) {
      updatePaymentPackageAndQueries(value);
    });
  }

  void getPaymentPackagePreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = preQuery!.snapshots().listen((value) {
      updatePaymentPackageAndQueries(value);
    });
  }

  void getPaymentPackageLastPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limitToLast(pageSize).snapshots().listen((value) {
      nextQuery = null;
      updatePaymentPackageAndQueries(value);
    });
  }

  void getPaymentPackageFirstPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      preQuery = null;
      updatePaymentPackageAndQueries(value);
    });
  }

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    if (startDate.isAtSameMomentAs(newStart)) {
      return;
    }
    startDate = newStart;
    if (startDate.isAfter(endDate)) {
      endDate = DateUtil.to24h(startDate);
    } else if (endDate.difference(startDate).inDays > 30) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 30)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    DateTime newEnd = DateUtil.to24h(date);
    if (endDate.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate)) {
      return;
    }
    endDate = newEnd;
    notifyListeners();
  }

  // Future<String> addPaymentPackageVersion(String id) async {
  //   isLoading = true;
  //   notifyListeners();
  //   String result = await FirebaseFunctions.instance
  //       .httpsCallable('hotelmanager-deletePackageVersion')
  //       .call({
  //     "hotel_id": GeneralManager.hotelID,
  //     "id_package": id,
  //   }).then((value) {
  //     return value.data;
  //   }).onError((error, stackTrace) =>
  //           (error as FirebaseFunctionsException).message);
  //   isLoading = false;
  //   notifyListeners();
  //   return result;
  // }
}
