import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/revenue_logs/revenue_log.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../../handler/firebasehandler.dart';
import '../../../../manager/paymentmethodmanager.dart';
import '../../../../util/dateutil.dart';

class RevenueLogsController extends ChangeNotifier {
  final int pageSize = 10;
  late List<RevenueLog> revenueLogs;
  late DateTime now, startDate, endDate;
  bool? forward, isLoading;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  late String methodFilter, typeLogFilter;
  List<RevenueLog?> revenueLogsAll = [];

  RevenueLogsController() {
    isLoading = false;
    revenueLogs = [];
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    methodFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeLogFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    loadRevenueLogs();
  }

  //getter
  Query get query {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colRevenueLogs)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .orderBy('created');
    if (methodFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      if (typeLogFilter ==
          UITitleUtil.getTitleByCode(
              UITitleCode.TABLEHEADER_TYPE_REVENUE_TRANSFER)) {
        query = query.where('method_from',
            isEqualTo:
                PaymentMethodManager().getPaymentMethodIdByName(methodFilter));
      } else {
        query = query.where('method',
            isEqualTo:
                PaymentMethodManager().getPaymentMethodIdByName(methodFilter));
      }
    }
    if (typeLogFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('type', isEqualTo: getTypeIdByFilter());
    }
    return query;
  }

  String get methodFilterId =>
      PaymentMethodManager().getPaymentMethodIdByName(methodFilter)!;

  // type
  List<String> get getTypeNames => [
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE_REVENUE_ADD),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE_REVENUE_MINUS),
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_TRANSFER),
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_ACTUAL_PAYMENT)
      ];

  num getTypeIdByFilter() {
    if (typeLogFilter ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE_REVENUE_ADD)) {
      return TypeRevenueLog.typeAdd;
    } else if (typeLogFilter ==
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_MINUS)) {
      return TypeRevenueLog.typeMinus;
    } else if (typeLogFilter ==
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_TRANSFER)) {
      return TypeRevenueLog.typeTransfer;
    } else {
      return TypeRevenueLog.typeActualPayment;
    }
  }

  void setMethodFilter(String value) async {
    if (methodFilter == value) {
      return;
    }
    methodFilter = value;
    isLoading = true;
    notifyListeners();
    forward = null;
    QuerySnapshot snapshot = await query.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  void setypeFilter(String value) async {
    if (typeLogFilter == value) {
      return;
    }
    typeLogFilter = value;
    isLoading = true;
    notifyListeners();
    forward = null;
    QuerySnapshot snapshot = await query.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  Future<void> loadRevenueLogs() async {
    isLoading = true;
    notifyListeners();
    QuerySnapshot snapshot = await query.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  // Future<String> deleteRevenueLog(RevenueLog revenueLog) async {
  //   isLoading = true;
  //   notifyListeners();
  //   return await FirebaseFunctions.instance
  //       .httpsCallable('revenue-deleteRevenueLog')
  //       .call({
  //         'hotel_id': GeneralManager.hotelID,
  //         'revenue_log_id': revenueLog.id,
  //       })
  //       .then((value) => value.data)
  //       .onError((error, stackTrace) {
  //         print(error);
  //         isLoading = false;
  //         notifyListeners();
  //         return error.message;
  //       })
  //       .whenComplete(() {
  //         isLoading = false;
  //         notifyListeners();
  //       });
  // }

  void updateRevenueLogsAndQueries(QuerySnapshot querySnapshot) {
    revenueLogs.clear();
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery =
            query.endAtDocument(snapshotTepm!.docs.last).limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery =
            query.startAtDocument(snapshotTepm!.docs.first).limit(pageSize);
      }
    } else {
      snapshotTepm = querySnapshot;
      for (var documentSnapshot in querySnapshot.docs) {
        revenueLogs.add(RevenueLog.fromDocumentData(documentSnapshot));
      }
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = query
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery =
              query.startAfterDocument(querySnapshot.docs.last).limit(pageSize);
        }
      } else {
        nextQuery =
            query.startAfterDocument(querySnapshot.docs.last).limit(pageSize);
        preQuery = query
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    isLoading = false;
    notifyListeners();
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

  void getRevenueLogsNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    QuerySnapshot snapshot = await nextQuery!.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  void getRevenueLogsPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    QuerySnapshot snapshot = await preQuery!.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  void getRevenueLogsFirstPage() async {
    isLoading = true;
    notifyListeners();
    preQuery = null;
    QuerySnapshot snapshot = await query.limit(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  void getRevenueLogsLastPage() async {
    isLoading = true;
    notifyListeners();
    nextQuery = null;
    QuerySnapshot snapshot = await query.limitToLast(pageSize).get();
    updateRevenueLogsAndQueries(snapshot);
  }

  double getAmountBalanceAfterTransaction(RevenueLog e) =>
      (e.type == TypeRevenueLog.typeMinus ||
              e.type == TypeRevenueLog.typeTransfer ||
              e.type == TypeRevenueLog.typeActualPayment)
          ? ((e.oldTotal?[e.method] ?? 0)) - e.amount
          : ((e.oldTotal?[e.method] ?? 0)) + e.amount;

  double getAmountOpeningBalanceByIdMethod(String? idMethod) {
    if (revenueLogsAll.firstWhere((element) => element?.method == idMethod) ==
        null) {
      return 0;
    }
    return revenueLogsAll
            .firstWhere((element) => element?.method == idMethod)
            ?.oldTotal![idMethod] ??
        0;
  }

  Future<List<RevenueLog?>> getAllCheckCashFlowStatement() async {
    revenueLogsAll.clear();
    QuerySnapshot snapshot = await query.get();
    for (var documentSnapshot in snapshot.docs) {
      revenueLogsAll.add(RevenueLog.fromDocumentData(documentSnapshot));
    }
    return revenueLogsAll;
  }
}
