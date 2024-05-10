import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../handler/firebasehandler.dart';
import '../modal/warehouse/warehouse.dart';
import '../util/messageulti.dart';
import 'generalmanager.dart';

class WarehouseManager extends ChangeNotifier {
  static const String NONE_WAREHOUSE = "none";
  static final WarehouseManager _instance = WarehouseManager._singleton();
  WarehouseManager._singleton();

  factory WarehouseManager() {
    return _instance;
  }

  String statusServiceFilter =
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  bool isInProgress = false;
  List<Warehouse> warehouses = [];

  StreamSubscription? streamSubscription;
  bool isStreaming = false;

  //for warehouse-configuration
  void listenWareHouse() {
    if (isStreaming) {
      return;
    }
    print('listenWarehouseInCloud: Init - ${Timestamp.now().toDate()}');
    isStreaming = true;
    streamSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc(FirebaseHandler.colWarehouses)
        .snapshots()
        .listen((snapshots) {
      warehouses.clear();
      if (snapshots.exists) {
        (snapshots.get('data') as Map<String, dynamic>).forEach((id, value) {
          warehouses.add(Warehouse.fromJson(id, value));
        });
      }
      warehouses.sort((a, b) => a.id!.compareTo(b.id!));
      notifyListeners();
    });
  }

  void cancelStream() {
    streamSubscription?.cancel();
    isStreaming = false;
    print('listenWarehouseInCloud: Cancelled');
  }

  Future<void> getWarehousesFromCloud() async {
    print('getWarehouseInCloud: Init - ${Timestamp.now().toDate()}');
    DocumentSnapshot snapshots = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc(FirebaseHandler.colWarehouses)
        .get();
    warehouses.clear();
    if (snapshots.exists) {
      (snapshots.get('data') as Map<String, dynamic>).forEach((id, value) {
        warehouses.add(Warehouse.fromJson(id, value));
      });
    }
    warehouses.sort((a, b) => a.id!.compareTo(b.id!));
    notifyListeners();
  }

  Future<String> toggleActivation(Warehouse warehouse) async {
    if (isInProgress) return MessageCodeUtil.IN_PROGRESS;
    isInProgress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('warehouse-toggleWarehouseActivation')
        .call(
            {'hotel_id': GeneralManager.hotelID, 'warehouse_id': warehouse.id})
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        });
    isInProgress = false;
    notifyListeners();
    return result;
  }

  void setStatusFilter(String value) {
    statusServiceFilter = value;
    notifyListeners();
  }

  String? getWarehouseNameById(String? id) {
    if (id == null) return null;
    try {
      return warehouses.firstWhere((e) => e.id == id).name!;
    } catch (e) {
      return null;
    }
  }

  String getIdByName(String name) {
    try {
      return warehouses.firstWhere((warehouse) => warehouse.name == name).id!;
    } catch (e) {
      return '';
    }
  }

  List<String> getActiveWarehouseName() {
    try {
      return warehouses
          .where((element) => element.isActive!)
          .map((e) => e.name!)
          .toList();
    } catch (exception) {
      return [];
    }
  }

  List<String> getActiveWarehouseIds() {
    try {
      return warehouses
          .where((element) => element.isActive!)
          .map((e) => e.id!)
          .toList();
    } catch (exception) {
      return [];
    }
  }

  Warehouse? getWarehouseByName(String name) {
    try {
      return warehouses.firstWhere((e) => e.name == name);
    } catch (e) {
      return null;
    }
  }

  Warehouse? getWarehouseById(String id) {
    try {
      return warehouses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // function check when create import warehouse note
  bool isHaveRoleInWareHouseImport() {
    if (UserManager.canSeeWareHouseManagement()) {
      return true;
    }

    for (var warehouse in warehouses) {
      if (warehouse.permission!.roleImport!.contains(UserManager.user!.id)) {
        return true;
      }
    }

    return false;
  }

  bool isHaveRoleInWareHouseExport() {
    if (UserManager.canSeeWareHouseManagement()) {
      return true;
    }

    for (var warehouse in warehouses) {
      if (warehouse.permission!.roleExport!.contains(UserManager.user!.id)) {
        return true;
      }
    }

    return false;
  }

  List<String> getListWarehouseNameHavePermissionImport() {
    return warehouses
        .where((e) =>
            e.permission!.roleImport!.contains(UserManager.user!.id) &&
            e.isActive!)
        .map((e) => e.name!)
        .toList();
  }

  List<String> getListWarehouseNameHavePermissionExport() {
    return warehouses
        .where((e) => e.permission!.roleExport!.contains(UserManager.user!.id))
        .map((e) => e.name!)
        .toList();
  }

  Future<void> exportToExcel(Warehouse data) async {
    ExcelUlti.exportWareHouse(data);
  }
}
