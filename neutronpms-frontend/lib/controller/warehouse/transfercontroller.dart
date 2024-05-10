import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
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
import '../../../modal/warehouse/warehousenote.dart';
import '../../../modal/warehouse/warehousetransfer/itemtransfer.dart';
import '../../../modal/warehouse/warehousetransfer/warehousenotetransfer.dart';

class TransferController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager warehouseNotesManager;
  WarehouseNoteTransfer? oldTransfer;
  bool? isInProgress = false, quantityWarning = false, isAddFeature;
  DateTime? now;

  List<ItemTransfer> listItem = <ItemTransfer>[];
  List<NeutronInputNumberController> inputAmounts = [];
  List<RebuildNumber> rebuildStock = [];

  TextEditingController? invoiceNumber;

  /// use to check permission
  Map<String, String> warehouses = {};

  TransferController(WarehouseNoteTransfer? transfer,
      this.warehouseNotesManager, bool isImportExcelFile,
      {this.priorityWarehouse}) {
    invoiceNumber = TextEditingController(
        text: transfer?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (transfer == null) {
      isAddFeature = true;
      now = DateTime.now();
      ItemTransfer newItemExport = ItemTransfer(
        id: MessageCodeUtil.CHOOSE_ITEM,
        amount: 0,
        fromWarehouse: priorityWarehouse?.name ??
            UITitleUtil.getTitleByCode(UITitleCode.NO),
        toWarehouse: UITitleUtil.getTitleByCode(UITitleCode.NO),
      );
      listItem.add(newItemExport);
      inputAmounts
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      rebuildStock.add(RebuildNumber(0));
    } else {
      isAddFeature = false;
      now = transfer.createdTime;
      oldTransfer = transfer;
      for (ItemTransfer item in transfer.list!) {
        ItemTransfer temp = ItemTransfer(
          id: item.id,
          amount: item.amount,
          fromWarehouse:
              WarehouseManager().getWarehouseNameById(item.fromWarehouse!),
          toWarehouse:
              WarehouseManager().getWarehouseNameById(item.toWarehouse!),
        );
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        rebuildStock.add(RebuildNumber(0));
      }
    }
    if (isImportExcelFile) {
      isAddFeature = true;
    }
  }

  List<String> getListAvailabelItem() {
    List<String?> allIdItems = ItemManager().getIdsOfActiveItems();
    return allIdItems
        .map((id) => ItemManager().getNameAndUnitByID(id!)!)
        .toList();
  }

  List<String> getAvailabelSupplierNames(
      String idItem, String currentSupplier) {
    List<String> allSuppliers = SupplierManager()
        .dataSuppliers
        .map((supplier) => supplier['name'].toString())
        .toList();
    return allSuppliers;
  }

  List<String> getAvailabelWarehouseNames(
      String idItem, String fromWarehouse, bool isDropdownFromWarehouse,
      {String? toWarehouse}) {
    List<String> allWarehouse = [];

    if (UserManager.canSeeWareHouseManagement()) {
      allWarehouse = WarehouseManager().getActiveWarehouseName();
      if (!isAddFeature!) {
        for (var element in oldTransfer!.list!) {
          String? oldWarehouseName =
              WarehouseManager().getWarehouseNameById(element.fromWarehouse!);
          if (!allWarehouse.contains(oldWarehouseName)) {
            allWarehouse.add(oldWarehouseName!);
          }
        }
      }
      if (toWarehouse != null) {
        for (ItemTransfer itemTransfer in listItem) {
          if (itemTransfer.id == idItem &&
              itemTransfer.fromWarehouse == fromWarehouse &&
              itemTransfer.toWarehouse != toWarehouse) {
            allWarehouse
                .removeWhere((element) => element == itemTransfer.toWarehouse);
          }
        }
        allWarehouse.removeWhere((element) => element == fromWarehouse);
      }
    } else {
      if (isDropdownFromWarehouse) {
        allWarehouse =
            WarehouseManager().getListWarehouseNameHavePermissionExport();
      } else {
        allWarehouse =
            WarehouseManager().getListWarehouseNameHavePermissionImport();

        for (ItemTransfer itemTransfer in listItem) {
          if (itemTransfer.id == idItem &&
              itemTransfer.fromWarehouse == fromWarehouse &&
              itemTransfer.toWarehouse != toWarehouse) {
            allWarehouse
                .removeWhere((element) => element == itemTransfer.toWarehouse);
          }
        }

        allWarehouse.removeWhere((element) => element == fromWarehouse);
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
    ItemTransfer newItemExport = ItemTransfer(
      id: MessageCodeUtil.CHOOSE_ITEM,
      amount: 0,
      fromWarehouse:
          priorityWarehouse?.name ?? UITitleUtil.getTitleByCode(UITitleCode.NO),
      toWarehouse: UITitleUtil.getTitleByCode(UITitleCode.NO),
    );
    listItem.add(newItemExport);
    inputAmounts
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    rebuildStock.add(RebuildNumber(0));
    notifyListeners();
    return true;
  }

  void setItemId(int index, String newValue) {
    int lastIndex = newValue.lastIndexOf('-');
    String? newId;
    if (lastIndex == -1) {
      newId =
          ItemManager().getIdByName(newValue) ?? MessageCodeUtil.CHOOSE_ITEM;
    } else {
      String name = newValue.substring(0, lastIndex).trim();
      String unit = newValue.substring(lastIndex + 1).trim();
      newId = ItemManager().getIdByNameAndUnit(name, unit);
    }
    String? oldId = listItem[index].id;
    if (oldId == newId) {
      return;
    }
    listItem[index].id = newId;

    HotelItem? temp = ItemManager().getItemById(newId!);
    if (temp != null) {
      listItem[index].fromWarehouse = priorityWarehouse?.name ??
          (WarehouseManager().getActiveWarehouseName().contains(
                  WarehouseManager()
                      .getWarehouseNameById(temp.defaultWarehouseId!))
              ? WarehouseManager()
                  .getWarehouseNameById(temp.defaultWarehouseId!)
              : UITitleUtil.getTitleByCode(UITitleCode.NO));
      notifyListeners();
    }
  }

  void setFromWarehouse(int index, String newWarehouseName) {
    listItem[index].fromWarehouse = newWarehouseName;
    if (listItem[index].toWarehouse == newWarehouseName) {
      listItem[index].toWarehouse = UITitleUtil.getTitleByCode(UITitleCode.NO);
    }
    notifyListeners();
  }

  void setToWarehouse(int index, String newWarehouseName) {
    listItem[index].toWarehouse = newWarehouseName;
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
    listItem.removeAt(index);
    inputAmounts.elementAt(index).disposeTextController();
    inputAmounts.removeAt(index);
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
    notifyListeners();
  }

  void cloneFromWarehouse(String warehouse) {
    for (ItemTransfer item in listItem) {
      item.fromWarehouse = warehouse;
      if (item.toWarehouse == warehouse) {
        item.toWarehouse = UITitleUtil.getTitleByCode(UITitleCode.NO);
      }
    }
    notifyListeners();
  }

  void cloneToWarehouse(String warehouse) {
    for (ItemTransfer item in listItem) {
      if (item.fromWarehouse != warehouse) {
        //prevent fromWarehouse == toWarehouse
        item.toWarehouse = warehouse;
      }
    }
    notifyListeners();
  }

  void onChangeAmount(int index) {
    rebuildStock[index].notifyListeners();
  }

  Future<String> updateTransfer() async {
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
          WarehouseNotesType.transfer,
          dataList,
          null,
          warehouses);
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNote newWarehouseNote = WarehouseNoteTransfer(
          id: newId,
          actualCreated: now,
          createdTime: now,
          creator: UserManager.user!.email,
          invoiceNumber: invoiceNumber!.text,
          list: convertJsonToList(dataList),
        );
        warehouseNotesManager.data.add(newWarehouseNote);
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    } else {
      List<ItemTransfer> newListItemTransfer = convertJsonToList(dataList);
      if (listEquals<ItemTransfer>(newListItemTransfer, oldTransfer!.list) &&
          oldTransfer!.invoiceNumber == invoiceNumber!.text.trim()) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(oldTransfer!, now!,
          invoiceNumber!.text, WarehouseNotesType.transfer, dataList, null);
      if (result == MessageCodeUtil.SUCCESS) {
        int index = warehouseNotesManager.data
            .indexWhere((element) => element.id == oldTransfer!.id);
        (warehouseNotesManager.data[index] as WarehouseNoteTransfer).list =
            convertJsonToList(dataList);
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
    for (ItemTransfer item in listItem) {
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
      if (item.fromWarehouse == UITitleUtil.getTitleByCode(UITitleCode.NO) ||
          item.toWarehouse == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY;
      }
      String fromWarehouseId =
          WarehouseManager().getIdByName(item.fromWarehouse!);
      String toWarehouseId = WarehouseManager().getIdByName(item.toWarehouse!);
      if (fromWarehouseId == '' || toWarehouseId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
      }
      if (warehouses.containsKey(fromWarehouseId)) {
        if (warehouses[fromWarehouseId] == WarehouseActionType.IMPORT) {
          warehouses[fromWarehouseId] = WarehouseActionType.BOTH;
        }
      } else {
        warehouses[fromWarehouseId] = WarehouseActionType.EXPORT;
      }

      if (warehouses.containsKey(toWarehouseId)) {
        if (warehouses[toWarehouseId] == WarehouseActionType.EXPORT) {
          warehouses[toWarehouseId] = WarehouseActionType.BOTH;
        }
      } else {
        warehouses[toWarehouseId] = WarehouseActionType.IMPORT;
      }

      if (dataList.containsKey(item.id)) {
        String fromWarehouseId =
            WarehouseManager().getIdByName(item.fromWarehouse!);
        String toWarehouseId =
            WarehouseManager().getIdByName(item.toWarehouse!);
        if ((dataList[item.id] as Map<String, dynamic>)
            .containsKey(fromWarehouseId)) {
          dataList[item.id][fromWarehouseId][toWarehouseId] =
              (dataList[item.id][fromWarehouseId][toWarehouseId] ?? 0) + amount;
        } else {
          dataList[item.id][fromWarehouseId] = <String, dynamic>{};
          dataList[item.id][fromWarehouseId][toWarehouseId] = amount;
        }
      } else {
        dataList[item.id!] = <String, dynamic>{};
        String fromWarehouseId =
            WarehouseManager().getIdByName(item.fromWarehouse!);
        String toWarehouseId =
            WarehouseManager().getIdByName(item.toWarehouse!);
        dataList[item.id][fromWarehouseId] = <String, double>{};
        dataList[item.id][fromWarehouseId][toWarehouseId] =
            (dataList[item.id][fromWarehouseId][toWarehouseId] ?? 0) + amount;
      }
    }
    return null;
  }

  List<ItemTransfer> convertJsonToList(Map<String, dynamic> dataList) {
    List<ItemTransfer> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        Map<String, dynamic> fromWarehouseMap =
            dataList[idItem] as Map<String, dynamic>;
        fromWarehouseMap.forEach((fromWarehouse, toWarehouseMap) {
          (toWarehouseMap as Map<String, dynamic>)
              .forEach((toWarehouse, amount) {
            listItem.add(ItemTransfer(
              id: idItem,
              amount: amount as double,
              fromWarehouse: fromWarehouse,
              toWarehouse: toWarehouse,
            ));
          });
        });
      }
    }
    return listItem;
  }

  bool isTransferMuchThanInStock(int index) {
    ItemTransfer itemTransfer = listItem.elementAt(index);
    num stockAmount = WarehouseManager()
            .getWarehouseByName(itemTransfer.fromWarehouse!)
            ?.getAmountOfItem(itemTransfer.id!) ??
        0;
    num transferAmount =
        num.tryParse(inputAmounts[index].controller.text.replaceAll(',', '')) ??
            0;
    if (stockAmount <= 0 || stockAmount < transferAmount) {
      quantityWarning = true;
      return true;
    }
    quantityWarning = false;
    return false;
  }
}
