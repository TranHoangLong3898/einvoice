import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/booking.dart';
import '../../util/excelulti.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';

class CosBookingGroupController extends ChangeNotifier {
  late List<Accounting> accountings;
  late bool isLoading;
  late String statusFilter, typeFilter, supplierFilter;
  late Booking booking;
  Map<String, String> mapDataBooking = {};
  CosBookingGroupController(this.booking) {
    isLoading = true;
    accountings = [];
    statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    typeFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    supplierFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    loadAccounting();
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
    accountings.clear();
    mapDataBooking.clear();
    for (var id in booking.subBookings!.keys) {
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colCostManagement)
          .where('id', isEqualTo: id)
          .get()
          .then((querySnapshot) {
        for (var documentSnapshot in querySnapshot.docs) {
          mapDataBooking[documentSnapshot.id] =
              RoomManager().getNameRoomById(booking.subBookings![id]["room"]);
          accountings.add(Accounting.fromDocumentData(documentSnapshot));
        }
      });
    }
    if (statusFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      accountings.where((element) => element.status == statusFilter);
    }
    if (typeFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      accountings.where((element) => element.type == typeFilter);
    }
    if (supplierFilter != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      accountings.where((element) => element.supplier == statusFilter);
    }
    isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String value) async {
    if (statusFilter == value) return;
    statusFilter = value;
    notifyListeners();
    loadAccounting();
  }

  void setTypeFilter(String value) async {
    if (typeFilter == value) return;
    typeFilter = value;
    loadAccounting();
  }

  void setSupplierFilter(String value) async {
    if (supplierFilter == value) return;
    supplierFilter = value;
    loadAccounting();
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
