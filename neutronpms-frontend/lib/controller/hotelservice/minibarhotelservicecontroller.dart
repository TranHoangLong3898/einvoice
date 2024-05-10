import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/minibarmanager.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/autoexportitemsstatus.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../ui/controls/neutrontextformfield.dart';

class MinibarRestaurantHotelServiceController extends ChangeNotifier {
  final HotelItem? service;

  bool isInProgress = false;
  late NeutronInputNumberController tePriceController;
  late String defaultWarehouseName;
  bool? isAutoExport;
  HotelItem? selectedItem;
  String? type;

  MinibarRestaurantHotelServiceController(this.service, String? type) {
    if (service == null) {
      tePriceController = NeutronInputNumberController(TextEditingController());
      defaultWarehouseName = '';
      isAutoExport = false;
      this.type = type ?? ItemType.minibar;
    } else {
      var currentItemPrice = service!.type == ItemType.minibar
          ? MinibarManager().getPriceOfItem(service!.id!)
          : RestaurantItemManager().getPriceOfItem(service!.id!);
      tePriceController = NeutronInputNumberController(
          TextEditingController(text: '$currentItemPrice'));
      defaultWarehouseName = WarehouseManager()
              .getWarehouseNameById(service!.defaultWarehouseId) ??
          "";
      isAutoExport = service!.isAutoExport;
      selectedItem = HotelItem.copy(service!);
      this.type = selectedItem!.type;
    }
  }

  void setDefaultWarehouse(String newWarehouse) {
    if (defaultWarehouseName == newWarehouse) {
      return;
    }
    defaultWarehouseName = newWarehouse;
    notifyListeners();
  }

  void setItem(HotelItem newItem) {
    if (selectedItem == newItem) {
      return;
    }
    selectedItem = newItem;
    notifyListeners();
  }

  void setAutoExport(bool? newValue) {
    isAutoExport = newValue;
    notifyListeners();
  }

  Future<String> updateMinibar() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }

    if (service == null &&
        MinibarManager().minibars.any((e) => e.id == selectedItem!.id)) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.DUPLICATED_ITEM);
    }
    if (GeneralManager.hotel!.autoExportItems ==
            HotelAutoExportItemsStatus.ALL_ITEMS ||
        (GeneralManager.hotel!.autoExportItems ==
                HotelAutoExportItemsStatus.ONLY_SELECTED_ITEMS &&
            isAutoExport!)) {
      if (WarehouseManager().getIdByName(defaultWarehouseName) == '') {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.PLEASE_CHOOSE_WAREHOUSE);
      }
    }
    String priceText = tePriceController.getRawString();
    double price = priceText.isEmpty ? 0 : double.tryParse(priceText)!;

    selectedItem!
      ..sellPrice = price
      ..defaultWarehouseId =
          WarehouseManager().getIdByName(defaultWarehouseName)
      ..type = type
      ..isAutoExport = isAutoExport;
    if (selectedItem!.defaultWarehouseId!.isEmpty) {
      selectedItem!.defaultWarehouseId = null;
    }
    if (service != null && service!.equalTo(selectedItem!)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }

    isInProgress = true;
    notifyListeners();
    String result = await ItemManager().updateItem(selectedItem!);
    isInProgress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
