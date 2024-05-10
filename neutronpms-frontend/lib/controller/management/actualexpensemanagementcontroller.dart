import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/accounting/actualpayment.dart';

import '../../handler/firebasehandler.dart';
import '../../manager/accountingtypemanager.dart';
import '../../manager/generalmanager.dart';
import '../../manager/suppliermanager.dart';
import '../../util/dateutil.dart';
import '../../util/excelulti.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';

class ActualExpenseManagementController extends ChangeNotifier {
  final int pageSize = 10;
  late List<ActualPayment> actualPayments;
  late DateTime now, startDate, endDate;
  num actualPaymentTotal = 0;
  //filter
  bool? forward, isLoading;
  String? methodFilter, statusFilter, costId, typeFilter, supplierFilter;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  StreamSubscription? _streamSubscriptionDailyData, _streamSubscription;
  DocumentSnapshot? dailyDataSnapshotInMonth, dailyDataSnapshotOutMonth;

  ActualExpenseManagementController(this.costId) {
    isLoading = true;
    actualPayments = [];
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    methodFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    loadActualPayments();
  }

  String get typeFilterId =>
      AccountingTypeManager.getIdByName(typeFilter!) ??
      MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);

  String get supplierFilterId =>
      SupplierManager().getSupplierIDByName(supplierFilter!) ??
      MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);

  //getter
  Query get query {
    Query query = FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colActualPayment)
        .where('hotel_id', isEqualTo: GeneralManager.hotelID);
    if (costId!.isNotEmpty) {
      query = query.where('cost_management_id', isEqualTo: costId);
    } else {
      query = query
          .where('created', isGreaterThanOrEqualTo: startDate)
          .where('created', isLessThanOrEqualTo: endDate)
          .orderBy('created');
    }
    if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('type', isEqualTo: typeFilterId);
    }
    if (supplierFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('supplier', isEqualTo: supplierFilterId);
    }
    if (methodFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('method', isEqualTo: methodFilterId);
    }
    if (statusFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query;
  }

  String? get methodFilterId =>
      PaymentMethodManager().getPaymentMethodIdByName(methodFilter!);

  List<String> listStatus = ['open', 'passed', 'failed'];

  Future<void> loadActualPayments() async {
    isLoading = true;
    notifyListeners();
    listenDailyData();
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((snapshots) {
      updateActualPaymentsAndQueries(snapshots);
    });
  }

  Future<String> deleteAccounting(ActualPayment actualPayment) async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-deleteActual')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cost_management_id': actualPayment.accountingId,
          'actual_payment_id': actualPayment.id
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          isLoading = false;
          notifyListeners();
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  Future<String> updateActualPaymentStatus(
      ActualPayment actualPayment, String newStatus) async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-updateStatusActual')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cost_management_id': actualPayment.accountingId,
          'actual_payment_id': actualPayment.id,
          'status': newStatus
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          isLoading = false;
          notifyListeners();
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  void updateActualPaymentsAndQueries(QuerySnapshot querySnapshot) {
    actualPayments.clear();
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
        actualPayments
            .add(ActualPayment.fromDocumentSnapshot(documentSnapshot));
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
    DateTime newEnd = DateUtil.to0h(date);
    if (endDate.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate)) {
      return;
    }
    endDate = newEnd;
    notifyListeners();
  }

  void setTypeFilter(String value) async {
    if (typeFilter == value) {
      return;
    }
    typeFilter = value;
    isLoading = true;
    notifyListeners();
    forward = null;
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((value) {
      updateActualPaymentTotalLocal();
      updateActualPaymentsAndQueries(value);
    });
  }

  void setSupplierFilter(String value) async {
    if (supplierFilter == value) {
      return;
    }
    supplierFilter = value;
    isLoading = true;
    notifyListeners();
    forward = null;
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((value) {
      updateActualPaymentTotalLocal();
      updateActualPaymentsAndQueries(value);
    });
  }

  void setMethodFilter(String value) async {
    if (methodFilter == value) {
      return;
    }
    methodFilter = value;
    isLoading = true;
    forward = null;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((value) {
      updateActualPaymentTotalLocal();
      updateActualPaymentsAndQueries(value);
    });
  }

  void setStatusFilter(String value) async {
    if (statusFilter == value) {
      return;
    }
    statusFilter = value;
    isLoading = true;
    forward = null;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((value) {
      updateActualPaymentTotalLocal();
      updateActualPaymentsAndQueries(value);
    });
  }

  void getActualPaymentsNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = nextQuery!.snapshots().listen((value) {
      updateActualPaymentsAndQueries(value);
    });
  }

  void getActualPaymentsPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = preQuery!.snapshots().listen((value) {
      updateActualPaymentsAndQueries(value);
    });
  }

  void getActualPaymentsLastPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        query.limitToLast(pageSize).snapshots().listen((value) {
      nextQuery = null;
      updateActualPaymentsAndQueries(value);
    });
  }

  void getActualPaymentsFirstPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = query.limit(pageSize).snapshots().listen((value) {
      preQuery = null;
      updateActualPaymentsAndQueries(value);
    });
  }

  void listenDailyData() async {
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    if (inMonthId == outMonthId) {
      await _streamSubscriptionDailyData?.cancel();
      _streamSubscriptionDailyData = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .doc(inMonthId)
          .snapshots()
          .listen((snapshots) {
        if (snapshots.exists) {
          dailyDataSnapshotInMonth = snapshots;
          actualPaymentTotal =
              getAcutalPaymentTotalMoneyFromSnapshot(snapshots, inDay, outDay);
          notifyListeners();
        } else {
          actualPaymentTotal = 0;
        }
      });
    } else {
      await _streamSubscriptionDailyData?.cancel();
      _streamSubscriptionDailyData = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .where(FieldPath.documentId, whereIn: [inMonthId, outMonthId])
          .snapshots()
          .listen((snapshots) {
            num accountingTepm = 0;
            if (snapshots.docs.first.exists) {
              dailyDataSnapshotInMonth = snapshots.docs.first;
              accountingTepm = getAcutalPaymentTotalMoneyFromSnapshot(
                  snapshots.docs.first, inDay, '');
            }
            if (snapshots.docs.last.exists) {
              dailyDataSnapshotOutMonth = snapshots.docs.last;
              accountingTepm += getAcutalPaymentTotalMoneyFromSnapshot(
                  snapshots.docs.last, '', outDay);
            }
            actualPaymentTotal = accountingTepm;
            notifyListeners();
          });
    }
  }

  num getAcutalPaymentTotalMoneyFromSnapshot(
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

    List<Map<String, dynamic>> actualPaymentManagementList = [];
    List<double> actualPaymentFlowStatus = [];

    for (var item in dataOfMonth) {
      if (item['actual_payment'] != null) {
        actualPaymentManagementList.add(item['actual_payment']);
      }
    }

    for (var item in actualPaymentManagementList) {
      if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
        if (item.keys.any((element) => element == typeFilterId)) {
          for (var elementType in item.entries) {
            if (elementType.key == typeFilterId) {
              Map<String, dynamic> actualPaymentsFlowSupplier =
                  elementType.value;
              if (supplierFilter !=
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                if (actualPaymentsFlowSupplier.keys
                    .any((element) => element == supplierFilterId)) {
                  for (var elementSupplier
                      in actualPaymentsFlowSupplier.entries) {
                    if (elementSupplier.key == supplierFilterId) {
                      Map<String, dynamic> actualPaymentsFlowMethod =
                          elementSupplier.value;
                      if (methodFilter !=
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                        if (actualPaymentsFlowMethod.keys
                            .any((element) => element == methodFilterId)) {
                          for (var elementMethod
                              in actualPaymentsFlowMethod.entries) {
                            if (elementMethod.key == methodFilterId) {
                              Map<String, dynamic> actualPaymentsFlowStatus =
                                  elementMethod.value;
                              if (statusFilter !=
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.STATUS_ALL)) {
                                if (actualPaymentsFlowStatus.keys.any(
                                    (element) => element == statusFilter)) {
                                  for (var elementStatus
                                      in actualPaymentsFlowStatus.entries) {
                                    if (elementStatus.key == statusFilter) {
                                      actualPaymentFlowStatus
                                          .add(elementStatus.value.toDouble());
                                    }
                                  }
                                }
                              } else {
                                for (var elementStatus
                                    in actualPaymentsFlowStatus.entries) {
                                  {
                                    actualPaymentFlowStatus
                                        .add(elementStatus.value.toDouble());
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        for (var elementMethod
                            in actualPaymentsFlowMethod.entries) {
                          Map<String, dynamic> actualPaymentsFlowStatus =
                              elementMethod.value;
                          if (statusFilter !=
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ALL)) {
                            if (actualPaymentsFlowStatus.keys
                                .any((element) => element == statusFilter)) {
                              for (var elementStatus
                                  in actualPaymentsFlowStatus.entries) {
                                if (elementStatus.key == statusFilter) {
                                  actualPaymentFlowStatus
                                      .add(elementStatus.value.toDouble());
                                }
                              }
                            }
                          } else {
                            for (var elementStatus
                                in actualPaymentsFlowStatus.entries) {
                              {
                                actualPaymentFlowStatus
                                    .add(elementStatus.value.toDouble());
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                for (var elementSupplier
                    in actualPaymentsFlowSupplier.entries) {
                  Map<String, dynamic> actualPaymentsFlowMethod =
                      elementSupplier.value;
                  if (methodFilter !=
                      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    if (actualPaymentsFlowMethod.keys
                        .any((element) => element == methodFilterId)) {
                      for (var elementMethod
                          in actualPaymentsFlowMethod.entries) {
                        if (elementMethod.key == methodFilterId) {
                          Map<String, dynamic> actualPaymentsFlowStatus =
                              elementMethod.value;
                          if (statusFilter !=
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ALL)) {
                            if (actualPaymentsFlowStatus.keys
                                .any((element) => element == statusFilter)) {
                              for (var elementStatus
                                  in actualPaymentsFlowStatus.entries) {
                                if (elementStatus.key == statusFilter) {
                                  actualPaymentFlowStatus
                                      .add(elementStatus.value.toDouble());
                                }
                              }
                            }
                          } else {
                            for (var elementStatus
                                in actualPaymentsFlowStatus.entries) {
                              {
                                actualPaymentFlowStatus
                                    .add(elementStatus.value.toDouble());
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    for (var elementMethod
                        in actualPaymentsFlowMethod.entries) {
                      Map<String, dynamic> actualPaymentsFlowStatus =
                          elementMethod.value;
                      if (statusFilter !=
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                        if (actualPaymentsFlowStatus.keys
                            .any((element) => element == statusFilter)) {
                          for (var elementStatus
                              in actualPaymentsFlowStatus.entries) {
                            if (elementStatus.key == statusFilter) {
                              actualPaymentFlowStatus
                                  .add(elementStatus.value.toDouble());
                            }
                          }
                        }
                      } else {
                        for (var elementStatus
                            in actualPaymentsFlowStatus.entries) {
                          {
                            actualPaymentFlowStatus
                                .add(elementStatus.value.toDouble());
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        for (var element in item.entries) {
          Map<String, dynamic> actualPaymemtsFlowSupplier = element.value;
          if (supplierFilter !=
              UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
            if (actualPaymemtsFlowSupplier.keys
                .any((element) => element == supplierFilterId)) {
              for (var elementSupplier in actualPaymemtsFlowSupplier.entries) {
                if (elementSupplier.key == supplierFilterId) {
                  Map<String, dynamic> actualPaymentsFlowMethod =
                      elementSupplier.value;
                  if (methodFilter !=
                      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    if (actualPaymentsFlowMethod.keys
                        .any((element) => element == methodFilterId)) {
                      for (var elementMethod
                          in actualPaymentsFlowMethod.entries) {
                        if (elementMethod.key == methodFilterId) {
                          Map<String, dynamic> actualPaymentsFlowStatus =
                              elementMethod.value;
                          if (statusFilter !=
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ALL)) {
                            if (actualPaymentsFlowStatus.keys
                                .any((element) => element == statusFilter)) {
                              for (var elementStatus
                                  in actualPaymentsFlowStatus.entries) {
                                if (elementStatus.key == statusFilter) {
                                  actualPaymentFlowStatus
                                      .add(elementStatus.value.toDouble());
                                }
                              }
                            }
                          } else {
                            for (var elementStatus
                                in actualPaymentsFlowStatus.entries) {
                              {
                                actualPaymentFlowStatus
                                    .add(elementStatus.value.toDouble());
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    for (var elementMethod
                        in actualPaymentsFlowMethod.entries) {
                      Map<String, dynamic> actualPaymentsFlowStatus =
                          elementMethod.value;
                      if (statusFilter !=
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                        if (actualPaymentsFlowStatus.keys
                            .any((element) => element == statusFilter)) {
                          for (var elementStatus
                              in actualPaymentsFlowStatus.entries) {
                            if (elementStatus.key == statusFilter) {
                              actualPaymentFlowStatus
                                  .add(elementStatus.value.toDouble());
                            }
                          }
                        }
                      } else {
                        for (var elementStatus
                            in actualPaymentsFlowStatus.entries) {
                          {
                            actualPaymentFlowStatus
                                .add(elementStatus.value.toDouble());
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          } else {
            for (var elementSupllier in actualPaymemtsFlowSupplier.entries) {
              Map<String, dynamic> actualPaymentsFlowMethod =
                  elementSupllier.value;
              if (methodFilter !=
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                if (actualPaymentsFlowMethod.keys
                    .any((element) => element == methodFilterId)) {
                  for (var elementMethod in actualPaymentsFlowMethod.entries) {
                    if (elementMethod.key == methodFilterId) {
                      Map<String, dynamic> actualPaymentsFlowStatus =
                          elementMethod.value;
                      if (statusFilter !=
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                        if (actualPaymentsFlowStatus.keys
                            .any((element) => element == statusFilter)) {
                          for (var elementStatus
                              in actualPaymentsFlowStatus.entries) {
                            if (elementStatus.key == statusFilter) {
                              actualPaymentFlowStatus
                                  .add(elementStatus.value.toDouble());
                            }
                          }
                        }
                      } else {
                        for (var elementStatus
                            in actualPaymentsFlowStatus.entries) {
                          {
                            actualPaymentFlowStatus
                                .add(elementStatus.value.toDouble());
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                for (var elementMethod in actualPaymentsFlowMethod.entries) {
                  Map<String, dynamic> actualPaymentsFlowStatus =
                      elementMethod.value;
                  if (statusFilter !=
                      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    if (actualPaymentsFlowStatus.keys
                        .any((element) => element == statusFilter)) {
                      for (var elementStatus
                          in actualPaymentsFlowStatus.entries) {
                        if (elementStatus.key == statusFilter) {
                          actualPaymentFlowStatus
                              .add(elementStatus.value.toDouble());
                        }
                      }
                    }
                  } else {
                    for (var elementStatus
                        in actualPaymentsFlowStatus.entries) {
                      {
                        actualPaymentFlowStatus
                            .add(elementStatus.value.toDouble());
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    result = actualPaymentFlowStatus.fold(
        0.0, (previousValue, element) => previousValue + element);
    return result;
  }

  void updateActualPaymentTotalLocal() {
    if (DateUtil.dateToMonthYearString(startDate) !=
        DateUtil.dateToMonthYearString(endDate)) {
      num depositTotalTepm = 0;
      depositTotalTepm = getAcutalPaymentTotalMoneyFromSnapshot(
          dailyDataSnapshotInMonth!,
          DateUtil.dateToShortStringDay(startDate),
          '');
      depositTotalTepm += getAcutalPaymentTotalMoneyFromSnapshot(
          dailyDataSnapshotOutMonth!,
          '',
          DateUtil.dateToShortStringDay(endDate));
      actualPaymentTotal = depositTotalTepm;
    } else {
      actualPaymentTotal = getAcutalPaymentTotalMoneyFromSnapshot(
          dailyDataSnapshotInMonth!,
          DateUtil.dateToShortStringDay(startDate),
          DateUtil.dateToShortStringDay(endDate));
    }
  }

  Future<void> exportToExcel() async {
    QuerySnapshot snapshot = await query.get();
    List<ActualPayment> excelData = [];
    if (snapshot.size <= 0) {
      return;
    }
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      excelData.add(ActualPayment.fromDocumentSnapshot(doc));
    }
    ExcelUlti.exportActualPaymentManagement(excelData, startDate, endDate);
  }
}
