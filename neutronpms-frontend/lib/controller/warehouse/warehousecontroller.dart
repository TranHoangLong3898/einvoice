import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roles.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../../modal/warehouse/warehouse.dart';

class WarehouseController extends ChangeNotifier {
  Warehouse? oldWarehouse;
  bool? isAddFeature;
  bool isInProgress = false;
  TextEditingController teId = TextEditingController(text: '');
  TextEditingController teName = TextEditingController(text: '');
  List<String> grantRoleImports = [];
  List<String> grantRoleExports = [];

  List<HotelUser>? users;

  WarehouseController(Warehouse? warehouse) {
    users = [];
    loadUserFromApi();

    if (warehouse == null) {
      isAddFeature = true;
    } else {
      isAddFeature = false;
      oldWarehouse = warehouse;
      teId.text = warehouse.id!;
      teName.text = warehouse.name!;
      grantRoleImports = List.from(warehouse.permission!.roleImport!);
      grantRoleExports = List.from(warehouse.permission!.roleExport!);
    }
  }

  void loadUserFromApi() async {
    isInProgress = true;
    notifyListeners();
    users!.clear();

    await FirebaseFunctions.instance
        .httpsCallable('user-getUsersInHotel')
        .call({'hotel_id': GeneralManager.hotelID}).then((value) {
      for (var doc in (value.data as List<dynamic>)) {
        if (GeneralManager.hotel!.roles![doc['id']].any(
            (e) => [Roles.admin, Roles.owner, Roles.manager].contains(e))) {
          continue;
        }
        users!.add(HotelUser.fromMap(doc));
      }
    }).onError((error, stackTrace) {
      print(error);
      users = [];
    });

    isInProgress = false;
    notifyListeners();
  }

  void setUserForImportRoleWarehouse(String id, bool isAdd) {
    isAdd ? grantRoleImports.add(id) : grantRoleImports.remove(id);
    notifyListeners();
  }

  void setUserForExportRoleWarehouse(String id, bool isAdd) {
    isAdd ? grantRoleExports.add(id) : grantRoleExports.remove(id);
    notifyListeners();
  }

  Future<String> updateWarehouse() async {
    String id = teId.text.trim().replaceAll(RegExp('/s+'), ' ');
    String name = teName.text.trim().replaceAll(RegExp('/s+'), ' ');
    String result;
    if (isAddFeature!) {
      isInProgress = true;
      notifyListeners();
      result = await FirebaseFunctions.instance
          .httpsCallable('warehouse-createWarehouse')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'warehouse_id': id,
            'warehouse_name': name,
            'permission_import': grantRoleImports,
            'permission_export': grantRoleExports
          })
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    } else {
      if (oldWarehouse!.id == id &&
          oldWarehouse!.name == name &&
          listEquals(grantRoleImports, oldWarehouse!.permission!.roleImport) &&
          listEquals(grantRoleExports, oldWarehouse!.permission!.roleExport)) {
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      isInProgress = true;
      notifyListeners();
      result = await FirebaseFunctions.instance
          .httpsCallable('warehouse-updateWarehouse')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'warehouse_id': id,
            'warehouse_name': name,
            'permission_import': grantRoleImports,
            'permission_export': grantRoleExports
          })
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
