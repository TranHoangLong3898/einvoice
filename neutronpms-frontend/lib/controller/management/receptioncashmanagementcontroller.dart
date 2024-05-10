import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../modal/service/deposit.dart';
import '../../util/dateutil.dart';

class ReceptionCashManagementController extends ChangeNotifier {
  late int maxTimePeriod;
  DateTime startDate = DateUtil.to0h(DateTime.now());
  DateTime endDate = DateUtil.to24h(DateTime.now());

  List<Deposit> cashLogs = [];
  Deposit? firstStep, depositCashFromDailyData = Deposit();

  late num? totalMoneyOfRecptionCash, totalMoneyOfRecptionCashCurrentPage;

  StreamSubscription? subscription;

  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;

  bool? forward, isLoading = false;

  final statuses = ['open', 'passed', 'failed'];
  final int pageSize = 10;

  ReceptionCashManagementController() {
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    getTotalReceptionCash();
    loadCashLogs();
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

  Query getInitQueryCashlogByDate(DateTime start, DateTime end) {
    return FirebaseHandler.hotelRef
        .collection('cash_logs')
        .where('created', isGreaterThanOrEqualTo: start)
        .where('created', isLessThanOrEqualTo: end)
        .orderBy('created');
  }

  void updateCashLogsAndQueries(QuerySnapshot snapshots) async {
    if (snapshots.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryCashlogByDate(startDate, endDate)
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryCashlogByDate(startDate, endDate)
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      cashLogs.clear();
      if (firstStep != null &&
          firstStep!.id!.compareTo(snapshots.docs.first.id) == 0) {
        cashLogs.add(depositCashFromDailyData!);
      }
      snapshotTepm = snapshots;
      for (var doc in snapshots.docs) {
        cashLogs.add(Deposit(
            id: doc.id,
            amount: doc.get('amount'),
            created: doc.get('created'),
            desc: doc.get('desc'),
            status: doc.get('status')));
      }
      if (snapshots.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryCashlogByDate(startDate, endDate)
              .endBeforeDocument(snapshots.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQueryCashlogByDate(startDate, endDate)
              .startAfterDocument(snapshots.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQueryCashlogByDate(startDate, endDate)
            .startAfterDocument(snapshots.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryCashlogByDate(startDate, endDate)
            .endBeforeDocument(snapshots.docs.first)
            .limitToLast(pageSize);
      }
    }
    if (cashLogs.isNotEmpty) {
      totalMoneyOfRecptionCashCurrentPage = cashLogs.fold(
          0, (previousValue, element) => previousValue! + element.amount!);
    } else {
      totalMoneyOfRecptionCashCurrentPage = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  void loadCashLogs() async {
    isLoading = true;
    notifyListeners();
    await getDepositsCashFromDailyData();
    cashLogs.clear();
    firstStep = null;
    subscription?.cancel();
    print('asyncCashLog: Init');
    subscription = getInitQueryCashlogByDate(startDate, endDate)
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateCashLogsAndQueries(value);
      if (firstStep == null) {
        cashLogs.insert(0, depositCashFromDailyData!);
        if (cashLogs.length >= 2) {
          firstStep = cashLogs[1];
        }
      }
    });
  }

  void getDepositsFirstPage() {
    isLoading = true;
    notifyListeners();
    cashLogs.clear();
    cashLogs.add(depositCashFromDailyData!);
    getInitQueryCashlogByDate(startDate, endDate)
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateCashLogsAndQueries(value);
      preQuery = null;
    });
  }

  void getDepositsPreviousPage() {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    cashLogs.clear();
    preQuery!.snapshots().listen((value) {
      updateCashLogsAndQueries(value);
    });
  }

  void getDepositsNextPage() {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    cashLogs.clear();
    nextQuery!.snapshots().listen((value) => updateCashLogsAndQueries(value));
  }

  void getDepositsLastPage() {
    isLoading = true;
    notifyListeners();
    cashLogs.clear();
    getInitQueryCashlogByDate(startDate, endDate)
        .limitToLast(pageSize)
        .snapshots()
        .listen((value) {
      updateCashLogsAndQueries(value);
      nextQuery = null;
    });
  }

  Future<void> getDepositsCashFromDailyData() async {
    List<Map<String, dynamic>> depositsWithCashMethod = [];
    final dailyData = await FirebaseHandler().getDailyData(startDate, endDate);
    for (var data in dailyData) {
      if (data['deposit'] != null && data['deposit']['ca'] != null) {
        depositsWithCashMethod.add(data['deposit']['ca']);
      }
      if (data['deposit'] != null && data['deposit']['cade'] != null) {
        depositsWithCashMethod.add(data['deposit']['cade']);
      }
    }

    if (depositsWithCashMethod.isEmpty) {
      depositCashFromDailyData = Deposit(
          amount: 0,
          desc: MessageUtil.getMessageByCode(
              MessageCodeUtil.TOTAL_PAYMENT_IN_CASH, [
            DateUtil.dateToDayMonthString(startDate),
            DateUtil.dateToDayMonthString(endDate)
          ]));
      return;
    }

    final totalDepositsCash = depositsWithCashMethod.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.values.fold(0,
                (previousValue, element) => previousValue + (element as int)));

    depositCashFromDailyData = Deposit(
        amount: totalDepositsCash,
        desc: MessageUtil.getMessageByCode(
            MessageCodeUtil.TOTAL_PAYMENT_IN_CASH, [
          DateUtil.dateToDayMonthString(startDate),
          DateUtil.dateToDayMonthString(endDate)
        ]));
  }

  Future<void> getTotalReceptionCash() async {
    try {
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colManagement)
          .doc('reception_cash')
          .get()
          .then((value) {
        totalMoneyOfRecptionCash = value.get('total');
        notifyListeners();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void addCashLog(Deposit cashLog) async {
    totalMoneyOfRecptionCash = (totalMoneyOfRecptionCash! + cashLog.amount!);
    notifyListeners();
  }

  Future<String> updateCashLogStatus(Deposit cashLog, String newStatus) async {
    try {
      isLoading = true;
      notifyListeners();
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('cashlog-updateStatusCashLog');
      final result = await callable.call({
        'hotel_id': GeneralManager.hotelID,
        'cashLog_id': cashLog.id,
        'status': newStatus
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        isLoading = false;
        notifyListeners();
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseException catch (e) {
      isLoading = false;
      notifyListeners();
      return e.message!;
    }
    isLoading = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  void cancelStream() {
    subscription?.cancel();
    print('asyncCashLog: Cancelled');
  }

  Future<String?> exportToExcel() async {
    List<Deposit> exportData = [];
    //get cash logs
    await getInitQueryCashlogByDate(startDate, endDate).get().then((snapshots) {
      for (var doc in snapshots.docs) {
        exportData.add(Deposit(
            id: doc.id,
            amount: doc.get('amount'),
            created: doc.get('created'),
            desc: doc.get('desc'),
            status: doc.get('status')));
      }
    });

    if (exportData.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);
    }
    //get total payment in cash
    final Deposit totalPaymentInCash = Deposit(
        amount: 0,
        desc: MessageUtil.getMessageByCode(
            MessageCodeUtil.TOTAL_PAYMENT_IN_CASH, [
          DateUtil.dateToDayMonthString(startDate),
          DateUtil.dateToDayMonthString(endDate)
        ]));
    List<Map<String, dynamic>> depositsWithCashMethod = [];
    final dailyData = await FirebaseHandler().getDailyData(startDate, endDate);
    for (var data in dailyData) {
      if (data['deposit'] != null && data['deposit']['ca'] != null) {
        depositsWithCashMethod.add(data['deposit']['ca']);
      }
    }
    if (depositsWithCashMethod.isNotEmpty) {
      final totalDepositsCash = depositsWithCashMethod.fold(
          0,
          (previousValue, element) =>
              previousValue +
              element.values.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + (element as int)));
      totalPaymentInCash.amount = totalDepositsCash;
    }
    exportData.insert(0, totalPaymentInCash);

    ExcelUlti.exportReceptionCash(exportData, startDate, endDate);
    return null;
  }
}

class AddCashLogController extends ChangeNotifier {
  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isAdding = false;
  num totalCash;
  AddCashLogController(this.totalCash);

  Future<dynamic> withdrawCashLog(bool isAdd) async {
    final amount = num.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      return {'result': MessageCodeUtil.INPUT_POSITIVE_AMOUNT};
    }
    isAdding = true;
    notifyListeners();
    final cashLog = Deposit(
        amount: isAdd ? amount : -amount,
        desc: descController.text,
        created: Timestamp.now());
    final result = await FirebaseHandler().addCashLog(cashLog, totalCash);
    if (result == MessageCodeUtil.SUCCESS) {
      isAdding = false;
      notifyListeners();
      return {'result': MessageCodeUtil.SUCCESS, 'data': cashLog};
    } else {
      isAdding = false;
      notifyListeners();
      return {'result': result};
    }
  }
}
