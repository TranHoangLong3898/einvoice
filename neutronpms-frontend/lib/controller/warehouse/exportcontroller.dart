import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../modal/warehouse/warehouseexport/itemexport.dart';
import '../../../modal/warehouse/warehouseexport/warehousenoteexport.dart';
import '../../../modal/warehouse/warehousenote.dart';

class ExportController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager warehouseNotesManager;
  WarehouseNoteExport? oldExport;
  bool? isInProgress = false, isAddFeature, quantityWarning = false;
  DateTime? now;

  List<ItemExport> listItem = <ItemExport>[];
  List<NeutronInputNumberController> inputAmounts = [];

  /// Rebuild total of each item
  List<RebuildNumber> rebuildStock = [];

  // /// Used to display total of all
  // RebuildNumber finalTotal = RebuildNumber(0);

  TextEditingController? invoiceNumber;

  /// use to check permission
  Map<String, String> warehouses = {};

  ExportController(WarehouseNoteExport? export, this.warehouseNotesManager,
      bool isImportExcelFile,
      {this.priorityWarehouse}) {
    invoiceNumber = TextEditingController(
        text: export?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (export == null) {
      isAddFeature = true;
      now = DateTime.now();
      ItemExport newItemExport = ItemExport(
          id: MessageCodeUtil.CHOOSE_ITEM,
          amount: 0,
          warehouse: priorityWarehouse?.name ??
              UITitleUtil.getTitleByCode(UITitleCode.NO));
      listItem.add(newItemExport);
      inputAmounts
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      rebuildStock.add(RebuildNumber(0));
    } else {
      isAddFeature = false;
      now = export.createdTime;
      oldExport = export;
      for (ItemExport item in export.list!) {
        // finalTotal.value += ItemManager()
        //         .getItemById(item.id!)
        //         .getAveragePriceByYear(now!.year.toString()) *
        //     item.amount;
        ItemExport temp = ItemExport(
            id: item.id,
            warehouse: WarehouseManager().getWarehouseNameById(item.warehouse!),
            amount: item.amount);
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        rebuildStock.add(RebuildNumber(0));
      }
    }
    if (isImportExcelFile) isAddFeature = true;
  }

  List<String> getListAvailabelItem() {
    List<String?> allIdItems = ItemManager().getIdsOfActiveItems();
    return allIdItems
        .map((id) => ItemManager().getNameAndUnitByID(id!)!)
        .toList();
  }

  List<String> getAvailabelWarehouseNames(
      String idItem, String currentWarehouse) {
    List<String> allWarehouse = [];
    WarehouseManager().warehouses.map((e) => e.name).toList();
    if (UserManager.canSeeWareHouseManagement()) {
      allWarehouse = WarehouseManager()
          .warehouses
          .where((element) => element.isActive!)
          .map((e) => e.name!)
          .toList();
    } else {
      allWarehouse =
          WarehouseManager().getListWarehouseNameHavePermissionExport();
    }

    for (ItemExport itemExport in listItem) {
      if (itemExport.id == idItem && itemExport.warehouse != currentWarehouse) {
        allWarehouse.removeWhere((element) => element == itemExport.warehouse);
      }
    }
    return allWarehouse;
  }

  bool addItemToList() {
    if (listItem
        .where((element) => element.id == MessageCodeUtil.CHOOSE_ITEM)
        .isNotEmpty) {
      return false;
    }
    ItemExport newItemExport = ItemExport(
        id: MessageCodeUtil.CHOOSE_ITEM,
        amount: 0,
        warehouse: priorityWarehouse?.name ??
            UITitleUtil.getTitleByCode(UITitleCode.NO));
    listItem.add(newItemExport);
    inputAmounts
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    rebuildStock.add(RebuildNumber(0));
    notifyListeners();
    return true;
  }

  void setItemId(int index, String newValue) {
    int lastIndex = newValue.lastIndexOf('-');
    String newId;
    if (lastIndex == -1) {
      newId =
          ItemManager().getIdByName(newValue) ?? MessageCodeUtil.CHOOSE_ITEM;
    } else {
      String name = newValue.substring(0, lastIndex).trim();
      String unit = newValue.substring(lastIndex + 1).trim();
      newId = ItemManager().getIdByNameAndUnit(name, unit)!;
    }

    String oldId = listItem[index].id!;
    if (oldId == newId) {
      return;
    }
    listItem[index].id = newId;
    HotelItem? itemTemp = ItemManager().getItemById(newId);
    if (itemTemp != null) {
      listItem[index].warehouse = priorityWarehouse?.name ??
          (WarehouseManager().getActiveWarehouseName().contains(
                  WarehouseManager()
                      .getWarehouseNameById(itemTemp.defaultWarehouseId!))
              ? WarehouseManager()
                  .getWarehouseNameById(itemTemp.defaultWarehouseId!)
              : UITitleUtil.getTitleByCode(UITitleCode.NO));
      notifyListeners();
    }
  }

  void setWarehouse(ItemExport oldItemExport, String newWarehouseName) {
    int index = listItem.indexOf(oldItemExport);
    if (index == -1) {
      return;
    }
    listItem[index].warehouse = newWarehouseName;
    notifyListeners();
  }

  void setDate(DateTime newDate) {
    if (now!.isAtSameMomentAs(newDate)) {
      return;
    }
    now = DateTime(
        newDate.year, newDate.month, newDate.day, now!.hour, now!.minute);
    notifyListeners();
  }

  void setTime(TimeOfDay newTime) {
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now!);
    if (currentTime.hour == newTime.hour && currentTime.minute == now!.minute) {
      return;
    }
    now =
        DateTime(now!.year, now!.month, now!.day, newTime.hour, newTime.minute);
    notifyListeners();
  }

  void removeItem(int index) {
    NeutronInputNumberController removedInput = inputAmounts.elementAt(index)
      ..disposeTextController();
    inputAmounts.removeAt(index);
    (removedInput.getNumber() ?? 0);
    listItem.removeAt(index);
    rebuildStock.removeAt(index);
    notifyListeners();
  }

  void removeAllItem() {
    if (listItem.isEmpty) {
      return;
    }
    for (var e in inputAmounts) {
      e.disposeTextController();
    }
    inputAmounts.clear();
    rebuildStock.clear();
    listItem.clear();
    // finalTotal.value = 0;
    notifyListeners();
  }

  void cloneWarehouse(String warehouse) {
    for (ItemExport item in listItem) {
      item.warehouse = warehouse;
    }
    notifyListeners();
  }

  void onChangeAmount(int index) {
    rebuildStock[index].notifyListeners();
  }

  Future<String> updateExport() async {
    Map<String, dynamic> dataList = {};
    String? convertMessage = convertListToJson(dataList);
    if (convertMessage != null) {
      return convertMessage;
    }
    if (dataList.isEmpty) {
      return MessageCodeUtil.INVALID_DATA;
    }
    if (invoiceNumber!.text.trim().isEmpty) {
      return MessageCodeUtil.INVOICE_NUMBER_CAN_NOT_BE_EMPTY;
    }

    isInProgress = true;
    notifyListeners();

    String result;
    if (isAddFeature!) {
      String newId = NumberUtil.getRandomID();
      result = await warehouseNotesManager.createNote(
          newId,
          now!,
          invoiceNumber!.text,
          WarehouseNotesType.export,
          dataList,
          null,
          warehouses);
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNote newWarehouseNote = WarehouseNoteExport(
            id: newId,
            createdTime: now,
            actualCreated: now,
            creator: UserManager.user!.email,
            invoiceNumber: invoiceNumber!.text,
            list: convertJsonToList(dataList));
        warehouseNotesManager.data.add(newWarehouseNote);
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    } else {
      List<ItemExport> newListItemExport = convertJsonToList(dataList);
      if (listEquals<ItemExport>(newListItemExport, oldExport!.list) &&
          oldExport!.invoiceNumber == invoiceNumber!.text.trim()) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(oldExport!, now!,
          invoiceNumber!.text, WarehouseNotesType.export, dataList, null);
      if (result == MessageCodeUtil.SUCCESS) {
        int index = warehouseNotesManager.data
            .indexWhere((element) => element.id == oldExport!.id);
        (warehouseNotesManager.data[index] as WarehouseNoteExport).list =
            newListItemExport;
        warehouseNotesManager.data[index].creator = UserManager.user!.email;
        warehouseNotesManager.data[index].createdTime = now;
        warehouseNotesManager.data[index].invoiceNumber = invoiceNumber!.text;
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }

  String? convertListToJson(Map<String, dynamic> dataList) {
    warehouses.clear();
    for (ItemExport item in listItem) {
      if (item.id == 'choose-item') {
        continue;
      }
      int index = listItem.indexOf(item);
      double? amount = double.tryParse(
          inputAmounts[index].controller.text.isEmpty
              ? '0'
              : inputAmounts[index].controller.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        return MessageCodeUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE;
      }
      if (item.warehouse == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY;
      }
      String warehouseId = WarehouseManager().getIdByName(item.warehouse!);
      if (warehouseId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
      }
      warehouses[warehouseId] = WarehouseActionType.EXPORT;
      if (dataList.containsKey(item.id)) {
        dataList[item.id][WarehouseManager().getIdByName(item.warehouse!)] =
            (dataList[item.id]
                        [WarehouseManager().getIdByName(item.warehouse!)] ??
                    0) +
                amount;
      } else {
        dataList[item.id!] = <String, double>{};
        dataList[item.id][WarehouseManager().getIdByName(item.warehouse!)] =
            amount;
      }
    }
    return null;
  }

  List<ItemExport> convertJsonToList(Map<String, dynamic> dataList) {
    List<ItemExport> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        Map<String, dynamic> warehouseMap =
            dataList[idItem] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, amount) {
          listItem.add(ItemExport(
              id: idItem, amount: amount as double, warehouse: warehouseId));
        });
      }
    }
    return listItem;
  }

  bool isExportMuchThanInStock(int index) {
    ItemExport itemExport = listItem.elementAt(index);
    num stockAmount = WarehouseManager()
            .getWarehouseByName(itemExport.warehouse!)
            ?.getAmountOfItem(itemExport.id!) ??
        0;
    num exportAmount =
        num.tryParse(inputAmounts[index].controller.text.replaceAll(',', '')) ??
            0;
    if (stockAmount <= 0 || stockAmount < exportAmount) {
      quantityWarning = true;
      return true;
    }
    quantityWarning = false;
    return false;
  }
}
