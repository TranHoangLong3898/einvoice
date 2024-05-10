import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import '../../manager/bookingmanager.dart';
import '../../modal/status.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';

class AccountingManagementController extends ChangeNotifier {
  final int pageSize = 10;
  StreamSubscription? _streamSubscription, _streamSubscriptionDailyData;
  DocumentSnapshot? dailyDataSnapshotInMonth, dailyDataSnapshotOutMonth;
  num accountingTotal = 0;

  late List<Accounting> accountings;
  late DateTime now, startDate, endDate;
  bool? isSortDsc, isLoading, forward, typeCostFilter;
  late String statusFilter, typeFilter, supplierFilter;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  Map<String, Booking> dataBooking = {};
  late TextEditingController filterSidOrRoom;

  AccountingManagementController() {
    isLoading = true;
    isSortDsc = false;
    accountings = [];
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeCostFilter = true;
    filterSidOrRoom = TextEditingController(text: "");

    loadAccounting();
  }

  Query getInitQuery() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .orderBy('created', descending: isSortDsc!);
    if (statusFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('type', isEqualTo: typeFilterId);
    }
    if (supplierFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('supplier', isEqualTo: supplierFilterId);
    }
    if (typeCostFilter!) {
      if (filterSidOrRoom.text.isNotEmpty) {
        query = query.where('sid', isEqualTo: filterSidOrRoom.text);
      }
    } else {
      if (filterSidOrRoom.text.isNotEmpty) {
        query = query.where('room',
            isEqualTo: RoomManager().getIdRoomByName(filterSidOrRoom.text));
      }
    }
    return query;
  }

  String get typeFilterId =>
      AccountingTypeManager.getIdByName(typeFilter) ??
      MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);

  String get supplierFilterId =>
      SupplierManager().getSupplierIDByName(supplierFilter) ??
      MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);

  Future<void> loadAccounting() async {
    isLoading = true;
    notifyListeners();
    getMoneyFromDailyData();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshots) async {
      await updateAccountingsAndQueries(snapshots);
      await getInfoBookingHaveCost();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateAccountingsAndQueries(QuerySnapshot querySnapshot) async {
    accountings.clear();
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
        accountings.add(Accounting.fromDocumentData(documentSnapshot));
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
    isLoading = false;
    notifyListeners();
  }

  getInfoBookingHaveCost() async {
    for (var element in accountings) {
      if (element.idBooking!.isNotEmpty && element.sidBooking!.isNotEmpty) {
        dataBooking[element.id!] =
            (await BookingManager().getBasicBookingByID(element.idBooking!))!;
      }
    }
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

  void setStatusFilter(String value) async {
    if (statusFilter == value) {
      return;
    }
    statusFilter = value;
    isLoading = true;
    notifyListeners();
    forward = null;
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateAccountingTotal();
      updateAccountingsAndQueries(value);
    });
  }

  void setTypeFilter(String value) async {
    if (typeFilter == value) {
      return;
    }
    typeFilter = value;
    isLoading = true;
    forward = null;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateAccountingTotal();
      updateAccountingsAndQueries(value);
    });
  }

  void setSupplierFilter(String value) async {
    if (supplierFilter == value) {
      return;
    }
    supplierFilter = value;
    isLoading = true;
    forward = null;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateAccountingTotal();
      updateAccountingsAndQueries(value);
    });
  }

  void setTypeCostFilter() {
    typeCostFilter = !typeCostFilter!;
    notifyListeners();
  }

  void setCostTypeFilter(String value) async {
    filterSidOrRoom = TextEditingController(text: value);
    filterSidOrRoom.selection = TextSelection.fromPosition(
        TextPosition(offset: filterSidOrRoom.text.length));
    notifyListeners();
  }

  void getAccountingNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = nextQuery!.snapshots().listen((value) {
      updateAccountingsAndQueries(value);
    });
  }

  void updateAccountingTotal() {
    if (DateUtil.dateToMonthYearString(startDate) !=
        DateUtil.dateToMonthYearString(endDate)) {
      num depositTotalTepm = 0;
      depositTotalTepm = getTotalMoneyFromSnapshot(dailyDataSnapshotInMonth!,
          DateUtil.dateToShortStringDay(startDate), '');
      depositTotalTepm += getTotalMoneyFromSnapshot(dailyDataSnapshotOutMonth!,
          '', DateUtil.dateToShortStringDay(endDate));
      accountingTotal = depositTotalTepm;
    } else {
      accountingTotal = getTotalMoneyFromSnapshot(
          dailyDataSnapshotInMonth!,
          DateUtil.dateToShortStringDay(startDate),
          DateUtil.dateToShortStringDay(endDate));
    }
  }

  void getAccountingPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = preQuery!.snapshots().listen((value) {
      updateAccountingsAndQueries(value);
    });
  }

  void getAccountingLastPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limitToLast(pageSize).snapshots().listen((value) {
      updateAccountingsAndQueries(value);
      nextQuery = null;
    });
  }

  void getAccountingFirstPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateAccountingsAndQueries(value);
      preQuery = null;
    });
  }

  void toggleSort() {
    isSortDsc = !isSortDsc!;
    notifyListeners();
  }

  void resetFilter() {
    isSortDsc = false;
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  }

  String getCostTypeByStatus(int? status, Accounting e) {
    switch (status) {
      case CostType.booked:
        return UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COST_BOOKED);
      case CostType.room:
        return "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COST_ROOM)} ${RoomManager().getNameRoomById(e.room!)} - ${RoomTypeManager().getRoomTypeNameByID(e.roomType!)}";
      default:
        return UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTING);
    }
  }

  Future<String> deleteAccounting(Accounting accounting) async {
    isLoading = true;
    notifyListeners();
    return await accounting.delete().whenComplete(() {
      isLoading = false;
      notifyListeners();
    });
  }

  void getMoneyFromDailyData() async {
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
          accountingTotal = getTotalMoneyFromSnapshot(snapshots, inDay, outDay);

          notifyListeners();
        } else {
          accountingTotal = 0;
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
              accountingTepm =
                  getTotalMoneyFromSnapshot(snapshots.docs.first, inDay, '');
            }
            if (snapshots.docs.last.exists) {
              dailyDataSnapshotOutMonth = snapshots.docs.last;
              accountingTepm +=
                  getTotalMoneyFromSnapshot(snapshots.docs.last, '', outDay);
            }
            accountingTotal = accountingTepm;
            notifyListeners();
          });
    }
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

    List<Map<String, dynamic>> costManagementList = [];
    List<double> statusCostTotal = [];

    for (var item in dataOfMonth) {
      if (item['cost_management'] != null) {
        costManagementList.add(item['cost_management']);
      }
    }

    for (var item in costManagementList) {
      if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
        if (item.keys.any((element) => element == typeFilterId)) {
          for (var elementType in item.entries) {
            if (elementType.key == typeFilterId) {
              Map<String, dynamic> accountingFlowSupplier = elementType.value;
              if (supplierFilter !=
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                if (accountingFlowSupplier.keys
                    .any((element) => element == supplierFilterId)) {
                  for (var elementSupplier in accountingFlowSupplier.entries) {
                    if (elementSupplier.key == supplierFilterId) {
                      Map<String, dynamic> accountingFlowStatus =
                          elementSupplier.value;
                      if (statusFilter !=
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                        if (accountingFlowStatus.keys
                            .any((element) => element == statusFilter)) {
                          for (var elementStatus
                              in accountingFlowStatus.entries) {
                            if (elementStatus.key == statusFilter) {
                              statusCostTotal
                                  .add(elementStatus.value.toDouble());
                            }
                          }
                        }
                      } else {
                        for (var elementStatus
                            in accountingFlowStatus.entries) {
                          statusCostTotal.add(elementStatus.value.toDouble());
                        }
                      }
                    }
                  }
                }
              } else {
                for (var element in accountingFlowSupplier.entries) {
                  Map<String, dynamic> accountingFlowStatus = element.value;
                  if (statusFilter !=
                      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    if (accountingFlowStatus.keys
                        .any((element) => element == statusFilter)) {
                      for (var elementThree in accountingFlowStatus.entries) {
                        if (elementThree.key == statusFilter) {
                          statusCostTotal.add(elementThree.value.toDouble());
                        }
                      }
                    }
                  } else {
                    for (var elementThree in accountingFlowStatus.entries) {
                      statusCostTotal.add(elementThree.value.toDouble());
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        for (var element in item.entries) {
          Map<String, dynamic> accountingFlowSupplier = element.value;
          if (supplierFilter !=
              UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
            if (accountingFlowSupplier.keys
                .any((element) => element == supplierFilterId)) {
              for (var elementSupplier in accountingFlowSupplier.entries) {
                if (elementSupplier.key == supplierFilterId) {
                  Map<String, dynamic> accountingFlowStatus =
                      elementSupplier.value;
                  if (statusFilter !=
                      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    if (accountingFlowStatus.keys
                        .any((element) => element == statusFilter)) {
                      for (var elementStatus in accountingFlowStatus.entries) {
                        if (elementStatus.key == statusFilter) {
                          statusCostTotal.add(elementStatus.value.toDouble());
                        }
                      }
                    }
                  } else {
                    for (var elementStatus in accountingFlowStatus.entries) {
                      statusCostTotal.add(elementStatus.value.toDouble());
                    }
                  }
                }
              }
            }
          } else {
            for (var elementSupllier in accountingFlowSupplier.entries) {
              Map<String, dynamic> accountingFlowStatus = elementSupllier.value;
              if (statusFilter !=
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                if (accountingFlowStatus.keys
                    .any((element) => element == statusFilter)) {
                  for (var elementStatus in accountingFlowStatus.entries) {
                    if (elementStatus.key == statusFilter) {
                      statusCostTotal.add(elementStatus.value.toDouble());
                    }
                  }
                }
              } else {
                for (var elementStatus in accountingFlowStatus.entries) {
                  statusCostTotal.add(elementStatus.value.toDouble());
                }
              }
            }
          }
        }
      }
    }

    result = statusCostTotal.fold(
        0.0, (previousValue, element) => previousValue + element);
    return result;
  }

  Future<void> exportToExcel() async {
    Query queryWithoutLimitation = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .orderBy('created');
    if (statusFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryWithoutLimitation =
          queryWithoutLimitation.where('status', isEqualTo: statusFilter);
    }
    if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryWithoutLimitation =
          queryWithoutLimitation.where('type', isEqualTo: typeFilterId);
    }
    if (supplierFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryWithoutLimitation =
          queryWithoutLimitation.where('supplier', isEqualTo: supplierFilterId);
    }
    QuerySnapshot snapshot = await queryWithoutLimitation.get();
    List<Accounting> excelData = [];
    if (snapshot.size <= 0) {
      return;
    }
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      excelData.add(Accounting.fromDocumentData(doc));
    }
    ExcelUlti.exportAccountingManagement(excelData, startDate, endDate);
  }
}
