import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/warehouse/warehouselost/warehousenotelost.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../modal/warehouse/warehouselost/itemlost.dart';
import '../../../modal/warehouse/warehousenote.dart';

class LostController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager warehouseNotesManager;
  WarehouseNoteLost? oldLost;
  bool isInProgress = false;
  bool? isAddFeature;
  DateTime? now;

  List<ItemLost> listItem = <ItemLost>[];
  List<NeutronInputNumberController> inputAmounts = [];
  TextEditingController? invoiceNumber;
  List<RebuildNumber> rebuildTotal = [];

  /// Used to display total of all
  RebuildNumber finalTotal = RebuildNumber(0);

  /// use to check permission
  Map<String, String> warehouses = {};

  LostController(WarehouseNoteLost? lost, this.warehouseNotesManager,
      bool isImportExcelFile,
      {this.priorityWarehouse}) {
    invoiceNumber = TextEditingController(
        text: lost?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (lost == null) {
      isAddFeature = true;
      now = DateTime.now();
      addItemToList();
      rebuildTotal.add(RebuildNumber(0));
    } else {
      isAddFeature = false;
      now = lost.createdTime;
      oldLost = lost;
      for (ItemLost item in lost.list!) {
        finalTotal.value +=
            ItemManager().getItemById(item.id!)!.costPrice! * item.amount!;
        ItemLost temp = ItemLost(
          id: item.id,
          warehouse: WarehouseManager().getWarehouseNameById(item.warehouse!),
          amount: item.amount,
          status: item.status,
        );
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        rebuildTotal.add(RebuildNumber(0));
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

  List<String> getAvailabelWarehouseNames() {
    List<String> allWarehouse = WarehouseManager().getActiveWarehouseName();
    if (!isAddFeature!) {
      for (var element in oldLost!.list!) {
        String? oldWarehouseName =
            WarehouseManager().getWarehouseNameById(element.warehouse!);
        if (!allWarehouse.contains(oldWarehouseName)) {
          allWarehouse.add(oldWarehouseName!);
        }
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
    ItemLost newItemLost = ItemLost(
      id: MessageCodeUtil.CHOOSE_ITEM,
      amount: 0,
      warehouse:
          priorityWarehouse?.name ?? UITitleUtil.getTitleByCode(UITitleCode.NO),
      status: LostStatus.lost,
    );
    listItem.add(newItemLost);
    inputAmounts.add(NeutronInputNumberController(TextEditingController()));
    rebuildTotal.add(RebuildNumber(0));
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

    HotelItem? itemTemp = ItemManager().getItemById(newId!);
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

  void setWarehouse(ItemLost oldItemLost, String newWarehouseName) {
    int index = listItem.indexOf(oldItemLost);
    if (index == -1) {
      return;
    }
    listItem[index].warehouse = newWarehouseName;
    notifyListeners();
  }

  void setStatus(ItemLost item, String newStatus) {
    if (newStatus == MessageUtil.getMessageByCode(MessageCodeUtil.LOST)) {
      item.status = LostStatus.lost;
    } else if (newStatus ==
        MessageUtil.getMessageByCode(MessageCodeUtil.EXPIRED)) {
      item.status = LostStatus.expired;
    } else {
      item.status = LostStatus.broken;
    }
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
    ItemLost removedItem = listItem.removeAt(index);
    NeutronInputNumberController removedInput = inputAmounts.elementAt(index)
      ..disposeTextController();
    inputAmounts.removeAt(index);
    finalTotal.value -=
        (ItemManager().getItemById(removedItem.id!)?.costPrice ?? 0) *
            (removedInput.getNumber() ?? 0);
    rebuildTotal.removeAt(index);
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
    rebuildTotal.clear();
    listItem.clear();
    finalTotal.value = 0;
    notifyListeners();
  }

  void cloneWarehouse(String warehouse) {
    for (ItemLost item in listItem) {
      item.warehouse = warehouse;
    }
    notifyListeners();
  }

  void cloneStatus(String newStatus) {
    for (ItemLost item in listItem) {
      item.status = newStatus;
    }
    notifyListeners();
  }

  void onChangeAmount(int index) {
    finalTotal.value = 0;
    for (var element in inputAmounts) {
      finalTotal.value += (ItemManager()
                  .getItemById(listItem[inputAmounts.indexOf(element)].id!)
                  ?.costPrice ??
              0) *
          (element.getNumber() ?? 0);
    }
    rebuildTotal[index].notifyListeners();
    finalTotal.notifyListeners();
  }

  Future<String> updateLost() async {
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
          WarehouseNotesType.lost,
          dataList,
          null,
          warehouses);
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNote newWarehouseNote = WarehouseNoteLost(
          id: newId,
          actualCreated: now,
          createdTime: now,
          invoiceNumber: invoiceNumber!.text,
          creator: UserManager.user!.email,
          list: convertJsonToList(dataList),
        );
        warehouseNotesManager.data.add(newWarehouseNote);
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    } else {
      List<ItemLost> newListItemLost = convertJsonToList(dataList);
      if (listEquals<ItemLost>(newListItemLost, oldLost!.list) &&
          oldLost!.invoiceNumber == invoiceNumber!.text.trim()) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(oldLost!, now!,
          invoiceNumber!.text, WarehouseNotesType.lost, dataList, null);
      if (result == MessageCodeUtil.SUCCESS) {
        int index = warehouseNotesManager.data
            .indexWhere((element) => element.id == oldLost!.id);
        (warehouseNotesManager.data[index] as WarehouseNoteLost).list =
            newListItemLost;
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
    for (ItemLost item in listItem) {
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

      warehouses[WarehouseManager().getIdByName(item.warehouse!)] =
          WarehouseActionType.EXPORT;

      if (dataList.containsKey(item.id)) {
        String warehouseId = WarehouseManager().getIdByName(item.warehouse!);
        if (warehouseId == '') {
          return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
        }
        if (dataList[item.id].containsKey(warehouseId)) {
          if (dataList[item.id][warehouseId].containsKey(item.status)) {
            dataList[item.id][warehouseId][item.status] =
                (dataList[item.id][warehouseId][item.status] ?? 0) + amount;
          } else {
            dataList[item.id][warehouseId][item.status] = amount;
          }
        } else {
          dataList[item.id][warehouseId] = {
            item.status: amount,
          };
        }
      } else {
        dataList[item.id!] = <String, Map>{
          WarehouseManager().getIdByName(item.warehouse!): {
            item.status: amount,
          }
        };
      }
    }
    return null;
  }

  List<ItemLost> convertJsonToList(Map<String, dynamic> dataList) {
    if (dataList.isEmpty) return [];

    List<ItemLost> listItem = [];
    for (MapEntry<String, dynamic> entry in dataList.entries) {
      String itemId = entry.key;
      (entry.value as Map<String, dynamic>).forEach((warehouseId, value) {
        (value as Map<dynamic, dynamic>).forEach((status, amount) {
          listItem.add(ItemLost(
            id: itemId,
            amount: amount.toDouble(),
            status: status,
            warehouse: warehouseId,
          ));
        });
      });
    }
    return listItem;
  }
}
