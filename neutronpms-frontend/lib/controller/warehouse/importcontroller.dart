import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/warehouse/warehousereturn/warehousenotereturn.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../modal/warehouse/warehouseimport/itemimport.dart';
import '../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../modal/warehouse/warehousenote.dart';
import '../rebuildnumber.dart';

class ImportController extends ChangeNotifier {
  Warehouse? priorityWarehouse;
  WarehouseNotesManager? warehouseNotesManager;
  WarehouseNoteImport? oldImport;
  bool isInProgress = false;
  bool? isAddFeature;
  DateTime? now;
  TextEditingController? invoiceNumber;

  ///use for compensation
  WarehouseNoteImport? importNoteForCompensation;
  bool isCompensation = false;
  WarehouseNoteReturn? returnNote;

  List<ItemImport> listItem = [];
  List<NeutronInputNumberController> inputAmounts = [];
  List<NeutronInputNumberController> inputPrices = [];

  List<RebuildNumber> listTotal = []; //subtotal : total of each item
  RebuildNumber finalTotal = RebuildNumber(0); //total of all

  /// use to check permission
  Map<String, String> warehouses = {};

  ImportController(WarehouseNoteImport? import, this.warehouseNotesManager,
      bool isImportExcelFile,
      {this.priorityWarehouse,
      this.importNoteForCompensation,
      this.returnNote}) {
    invoiceNumber = TextEditingController(
        text: import?.invoiceNumber ?? NumberUtil.getRandomString(8));
    if (import == null) {
      isAddFeature = true;
      now = DateTime.now();
      ItemImport newItemImport = ItemImport(
          id: MessageCodeUtil.CHOOSE_ITEM,
          supplier: UITitleUtil.getTitleByCode(UITitleCode.NO),
          price: 0,
          amount: 0,
          warehouse: priorityWarehouse?.name ??
              UITitleUtil.getTitleByCode(UITitleCode.NO));
      listItem.add(newItemImport);
      inputAmounts
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      inputPrices
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      listTotal.add(RebuildNumber(0));
    } else {
      isAddFeature = false;
      now = import.createdTime;
      oldImport = import;
      for (ItemImport item in import.list!) {
        finalTotal.value += item.price! * item.amount!;
        ItemImport temp = ItemImport(
          id: item.id,
          supplier: SupplierManager().getSupplierNameByID(item.supplier),
          warehouse: WarehouseManager().getWarehouseNameById(item.warehouse!) ??
              UITitleUtil.getTitleByCode(UITitleCode.NO),
        );
        listItem.add(temp);
        inputAmounts.add(NeutronInputNumberController(
            TextEditingController(text: item.amount.toString())));
        inputPrices.add(NeutronInputNumberController(
            TextEditingController(text: item.price.toString())));
        listTotal.add(RebuildNumber(item.amount! * item.price!));
      }
    }
    if (isImportExcelFile) isAddFeature = true;

    if (importNoteForCompensation != null && returnNote != null) {
      isCompensation = true;
    }
  }

  List<String> getListAvailabelItem() {
    List<String?> allIdItems = [];
    if (isCompensation) {
      allIdItems = returnNote!.list!.map((e) => e.id!).toSet().toList();
    } else {
      allIdItems = ItemManager().getIdsOfActiveItems();
    }
    return allIdItems
        .map((id) => ItemManager().getNameAndUnitByID(id!)!)
        .toList();
  }

  List<String> getAvailabelSupplierNames(
      String idItem, String currentSupplier) {
    List<String> allSuppliers = SupplierManager().getActiveSupplierNames();
    if (!isAddFeature!) {
      for (var element in oldImport!.list!) {
        String oldSupplierName =
            SupplierManager().getSupplierNameByID(element.supplier);
        if (!allSuppliers.contains(oldSupplierName)) {
          allSuppliers.add(oldSupplierName);
        }
      }
    }
    return allSuppliers;
  }

  List<String> getAvailabelWarehouseNames(String idItem) {
    List<String> allWarehouse = [];
    if (UserManager.canSeeWareHouseManagement()) {
      allWarehouse = WarehouseManager().getActiveWarehouseName();
    } else {
      allWarehouse =
          WarehouseManager().getListWarehouseNameHavePermissionImport();
    }
    if (!isAddFeature!) {
      for (var element in oldImport!.list!) {
        String? oldWarehouseName =
            WarehouseManager().getWarehouseNameById(element.warehouse!);
        if (!allWarehouse.contains(oldWarehouseName)) {
          allWarehouse.add(oldWarehouseName!);
        }
      }
    }
    return allWarehouse;
  }

// use for compensation
  List<String> getSuppliersByItemId(String itemId) {
    return importNoteForCompensation!.list!
        .where((element) => element.id == itemId)
        .map((e) => SupplierManager().getSupplierNameByID(e.supplier))
        .toList();
  }

// use for compensation
  List<String> getWarehousesByItemId(String itemId) {
    return importNoteForCompensation!.list!
        .where((element) => element.id == itemId)
        .map((e) => WarehouseManager().getWarehouseNameById(e.warehouse!)!)
        .toList();
  }

  bool addItemToList() {
    if (listItem
        .where((element) => element.id == MessageCodeUtil.CHOOSE_ITEM)
        .isNotEmpty) {
      return false;
    }
    ItemImport newItemImport = ItemImport(
        id: MessageCodeUtil.CHOOSE_ITEM,
        supplier: UITitleUtil.getTitleByCode(UITitleCode.NO),
        price: 0,
        amount: 0,
        warehouse: priorityWarehouse?.name ??
            UITitleUtil.getTitleByCode(UITitleCode.NO));
    listItem.add(newItemImport);
    inputAmounts
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    inputPrices
        .add(NeutronInputNumberController(TextEditingController(text: '')));
    listTotal.add(RebuildNumber(0));
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
                      .getWarehouseNameById(temp.defaultWarehouseId!)!)
              ? WarehouseManager()
                  .getWarehouseNameById(temp.defaultWarehouseId!)
              : UITitleUtil.getTitleByCode(UITitleCode.NO));
      notifyListeners();
    }
  }

  void setIsCompensation(bool value) {
    if (isCompensation == value) return;
    isCompensation = value;
    notifyListeners();
  }

  void setSupplier(int index, String newSupplierName) {
    listItem[index].supplier = newSupplierName;
    notifyListeners();
  }

  void setWarehouse(ItemImport oldItemImport, String newWarehouseName) {
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
    inputPrices.elementAt(index).disposeTextController();
    inputPrices.removeAt(index);
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
    listItem.clear();
    listTotal.clear();
    finalTotal.value = 0;
    notifyListeners();
  }

  void cloneWarehouse(String warehouse) {
    for (ItemImport item in listItem) {
      item.warehouse = warehouse;
    }
    notifyListeners();
  }

  void cloneSupplier(String supplier) {
    for (ItemImport item in listItem) {
      item.supplier = supplier;
    }
    notifyListeners();
  }

  Future<String> updateImport() async {
    Map<String, List> dataList = {};
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
      result = await warehouseNotesManager!.createNote(
          newId,
          now!,
          invoiceNumber!.text,
          WarehouseNotesType.import,
          dataList,
          returnNote?.invoiceNumber,
          warehouses);
      if (result == MessageCodeUtil.SUCCESS && !isCompensation) {
        WarehouseNote newWarehouseNote = WarehouseNoteImport(
            id: newId,
            actualCreated: now,
            createdTime: now,
            invoiceNumber: invoiceNumber!.text,
            returnInvoiceNum: '',
            creator: UserManager.user!.email,
            totalCost: 0,
            list: convertJsonToList(dataList));
        warehouseNotesManager!.data.add(newWarehouseNote);
        warehouseNotesManager!.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager!.updateIndex();
        warehouseNotesManager!.notifyListeners();
      }
    } else {
      List<ItemImport> newListItemImport = convertJsonToList(dataList);
      if (listEquals<ItemImport>(newListItemImport, oldImport!.list) &&
          oldImport!.invoiceNumber == invoiceNumber!.text) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager!.updateNote(
          oldImport!,
          now!,
          invoiceNumber!.text,
          WarehouseNotesType.import,
          dataList,
          returnNote?.invoiceNumber);
      if (result == MessageCodeUtil.SUCCESS && !isCompensation) {
        int index = warehouseNotesManager!.data
            .indexWhere((element) => element.id == oldImport!.id);
        (warehouseNotesManager!.data[index] as WarehouseNoteImport).list =
            newListItemImport;
        warehouseNotesManager!.data[index].creator = UserManager.user!.email;
        warehouseNotesManager!.data[index].createdTime = now;
        warehouseNotesManager!.data[index].invoiceNumber = invoiceNumber!.text;
        (warehouseNotesManager!.data[index] as WarehouseNoteImport)
            .returnInvoiceNum = '';
        warehouseNotesManager!.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        warehouseNotesManager!.updateIndex();
        warehouseNotesManager!.notifyListeners();
      }
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }

  String? convertListToJson(Map<String, List> dataList) {
    warehouses.clear();
    for (ItemImport item in listItem) {
      if (item.id == 'choose-item') {
        continue;
      }
      if (!ItemManager().isContainId(item.id!)) {
        return MessageCodeUtil.INVALID_ITEM;
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
      if (item.supplier == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_SUPPLIER_CAN_NOT_BE_EMPTY;
      }
      if (item.warehouse == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
        return MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY;
      }
      String warehouseId = WarehouseManager().getIdByName(item.warehouse!);

      warehouses[warehouseId] = WarehouseActionType.IMPORT;
      String? supplierId =
          SupplierManager().getSupplierIDByName(item.supplier!);
      if (supplierId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_SUPPLIER;
      }
      if (warehouseId == '') {
        return MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE;
      }
      if (dataList.containsKey(item.id)) {
        bool isExisted =
            false; //true if having the same warehouse, price, supplier
        for (Map<String, dynamic> map
            in (dataList[item.id] as List<Map<String, dynamic>>)) {
          if (map['warehouse'] == warehouseId &&
              map['price'] == price &&
              map['supplier'] == supplierId) {
            isExisted = true;
            map['amount'] += amount;
            break;
          }
        }
        if (!isExisted) {
          Map<String, dynamic> map = {};
          map['warehouse'] = warehouseId;
          map['price'] = price;
          map['supplier'] = supplierId;
          map['amount'] = amount;
          dataList[item.id]!.add(map);
        }
      } else {
        dataList[item.id!] = <Map<String, dynamic>>[];
        Map<String, dynamic> map = {};
        map['warehouse'] = warehouseId;
        map['price'] = price;
        map['supplier'] = supplierId;
        map['amount'] = amount;
        dataList[item.id]!.add(map);
      }
    }
    return null;
  }

  List<ItemImport> convertJsonToList(Map<String, List> dataList) {
    List<ItemImport> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        for (dynamic objData in dataList[idItem]!) {
          listItem.add(ItemImport(
              id: idItem,
              amount: objData['amount'] as double,
              price: objData['price'],
              supplier: objData['supplier'],
              warehouse: objData['warehouse']));
        }
      }
    }
    return listItem;
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
  }
}
