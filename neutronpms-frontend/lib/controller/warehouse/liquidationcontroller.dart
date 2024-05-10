import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../../../modal/warehouse/warehouseliquidation/itemliquidation.dart';
import '../../../modal/warehouse/warehouseliquidation/warehousenoteliquidation.dart';
import '../../../modal/warehouse/warehousenote.dart';
import '../rebuildnumber.dart';

class LiquidationController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager warehouseNotesManager;
  WarehouseNoteLiquidation? oldLiquidation;
  bool? isInProgress = false, quantityWarning = false, isAddFeature;
  DateTime? now;
  TextEditingController? invoiceNumber;
  String? oldInvoiceNumber;

  List<ItemLiquidation> listItem = [];
  List<NeutronInputNumberController> inputAmounts = [];
  List<NeutronInputNumberController> inputPrices = [];

  List<RebuildNumber> rebuildStock = [];
  List<RebuildNumber> listTotal = []; //subtotal : total of each item
  RebuildNumber finalTotal = RebuildNumber(0); //total of all

  /// use to check permission
  Map<String, String> warehouses = {};

  LiquidationController(WarehouseNoteLiquidation? import,
      this.warehouseNotesManager, bool isImportExcelFile,
      {this.priorityWarehouse}) {
    invoiceNumber = TextEditingController(
        text: import?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (import == null) {
      isAddFeature = true;
      now = DateTime.now();
      ItemLiquidation newItemImport = ItemLiquidation(
          id: MessageCodeUtil.CHOOSE_ITEM,
          price: 0,
          amount: 0,
          warehouse: priorityWarehouse?.name ?? '');
      listItem.add(newItemImport);
      inputAmounts
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      listTotal.add(RebuildNumber(0));
      rebuildStock.add(RebuildNumber(0));
      inputPrices
          .add(NeutronInputNumberController(TextEditingController(text: '')));
    } else {
      isAddFeature = false;
      now = import.createdTime;
      oldLiquidation = import;
      oldInvoiceNumber = import.invoiceNumber;
      for (ItemLiquidation item in import.list!) {
        finalTotal.value += item.price! * item.amount!;
        ItemLiquidation temp = ItemLiquidation(
          id: item.id,
          warehouse: WarehouseManager().getWarehouseNameById(item.warehouse!),
        );
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        inputPrices.add(NeutronInputNumberController(
            TextEditingController(text: item.price.toString())));
        listTotal.add(RebuildNumber(item.amount! * item.price!));
        rebuildStock.add(RebuildNumber(0));
      }
    }
  }

  List<String>? getListAvailabelItem() {
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
      String idItem, String currentWarehouse) {
    List<String> allWarehouse = WarehouseManager().getActiveWarehouseName();
    if (!isAddFeature!) {
      for (var element in oldLiquidation!.list!) {
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
    ItemLiquidation newItemImport = ItemLiquidation(
        id: MessageCodeUtil.CHOOSE_ITEM,
        price: 0,
        amount: 0,
        warehouse: priorityWarehouse?.name ?? '');
    listItem.add(newItemImport);
    inputAmounts
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    listTotal.add(RebuildNumber(0));
    rebuildStock.add(RebuildNumber(0));
    inputPrices
        .add(NeutronInputNumberController(TextEditingController(text: '')));
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
      inputPrices[index].controller.text =
          NumberUtil.numberFormat.format(temp.costPrice);
      listItem[index].warehouse = priorityWarehouse?.name ??
          (WarehouseManager().getActiveWarehouseName().contains(
                  WarehouseManager()
                      .getWarehouseNameById(temp.defaultWarehouseId!))
              ? WarehouseManager()
                  .getWarehouseNameById(temp.defaultWarehouseId!)
              : UITitleUtil.getTitleByCode(UITitleCode.NO));
      notifyListeners();
    }
  }

  void setWarehouse(ItemLiquidation oldItemImport, String newWarehouseName) {
    int index = listItem.indexOf(oldItemImport);
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
    listItem.removeAt(index);
    inputAmounts.elementAt(index).disposeTextController();
    inputAmounts.removeAt(index);
    rebuildStock.removeAt(index);
    finalTotal.value -= listTotal.elementAt(index).value;
    listTotal.removeAt(index);
    notifyListeners();
  }

  void removeAllItem() {
    if (listItem.isEmpty) {
      return;
    }
    for (var e in inputAmounts) {
      e.disposeTextController();
    }
    inputPrices.clear();
    inputAmounts.clear();
    rebuildStock.clear();
    listItem.clear();
    listTotal.clear();
    finalTotal.value = 0;
    notifyListeners();
  }

  void rebuildTotal(int index) {
    num amount =
        num.tryParse(inputAmounts[index].controller.text.replaceAll(',', '')) ??
            0;
    num price =
        num.tryParse(inputPrices[index].controller.text.replaceAll(',', '')) ??
            0;
    num subTotal = amount * price;
    listTotal[index].rebuild(subTotal);
    num total = listTotal.fold(
        0, (previousValue, element) => previousValue + element.value);
    finalTotal.rebuild(total);
    rebuildStock[index].notifyListeners();
  }

  void cloneWarehouse(String warehouse) {
    for (ItemLiquidation item in listItem) {
      item.warehouse = warehouse;
    }
    notifyListeners();
  }

  Future<String> updateLiquidation() async {
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
          WarehouseNotesType.liquidation,
          dataList,
          null,
          warehouses);
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNote newWarehouseNote = WarehouseNoteLiquidation(
            id: newId,
            actualCreated: now,
            createdTime: now,
            invoiceNumber: invoiceNumber?.text,
            creator: UserManager.user!.email,
            list: convertJsonToList(dataList));
        warehouseNotesManager.data.add(newWarehouseNote);
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    } else {
      List<ItemLiquidation> newListItemLiquidation =
          convertJsonToList(dataList);
      if (listEquals<ItemLiquidation>(
              newListItemLiquidation, oldLiquidation!.list) &&
          oldInvoiceNumber == invoiceNumber!.text) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(oldLiquidation!, now!,
          invoiceNumber!.text, WarehouseNotesType.liquidation, dataList, null);
      if (result == MessageCodeUtil.SUCCESS) {
        int index = warehouseNotesManager.data
            .indexWhere((element) => element.id == oldLiquidation!.id);
        (warehouseNotesManager.data[index] as WarehouseNoteLiquidation).list =
            newListItemLiquidation;
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
    for (ItemLiquidation item in listItem) {
      if (item.id == 'choose-item') {
        continue;
      }
      if (item.warehouse == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY;
      }
      int index = listItem.indexOf(item);
      double? price = double.tryParse(inputPrices[index].controller.text.isEmpty
          ? '0'
          : inputPrices[index].controller.text.replaceAll(',', ''));
      if (price == null) {
        return MessageCodeUtil.PRICE_MUST_BE_NUMBER;
      }
      double? amount = double.tryParse(
          inputAmounts[index].controller.text.isEmpty
              ? '0'
              : inputAmounts[index].controller.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        return MessageCodeUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE;
      }
      String warehouseId = WarehouseManager().getIdByName(item.warehouse!);
      if (warehouseId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
      }
      warehouses[warehouseId] = WarehouseActionType.EXPORT;
      if (dataList.containsKey(item.id)) {
        bool isExisted =
            false; //true if having the same warehouse, price, supplier
        for (Map<String, dynamic> map
            in (dataList[item.id] as List<Map<String, dynamic>>)) {
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
          dataList[item.id].add(map);
        }
      } else {
        dataList[item.id!] = <Map<String, dynamic>>[];
        Map<String, dynamic> map = {};
        map['warehouse'] = warehouseId;
        map['price'] = price;
        map['amount'] = amount;
        dataList[item.id].add(map);
      }
    }
    return null;
  }

  List<ItemLiquidation> convertJsonToList(Map<String, dynamic> dataList) {
    List<ItemLiquidation> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        for (dynamic objData in dataList[idItem]) {
          listItem.add(ItemLiquidation(
              id: idItem,
              amount: objData['amount'] as double,
              price: objData['price'],
              warehouse: objData['warehouse']));
        }
      }
    }
    return listItem;
  }

  bool isLiquidationMuchThanInStock(int index) {
    ItemLiquidation itemLiquidation = listItem.elementAt(index);
    num stockAmount = WarehouseManager()
            .getWarehouseByName(itemLiquidation.warehouse!)
            ?.getAmountOfItem(itemLiquidation.id!) ??
        0;
    num liquidationAmount =
        num.tryParse(inputAmounts[index].controller.text.replaceAll(',', '')) ??
            0;
    if (stockAmount <= 0 || stockAmount < liquidationAmount) {
      quantityWarning = true;
      return true;
    }
    quantityWarning = false;
    return false;
  }
}
