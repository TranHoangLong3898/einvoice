import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/warehouse/warehouseimport/warehousenoteimport.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../modal/warehouse/warehouseimport/itemimport.dart';
import '../../../modal/warehouse/warehousereturn/itemreturn.dart';
import '../../../modal/warehouse/warehousereturn/warehousenotereturn.dart';

class ReturnToSupplierController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager warehouseNotesManager;
  WarehouseNoteImport? importNote;
  WarehouseNoteReturn? oldExport;
  bool? isInProgress = false, isAddFeature, quantityWarning = false;
  DateTime? now;

  List<ItemReturn> listItem = <ItemReturn>[];
  List<NeutronInputNumberController> inputAmounts = [];

  /// Rebuild total of each item
  List<RebuildNumber> rebuildStock = [];

  /// Used to display total of all
  RebuildNumber finalTotal = RebuildNumber(0);

  /// use to check permission
  Map<String, String> warehouses = {};

  TextEditingController? invoiceNumber;

  ReturnToSupplierController(WarehouseNoteReturn? returnItem,
      this.warehouseNotesManager, this.importNote,
      {this.priorityWarehouse}) {
    invoiceNumber = TextEditingController(
        text: returnItem?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (returnItem == null) {
      isAddFeature = true;
      now = DateTime.now();
      ItemReturn newItemReturn = ItemReturn(
          id: MessageCodeUtil.CHOOSE_ITEM,
          amount: 0,
          warehouse: priorityWarehouse?.name ??
              UITitleUtil.getTitleByCode(UITitleCode.NO));
      listItem.add(newItemReturn);
      inputAmounts
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      rebuildStock.add(RebuildNumber(0));
    } else {
      isAddFeature = false;
      now = returnItem.createdTime!;
      oldExport = returnItem;
      for (ItemReturn item in returnItem.list!) {
        finalTotal.value += item.price! * item.amount!;
        ItemReturn temp = ItemReturn(
            id: item.id,
            warehouse: WarehouseManager().getWarehouseNameById(item.warehouse!),
            price: item.price,
            amount: item.amount);
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        rebuildStock.add(RebuildNumber(0));
      }
    }
  }

  double getItemAmountInImportNote(Warehouse? warehouse, String itemId) {
    if (itemId == MessageCodeUtil.CHOOSE_ITEM || warehouse == null) {
      return 0;
    }
    try {
      return importNote!.list!
          .firstWhere((element) =>
              element.id == itemId && element.warehouse == warehouse.id)
          .amount!;
    } catch (e) {
      return 0;
    }
  }

  List<String> getListAvailabelItem() {
    List<String> allIdItems = [];
    for (var element in importNote!.list!) {
      if (!allIdItems.contains(element.id)) {
        allIdItems.add(element.id!);
      }
    }

    return allIdItems
        .map((id) => ItemManager().getNameAndUnitByID(id)!)
        .toList();
  }

  List<String> getAvailabelWarehouseNames(
      String idItem, String currentWarehouse) {
    List<String> allWarehouse = [];
    WarehouseManager().warehouses.map((e) => e.name).toList();
    if (UserManager.canSeeWareHouseManagement()) {
      for (var element
          in importNote!.list!.where((item) => item.id == idItem)) {
        if (!allWarehouse.contains(
            WarehouseManager().getWarehouseNameById(element.warehouse!))) {
          allWarehouse.add(
              WarehouseManager().getWarehouseNameById(element.warehouse!)!);
        }
      }
    } else {
      List<String> listHasPermissionWarehouse =
          WarehouseManager().getListWarehouseNameHavePermissionExport();
      allWarehouse = importNote!.list!
          .where((item) => item.id == idItem)
          .map((e) => e.warehouse!)
          .toList();
      allWarehouse.removeWhere(
          (element) => !listHasPermissionWarehouse.contains(element));
    }

    for (ItemReturn itemReturn in listItem) {
      if (itemReturn.id == idItem && itemReturn.warehouse != currentWarehouse) {
        allWarehouse.removeWhere((element) => element == itemReturn.warehouse);
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
    ItemReturn newItemReturn = ItemReturn(
        id: MessageCodeUtil.CHOOSE_ITEM,
        amount: 0,
        price: 0,
        warehouse: priorityWarehouse?.name ??
            UITitleUtil.getTitleByCode(UITitleCode.NO));
    listItem.add(newItemReturn);
    inputAmounts
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    rebuildStock.add(RebuildNumber(0));
    notifyListeners();
    return true;
  }

  double getPrice(String itemId, String warehouseId) {
    try {
      return importNote!.list!
          .firstWhere((element) =>
              element.id == itemId && warehouseId == element.warehouse)
          .price!;
    } catch (e) {
      return 0;
    }
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
      listItem[index].warehouse =
          priorityWarehouse?.name ?? UITitleUtil.getTitleByCode(UITitleCode.NO);
      notifyListeners();
    }
  }

  void setWarehouse(ItemReturn oldItemReturn, String newWarehouseName) {
    int index = listItem.indexOf(oldItemReturn);
    if (index == -1) {
      return;
    }
    listItem[index].warehouse = newWarehouseName;
    listItem[index].price = getPrice(
        listItem[index].id!, WarehouseManager().getIdByName(newWarehouseName));
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
    ItemReturn removedItem = listItem.removeAt(index);
    NeutronInputNumberController removedInput = inputAmounts.elementAt(index)
      ..disposeTextController();
    inputAmounts.removeAt(index);
    finalTotal.value -= removedItem.price! * (removedInput.getNumber() ?? 0);
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
    finalTotal.value = 0;
    notifyListeners();
  }

  void cloneWarehouse(String warehouse) {
    for (ItemReturn item in listItem) {
      item.warehouse = warehouse;
    }
    notifyListeners();
  }

  void onChangeAmount(int index) {
    finalTotal.value = 0;
    for (var i = 0; i < inputAmounts.length; i++) {
      Iterable<ItemImport> itemImports = importNote!.list!.where((importItem) =>
          importItem.id == listItem[i].id &&
          importItem.warehouse ==
              WarehouseManager().getIdByName(listItem[i].warehouse!));

      ItemImport? itemImport = itemImports.isEmpty ? null : itemImports.first;
      finalTotal.value += (itemImport == null ? 0 : itemImport.price)! *
          inputAmounts[i].getNumber()!;
    }
    rebuildStock[index].notifyListeners();
    finalTotal.notifyListeners();
  }

  Future<String> updateReturnNote() async {
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
          WarehouseNotesType.returnToSupplier,
          dataList,
          importNote!.invoiceNumber,
          warehouses);
    } else {
      List<ItemReturn> newListItemReturn = convertJsonToList(dataList);
      if (listEquals<ItemReturn>(newListItemReturn, oldExport!.list) &&
          oldExport!.invoiceNumber == invoiceNumber!.text.trim()) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(
          oldExport!,
          now!,
          invoiceNumber!.text,
          WarehouseNotesType.returnToSupplier,
          dataList,
          importNote!.invoiceNumber);
    }
    print(22222222222);
    print(result);
    isInProgress = false;
    notifyListeners();
    return result;
  }

  String? convertListToJson(Map<String, dynamic> dataList) {
    warehouses.clear();

    for (var i = 0; i < listItem.length; i++) {
      if (listItem[i].id == 'choose-item') {
        continue;
      }
      int index = listItem.indexOf(listItem[i]);
      double? amount = double.tryParse(
          inputAmounts[index].controller.text.isEmpty
              ? '0'
              : inputAmounts[index].controller.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        return MessageCodeUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE;
      }
      if (isExportMuchThanInStock(i)) {
        return MessageCodeUtil
            .TEXTALERT_AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE;
      }
      if (listItem[i].warehouse == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY;
      }

      double? price = listItem[i].price;
      String warehouseId =
          WarehouseManager().getIdByName(listItem[i].warehouse!);
      if (warehouseId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
      }

      warehouses[warehouseId] = WarehouseActionType.EXPORT;

      if (dataList.containsKey(listItem[i].id)) {
        bool isExisted =
            false; //true if having the same warehouse, price, supplier
        for (Map<String, dynamic> map
            in (dataList[listItem[i].id] as List<Map<String, dynamic>>)) {
          if (map['warehouse'] == warehouseId && map['price'] == price) {
            isExisted = true;
            map['amount'] += amount;
            break;
          }
        }
        if (!isExisted) {
          Map<String, dynamic> map = {};
          map['warehouse'] = warehouseId;
          map['price'] = price;
          map['amount'] = amount;
          dataList[listItem[i].id].add(map);
        }
      } else {
        dataList[listItem[i].id!] = <Map<String, dynamic>>[];
        Map<String, dynamic> map = {};
        map['warehouse'] = warehouseId;
        map['price'] = price;
        map['amount'] = amount;
        dataList[listItem[i].id].add(map);
      }
    }
    return null;
  }

  List<ItemReturn> convertJsonToList(Map<String, dynamic> dataList) {
    List<ItemReturn> listItem = [];
    if (dataList.isNotEmpty) {
      dataList.forEach((idItem, arrayData) {
        for (dynamic objData in (arrayData as List<dynamic>)) {
          listItem.add(ItemReturn(
              id: idItem,
              amount: objData['amount'].toDouble(),
              price: objData['price'].toDouble(),
              warehouse: objData['warehouse']));
        }
      });
    }
    return listItem;
  }

  bool isExportMuchThanInStock(int index) {
    ItemReturn itemReturn = listItem.elementAt(index);
    num stockAmount = getItemAmountInImportNote(
        WarehouseManager().getWarehouseByName(itemReturn.warehouse!),
        itemReturn.id!);
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
