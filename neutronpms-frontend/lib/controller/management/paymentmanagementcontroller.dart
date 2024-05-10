import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/paymentmethodmanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/service/deposit.dart';
import '../../util/dateutil.dart';

class PaymentManagementController extends ChangeNotifier {
  late int maxTimePeriod;

  List<Deposit>? deposits = [];
  Map<String, dynamic> dataPayment = {};
  num totalAll = 0;

  late DateTime startDate, endDate, confirmDate;
  late String methodName, sourceName = 'all', status = 'all';

  StreamSubscription? subscription, subscriptionDepositTotal;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward, isLoading = false;
  bool isLoadingConfirmMoney = false;
  String idDeposit = "";

  DocumentSnapshot? dailyDataSnapshotInMonth, dailyDataSnapshotOutMonth;

  final int pageSize = 10;
  num depositTotal = 0;

  PaymentManagementController(
      [DateTime? inDate, DateTime? outDate, String? methodName]) {
    startDate = inDate ?? DateUtil.to0h(DateTime.now());
    endDate = outDate ?? DateUtil.to24h(DateTime.now());
    confirmDate = DateTime.now();
    this.methodName = methodName ?? 'all';
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    loadDeposits();
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

  void setConfirmDate(DateTime newDate) {
    if (DateUtil.equal(newDate, confirmDate)) return;
    confirmDate = newDate;
    notifyListeners();
  }

  void updateDepositsAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryColDepositsByCreatedRange()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryColDepositsByCreatedRange()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      deposits!.clear();
      snapshotTepm = querySnapshot;
      for (var documentSnapshot in querySnapshot.docs) {
        deposits!.add(Deposit.fromSnapshot(documentSnapshot));
      }
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryColDepositsByCreatedRange()
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQueryColDepositsByCreatedRange()
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQueryColDepositsByCreatedRange()
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryColDepositsByCreatedRange()
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void loadDeposits() async {
    isLoading = true;
    notifyListeners();
    getDepositTotal();
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  void cancelStream() {
    subscription?.cancel();
    subscriptionDepositTotal?.cancel();
    deposits!.clear();
  }

  void getDepositNextPage() {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    deposits!.clear();
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
    deposits!.clear();
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  void getDepositLastPage() {
    isLoading = true;
    notifyListeners();
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limitToLast(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      nextQuery = null;
    });
  }

  void getDepositFirstPage() {
    isLoading = true;
    notifyListeners();
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      preQuery = null;
    });
  }

  Query getInitQueryColDepositsByCreatedRange(
      {DateTime? startInput, DateTime? endInput}) {
    DateTime start = startInput ?? startDate;
    DateTime end = endInput ?? endDate;
    Query queryFilter = FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colDeposits)
        .where('created', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .orderBy('created');
    if (methodName != 'all') {
      queryFilter = queryFilter.where('method',
          isEqualTo:
              PaymentMethodManager().getPaymentMethodIdByName(methodName));
    }
    if (sourceName != 'all') {
      queryFilter = queryFilter.where('source',
          isEqualTo: SourceManager().getSourceIDByName(sourceName));
    }
    if (status != 'all') {
      queryFilter = queryFilter.where('status', isEqualTo: status);
    }
    return queryFilter;
  }

  void setMethod(String newMethodName) {
    if (newMethodName == methodName) return;
    isLoading = true;
    notifyListeners();
    methodName = newMethodName;
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      // update dailydata method here
      if (DateUtil.dateToMonthYearString(startDate) !=
          DateUtil.dateToMonthYearString(endDate)) {
        num depositTotalTepm = 0;
        depositTotalTepm = getTotalMoneyFromSnapshot(dailyDataSnapshotInMonth!,
            DateUtil.dateToShortStringDay(startDate), '');
        depositTotalTepm += getTotalMoneyFromSnapshot(
            dailyDataSnapshotOutMonth!,
            '',
            DateUtil.dateToShortStringDay(endDate));
        depositTotal = depositTotalTepm;
        notifyListeners();
      } else {
        depositTotal = getTotalMoneyFromSnapshot(
            dailyDataSnapshotInMonth!,
            DateUtil.dateToShortStringDay(startDate),
            DateUtil.dateToShortStringDay(endDate));
      }
      notifyListeners();
    });
  }

  void setSource(String newSourceName) {
    if (newSourceName == sourceName) return;
    isLoading = true;
    notifyListeners();
    sourceName = newSourceName;
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
      // update dailydata source here
      if (DateUtil.dateToMonthYearString(startDate) !=
          DateUtil.dateToMonthYearString(endDate)) {
        num depositTotalTepm = 0;
        depositTotalTepm = getTotalMoneyFromSnapshot(dailyDataSnapshotInMonth!,
            DateUtil.dateToShortStringDay(startDate), '');
        depositTotalTepm += getTotalMoneyFromSnapshot(
            dailyDataSnapshotOutMonth!,
            '',
            DateUtil.dateToShortStringDay(endDate));
        depositTotal = depositTotalTepm;
        notifyListeners();
      } else {
        depositTotal = getTotalMoneyFromSnapshot(
            dailyDataSnapshotInMonth!,
            DateUtil.dateToShortStringDay(startDate),
            DateUtil.dateToShortStringDay(endDate));
        notifyListeners();
      }
    });
  }

  void setStatus(String newStatus) {
    if (newStatus == status) return;
    isLoading = true;
    notifyListeners();
    status = newStatus;
    deposits!.clear();
    subscription?.cancel();
    subscription = getInitQueryColDepositsByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateDepositsAndQueries(value);
    });
  }

  num getTotalMoneyFromSnapshot(
      DocumentSnapshot snapshot, String inDay, String outDay) {
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

    List<Map<String, dynamic>> depositsList = [];
    List<double> methodDepositList = [];

    for (var item in dataOfMonth) {
      if (item['deposit'] != null) depositsList.add(item['deposit']);
    }

    // array before filter
    if (methodName != 'all') {
      for (var item in depositsList) {
        if (item.keys.any((element) =>
            element ==
            PaymentMethodManager().getPaymentMethodIdByName(methodName))) {
          for (var element in item.entries) {
            if (element.key ==
                PaymentMethodManager().getPaymentMethodIdByName(methodName)) {
              Map<String, dynamic> sourceDeposit = element.value;
              if (sourceName != 'all') {
                if (sourceDeposit.keys.any((element) =>
                    element == SourceManager().getSourceIDByName(sourceName))) {
                  for (var elementTwo in sourceDeposit.entries) {
                    if (elementTwo.key ==
                        SourceManager().getSourceIDByName(sourceName)) {
                      methodDepositList.add(elementTwo.value.toDouble());
                    }
                  }
                }
              } else {
                for (var elementTwo in sourceDeposit.entries) {
                  methodDepositList.add(elementTwo.value.toDouble());
                }
              }
            }
          }
        }
      }
    } else {
      for (var item in depositsList) {
        for (var element in item.entries) {
          Map<String, dynamic> sourceDeposit = element.value;
          if (sourceName != 'all') {
            if (sourceDeposit.keys.any((element) =>
                element == SourceManager().getSourceIDByName(sourceName))) {
              for (var elementTwo in sourceDeposit.entries) {
                if (elementTwo.key ==
                    SourceManager().getSourceIDByName(sourceName)) {
                  methodDepositList.add(elementTwo.value.toDouble());
                }
              }
            }
          } else {
            for (var elementTwo in sourceDeposit.entries) {
              methodDepositList.add(elementTwo.value.toDouble());
            }
          }
        }
      }
    }

    result = methodDepositList.fold(
        0.0, (previousValue, element) => previousValue + element);
    return result;
  }

  void getDepositTotal() {
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    if (inMonthId == outMonthId) {
      subscriptionDepositTotal?.cancel();
      subscriptionDepositTotal = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .doc(inMonthId)
          .snapshots()
          .listen((snapshots) {
        if (snapshots.exists) {
          dailyDataSnapshotInMonth = snapshots;
          depositTotal = getTotalMoneyFromSnapshot(snapshots, inDay, outDay);
        } else {
          depositTotal = 0;
        }
      });
    } else {
      subscriptionDepositTotal?.cancel();
      subscriptionDepositTotal = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .where(FieldPath.documentId, whereIn: [inMonthId, outMonthId])
          .snapshots()
          .listen((snapshots) {
            num depositTotalTepm = 0;
            if (snapshots.docs.first.exists) {
              dailyDataSnapshotInMonth = snapshots.docs.first;

              depositTotalTepm =
                  getTotalMoneyFromSnapshot(snapshots.docs.first, inDay, '');
            }
            if (snapshots.docs.last.exists) {
              dailyDataSnapshotOutMonth = snapshots.docs.last;
              depositTotalTepm +=
                  getTotalMoneyFromSnapshot(snapshots.docs.last, '', outDay);
            }
            depositTotal = depositTotalTepm;
          });
    }
  }

  // num getTransferTotal() => deposits
  //     .where(
  //         (element) => element.method == PaymentMethodManager.transferMethodID)
  //     .fold(0, (previousValue, element) => previousValue + element.amount);

  List<String?> getSourceNames() {
    List<String> sources = SourceManager().getSourceNames();
    sources.add('all');
    return sources;
  }

  List<String?> getMethodNames() {
    List<String?> methods = PaymentMethodManager().getPaymentMethodName();
    methods.add('all');
    return methods;
  }

  List<String> getStatuses() {
    List<String> statuses = [
      PaymentMethodManager.statusOpen,
      PaymentMethodManager.statusPass,
      PaymentMethodManager.statusFailed
    ];
    statuses.add('all');
    return statuses;
  }

  Future<String?> updateDepositStatus(Deposit deposit, String newStatus) async {
    if (deposit.status == newStatus) return null;
    String result = await deposit.updateStatus(newStatus);
    if (result == MessageCodeUtil.SUCCESS) {
      deposit.status = newStatus;
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }

  Future<List<Deposit>> getAllPaymentForExporting() async {
    List<Deposit> exportData = [];
    await getInitQueryColDepositsByCreatedRange(
            startInput: startDate, endInput: endDate)
        .get()
        .then((querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        exportData.add(Deposit.fromSnapshot(documentSnapshot));
      }
    });
    PaymentMethodManager().getPaymentMethodId().forEach((element) {
      dataPayment[element!] = 0;
    });
    for (var data in exportData) {
      // ignore: unnecessary_null_comparison
      if (dataPayment.entries.where((element) => element.key == data.method) !=
          null) {
        dataPayment[data.method!] += data.amount;
      }
    }
    notifyListeners();
    return exportData;
  }

  Future<String> updateConfirmMoney(Deposit deposit) async {
    isLoadingConfirmMoney = true;
    idDeposit = deposit.id!;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('deposit-updateConfirmMoneyPayment')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'payment_id': deposit.id,
          'booking_id': deposit.bookingID,
          'confirm_date': confirmDate.toString(),
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoadingConfirmMoney = false;
          notifyListeners();
        });
    return result;
  }
}
