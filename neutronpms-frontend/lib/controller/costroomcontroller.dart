import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';
import '../manager/roommanager.dart';

class CostRoomController extends ChangeNotifier {
  final int pageSize = 10;
  StreamSubscription? _streamSubscription;
  late List<Accounting> accountings;
  DateTime? now, startDate, endDate;
  bool? isLoading, forward;
  late String statusFilter, typeFilter, supplierFilter;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  String idRoom = "";
  CostRoomController(this.idRoom, this.startDate, this.endDate) {
    isLoading = true;
    accountings = [];
    now = DateTime.now();
    startDate = startDate ?? DateUtil.to0h(now!);
    endDate = endDate ?? DateUtil.to24h(now!);
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    loadAccounting();
  }

  Query getInitQuery() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .where('room_type', isEqualTo: RoomManager().getRoomTypeById(idRoom))
        .where('room', isEqualTo: idRoom)
        .orderBy('created');
    if (statusFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('type', isEqualTo: typeFilterId);
    }
    if (supplierFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      query = query.where('supplier', isEqualTo: supplierFilterId);
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
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshots) {
      updateAccountingsAndQueries(snapshots);
    });
  }

  void updateAccountingsAndQueries(QuerySnapshot querySnapshot) {
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

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    if (startDate!.isAtSameMomentAs(newStart)) {
      return;
    }
    startDate = newStart;
    if (startDate!.isAfter(endDate!)) {
      endDate = DateUtil.to24h(startDate!);
    } else if (endDate!.difference(startDate!).inDays > 30) {
      endDate = DateUtil.to24h(startDate!.add(const Duration(days: 30)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    DateTime newEnd = DateUtil.to24h(date);
    if (endDate!.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate!)) {
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
      updateAccountingsAndQueries(value);
    });
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

  Future<String> deleteAccounting(Accounting accounting) async {
    isLoading = true;
    notifyListeners();
    return await accounting.delete().whenComplete(() {
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> exportToExcel() async {
    Query queryWithoutLimitation = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .where('room_type', isEqualTo: RoomManager().getRoomTypeById(idRoom))
        .where('room', isEqualTo: idRoom)
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
    ExcelUlti.exportAccountingManagement(excelData, startDate!, endDate!);
  }
}
