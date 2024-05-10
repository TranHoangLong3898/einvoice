import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/util/excelulti.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';

class CostBookingController extends ChangeNotifier {
  late String statusFilter, typeFilter, supplierFilter;
  StreamSubscription? _streamSubscription;
  late List<Accounting> accountings;
  late bool isLoading;
  Booking? booking;
  late String idBooking = "";
  CostBookingController(this.booking) {
    isLoading = true;
    accountings = [];
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    idBooking = (booking == null ? "" : booking!.id)!;
    loadAccounting();
  }

  Query getInitQuery() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('id', isEqualTo: idBooking)
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
    _streamSubscription = getInitQuery().snapshots().listen((snapshots) {
      updateAccountingsAndQueries(snapshots);
    });
  }

  void updateAccountingsAndQueries(QuerySnapshot querySnapshot) {
    accountings.clear();
    for (var documentSnapshot in querySnapshot.docs) {
      if (documentSnapshot.exists) {
        accountings.add(Accounting.fromDocumentData(documentSnapshot));
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String value) async {
    if (statusFilter == value) return;
    statusFilter = value;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = getInitQuery().snapshots().listen((value) {
      updateAccountingsAndQueries(value);
    });
  }

  void setTypeFilter(String value) async {
    if (typeFilter == value) return;
    typeFilter = value;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = getInitQuery().snapshots().listen((value) {
      updateAccountingsAndQueries(value);
    });
  }

  void setSupplierFilter(String value) async {
    if (supplierFilter == value) return;
    supplierFilter = value;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = getInitQuery().snapshots().listen((value) {
      updateAccountingsAndQueries(value);
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
    if (accountings.isEmpty) return;
    ExcelUlti.exportAccountingManagement(
        accountings, DateTime.now(), DateTime.now());
  }
}
