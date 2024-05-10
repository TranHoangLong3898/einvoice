import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/warehouse/warehousenote.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../modal/warehouse/inventory/inventorycheck.dart';
import '../../../modal/warehouse/inventory/warehousechecknote.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../ui/controls/neutrontextformfield.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/uimultilanguageutil.dart';

class InventoryCheckController extends ChangeNotifier {
  WarehouseNotesManager warehouseNotesManager;
  bool? isInProgress = false, isAddFeature;
  Map<String, bool> categoryAndType = {}, listType = {};
  int? pageIndex = 0, startIndex, endIndex, pageSize = 20;
  WarehouseNoteCheck? oldInventoryCheck;
  TextEditingController? invoiceNumber, note;
  List<NeutronInputNumberController> inputActualInventory = [], inputPrice = [];
  List<TextEditingController> inputNotes = [];
  String? status, creator, checker;
  double progressWidth = 0;
  DateTime? createTime, checkTime;

  List<ItemInventory> listItem = [];
  // just use when add multiple item
  List<ItemInventory> tempList = [];

  String? addMulltipleSearch;
  String warehouse = UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE;
  String item = UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE_ITEM);

  /// use to check warehouse permission
  Map<String, String> warehouseActions = {};
  InventoryCheckController(
    WarehouseNoteCheck? inventoryCheck,
    this.warehouseNotesManager,
  ) {
    categoryAndType = {"all": false, "type": false, "category": false};
    invoiceNumber = TextEditingController(
        text: inventoryCheck?.invoiceNumber ?? NumberUtil.getRandomString(8));
    note = TextEditingController(text: inventoryCheck?.note ?? '');
    creator = inventoryCheck?.creator ?? UserManager.user!.email;
    checker = inventoryCheck?.checker ?? '';
    status = inventoryCheck?.status ?? InventorySatus.CREATELIST;
    createTime = inventoryCheck?.createdTime ?? DateTime.now();
    checkTime = inventoryCheck?.checkTime ?? DateTime.now();
    warehouse =
        inventoryCheck?.warehouse ?? UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE;
    ItemTypesUlti.getItemTypes().forEach((element) {
      listType[element] = false;
    });

    // for (var element in ItemManager().itemCategories) {
    //   listCategory[element.id] = false;
    // }
    if (inventoryCheck != null) {
      oldInventoryCheck = inventoryCheck;
      for (var item in inventoryCheck.list!) {
        listItem.add(ItemInventory(
            id: item.id,
            actualAmount: item.actualAmount,
            amount: item.amount,
            note: item.note));
      }
    }
    for (var i = 0; i < listItem.length; i++) {
      inputActualInventory
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      inputNotes.add(TextEditingController(text: ''));
    }

    updateIndex();
    changeStatus(status!);
  }

  List<String> getAvailabelWarehouseNames() {
    List<String> allWarehouse = [];
    if (UserManager.canSeeWareHouseManagement()) {
      allWarehouse = WarehouseManager()
          .warehouses
          .where((element) => element.isActive!)
          .map((e) => e.name!)
          .toList();
    } else {
      allWarehouse =
          WarehouseManager().getListWarehouseNameHavePermissionImport();
    }

    return allWarehouse;
  }

  List<String> getListItemNameOfWarehouse() {
    Warehouse? chooseWarehouse = WarehouseManager().getWarehouseById(warehouse);
    if (chooseWarehouse == null) {
      warehouse = UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE;
    }
    if (warehouse == UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE) {
      return [];
    }
    return chooseWarehouse!.items!.keys
        .where((key) => listItem.where((element) => element.id == key).isEmpty)
        .where((key) => tempList.where((element) => element.id == key).isEmpty)
        .map((e) => ItemManager().getItemNameByID(e)!)
        .toList();
  }

  List<String> filter() {
    return getListItemNameOfWarehouse()
        .where((element) =>
            element.toLowerCase().contains(addMulltipleSearch!.toLowerCase()))
        .toList();
  }

  void setWarehouse(String newWarehouse) {
    if (newWarehouse ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE)) {
      warehouse = UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE;
    } else {
      String newWarehouseId = WarehouseManager().getIdByName(newWarehouse);
      if (newWarehouseId == '' || warehouse == newWarehouseId) return;
      warehouse = newWarehouseId;
    }
    listItem = [];
    updateIndex();
    notifyListeners();
  }

  void setChecker() {
    checker = UserManager.user!.email;
    checkTime = DateTime.now();
    notifyListeners();
  }

  void chooseItemToList(String newItem) {
    if (item == newItem) return;
    item = newItem;
    String? itemId = ItemManager().getIdByName(newItem);
    if (itemId != null &&
        listItem.where((element) => element.id == itemId).isEmpty) {
      listItem.add(ItemInventory.byId(itemId));
      inputActualInventory
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      inputNotes.add(TextEditingController(text: ''));
      updateIndex();
    }
    notifyListeners();
  }

  void chooseItemToTempList(String newItem) {
    if (item == newItem) return;
    item = newItem;
    String? itemId = ItemManager().getIdByName(newItem);
    if (itemId != null &&
        tempList.where((element) => element.id == itemId).isEmpty) {
      tempList.add(ItemInventory.byId(itemId));
    }
    notifyListeners();
  }

  void restItemInput() {
    item = UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE_ITEM);
    notifyListeners();
  }

  // void changeCheckBoxValue(Map<String, bool> map, String key, bool newValue) {
  //   map[key] = newValue;
  //   switch (key) {
  //     case 'all':
  //       map['category'] = newValue;
  //       map['type'] = newValue;
  //       for (var type in listType.keys) {
  //         listType[type] = newValue;
  //       }
  //       // for (var category in listCategory.keys) {
  //       //   listCategory[category] = newValue;
  //       // }

  //       if (newValue) {
  //         tempList.addAll(getListItemNameOfWarehouse()
  //             .map((name) => ItemInventory(
  //                 id: ItemManager().getIdByName(name),
  //                 actualAmount: 0,
  //                 amount: 0))
  //             .toList());
  //       } else {
  //         tempList.clear();
  //       }
  //       break;
  //     case 'type':
  //       for (var type in listType.keys) {
  //         listType[type] = newValue;
  //       }

  //       if (newValue) {
  //         List<ItemInventory> items = getListItemNameOfWarehouse()
  //             .map((name) => ItemManager().getItemByName(name))
  //             .toList()
  //             .where((item) => item!.type != null)
  //             .map((e) => ItemInventory.byId(e!.id))
  //             .toList();
  //         tempList.addAll(items);
  //       } else {
  //         tempList.removeWhere((itemInventory) =>
  //             ItemManager().getItemById(itemInventory.id!)!.type != null);
  //       }
  //       break;
  //     case 'category':
  //       // for (var category in listCategory.keys) {
  //       //   listCategory[category] = newValue;
  //       // }

  //       if (newValue) {
  //         List<ItemInventory> items = getListItemNameOfWarehouse()
  //             .map((name) => ItemManager().getItemByName(name))
  //             .toList()
  //             // .where((item) => item.category != null)
  //             .map((e) => ItemInventory.byId(e!.id))
  //             .toList();
  //         tempList.addAll(items);
  //       } else {
  //         tempList.removeWhere((itemInventory) =>
  //             ItemManager().getItemById(itemInventory.id).category != null);
  //       }
  //       break;
  //     default:
  //       if (map == listCategory) {
  //         if (newValue) {
  //           tempList.addAll(getListItemNameOfWarehouse()
  //               .map((name) => ItemManager().getItemByName(name))
  //               .toList()
  //               .where((element) => element.category == key)
  //               .map((e) => ItemInventory.byId(e.id))
  //               .toList());
  //         } else {
  //           tempList.removeWhere((itemInventory) =>
  //               ItemManager().getItemById(itemInventory.id).category == key);
  //         }
  //         if (listCategory.entries.where((element) => element.value).length ==
  //             listCategory.length) {
  //           categoryAndType['category'] = true;
  //         } else {
  //           categoryAndType['category'] = false;
  //         }
  //       }
  //       if (map == listType) {
  //         if (newValue) {
  //           tempList.addAll(getListItemNameOfWarehouse()
  //               .map((name) => ItemManager().getItemByName(name))
  //               .toList()
  //               .where((element) => element.type == key)
  //               .map((e) => ItemInventory.byId(e.id))
  //               .toList());
  //         } else {
  //           tempList.removeWhere((itemInventory) =>
  //               ItemManager().getItemById(itemInventory.id).type == key);
  //         }
  //         if (listType.entries.where((element) => element.value).length ==
  //             listType.length) {
  //           categoryAndType['type'] = true;
  //         } else {
  //           categoryAndType['type'] = false;
  //         }
  //       }
  //   }

  //   notifyListeners();
  // }

  void changeStatus(String newStatus) {
    status = newStatus;
    switch (newStatus) {
      case InventorySatus.CREATELIST:
        progressWidth = 0;
        break;
      case InventorySatus.CHECKING:
        progressWidth = 150;
        break;
      case InventorySatus.CHECKED:
        progressWidth = 300;
        break;
      case InventorySatus.BALANCED:
        progressWidth = 450;
        break;
    }
    notifyListeners();
  }

  void removeItem(ItemInventory item, List<ItemInventory> list) {
    if (list == listItem) {
      inputActualInventory.removeAt(listItem.indexOf(item));
      inputNotes.removeAt(listItem.indexOf(item));
    }
    list.remove(item);
    updateIndex();
    notifyListeners();
  }

  void addTempListToList() {
    listItem.addAll(tempList);
    for (var i = 0; i < tempList.length; i++) {
      inputActualInventory
          .add(NeutronInputNumberController(TextEditingController(text: '')));
      inputNotes.add(TextEditingController(text: ''));
    }
    updateIndex();
    notifyListeners();
  }

  void updateIndex() {
    startIndex = pageIndex! * pageSize!;
    endIndex = startIndex! + pageSize! > listItem.length
        ? listItem.length
        : pageIndex! * pageSize! + pageSize!;
  }

  void nextPage() {
    if (listItem.length > (pageIndex! * pageSize! + pageSize!)) {
      pageIndex = pageIndex! + 1;
      updateIndex();
      notifyListeners();
      return;
    }
  }

  void previousPage() {
    if (pageIndex == 0) return;
    pageIndex = pageIndex! - 1;
    if (pageIndex! < 0) pageIndex = 0;
    updateIndex();
    notifyListeners();
  }

  void initChooseMultiple() {
    tempList.clear();
    item = UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE_ITEM);
    for (var key in categoryAndType.keys) {
      categoryAndType[key] = false;
    }
    addMulltipleSearch = '';
  }

  void search(String value) {
    addMulltipleSearch = value;
    notifyListeners();
  }

  String completeChecking() {
    for (var actualInventory in inputActualInventory) {
      if (actualInventory.controller.text == '') {
        return MessageCodeUtil.INVENTORY_CONFIRM_COMPLETE_CHECKING;
      }
    }
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  void removeFromCheckList() {
    for (var i = 0; i < listItem.length; i++) {
      if (inputActualInventory[i].controller.text == '') {
        listItem.removeAt(i);
        inputActualInventory.removeAt(i);
        inputNotes.removeAt(i);
        i--;
      }
    }
    updateIndex();
  }

  void enterActualInventory(String value, int index) {
    inputActualInventory[index].controller.text = value;
    inputActualInventory[index].controller.selection =
        TextSelection.collapsed(offset: value.length);
    listItem[index].actualAmount = double.parse(value);
    notifyListeners();
  }

  void enterItemNote(String value, int index) {
    inputNotes[index].text = value;
    inputNotes[index].selection = TextSelection.collapsed(offset: value.length);
    listItem[index].note = value;
    notifyListeners();
  }

  Future<String> updateNote(bool isCreateNote) async {
    String result;
    Map<String, dynamic> dataList = {};
    result = convertListToJson(dataList, isCreateNote);
    if (result != '') {
      return result;
    }
    if (invoiceNumber!.text.trim().isEmpty) {
      return MessageCodeUtil.INVOICE_NUMBER_CAN_NOT_BE_EMPTY;
    }
    if (oldInventoryCheck == null) {
      createTime = DateTime.now();
      String newId = NumberUtil.getRandomID();
      result = await warehouseNotesManager.createNote(
          newId,
          createTime!,
          invoiceNumber!.text,
          WarehouseNotesType.inventoryCheck,
          dataList,
          {
            'note': note!.text,
            'status': InventorySatus.CHECKING,
            'warehouse': warehouse
          },
          null);
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNote newWarehouseNote = WarehouseNoteCheck(
            id: newId,
            createdTime: createTime,
            invoiceNumber: invoiceNumber!.text,
            note: note!.text,
            status: InventorySatus.CHECKING,
            warehouse: warehouse,
            creator: UserManager.user!.email,
            list: listItem);
        warehouseNotesManager.data.add(newWarehouseNote);
        warehouseNotesManager.data
            .sort(((a, b) => b.createdTime!.compareTo(a.createdTime!)));
        oldInventoryCheck = newWarehouseNote as WarehouseNoteCheck;
        warehouseNotesManager.updateIndex();
        warehouseNotesManager.notifyListeners();
      }
    } else {
      if (status == InventorySatus.CREATELIST &&
          listEquals<ItemInventory>(listItem, oldInventoryCheck!.list) &&
          oldInventoryCheck!.invoiceNumber == invoiceNumber!.text) {
        isInProgress = false;
        notifyListeners();
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      result = await warehouseNotesManager.updateNote(
        oldInventoryCheck!,
        createTime!,
        invoiceNumber!.text.trim(),
        WarehouseNotesType.inventoryCheck,
        dataList,
        {
          'note': note!.text,
          'status': status == InventorySatus.CREATELIST
              ? InventorySatus.CHECKING
              : InventorySatus.BALANCED,
          'warehouse': warehouse,
          'isCreateNote': isCreateNote
        },
      );
      if (result == MessageCodeUtil.SUCCESS) {
        WarehouseNoteCheck note = (warehouseNotesManager.data.firstWhere(
                (element) =>
                    element.invoiceNumber == invoiceNumber!.text.trim())
            as WarehouseNoteCheck);
        note.status = status == InventorySatus.CREATELIST
            ? InventorySatus.CHECKING
            : InventorySatus.BALANCED;
        note.list = listItem;
        note.checker = UserManager.user!.email;
        warehouseNotesManager.notifyListeners();
      }
    }

    return result;
  }

  String convertListToJson(Map<String, dynamic> dataList, bool isCreateNote) {
    for (var inventoryItem in listItem) {
      Map<String, dynamic> mapData = {
        if (inventoryItem.amount != null) 'amount': inventoryItem.amount,
        if (inventoryItem.actualAmount != null)
          'actual_amount': inventoryItem.actualAmount,
        if (inventoryItem.note != null) 'note': inventoryItem.note,
      };
      if (isCreateNote) {
        if (WarehouseManager()
                    .getWarehouseById(warehouse)!
                    .items![inventoryItem.id] -
                inventoryItem.actualAmount <
            0) {
          if (inventoryItem.price == null) {
            return MessageCodeUtil.INPUT_PRICE;
          }
          if (inventoryItem.supplierId == null) {
            return MessageCodeUtil.TEXTALERT_SUPPLIER_CAN_NOT_BE_EMPTY;
          }
          mapData['price'] = inventoryItem.price;
          mapData['supplier'] = inventoryItem.supplierId;
        }
      }
      dataList[inventoryItem.id!] = mapData;
    }
    return MessageCodeUtil.SUCCESS;
  }

  bool checkDifference() {
    warehouseActions.clear();
    bool import = false;
    bool export = false;
    for (var item in listItem) {
      item.amount =
          WarehouseManager().getWarehouseById(warehouse)!.items![item.id];
      double difference = item.actualAmount! - (item.amount ?? 0);
      if (difference > 0) {
        import = true;
      }
      if (difference < 0) {
        export = true;
      }
    }

    if (import) {
      warehouseActions[warehouse] = WarehouseActionType.IMPORT;
    }
    if (export) {
      if (import) {
        warehouseActions[warehouse] = WarehouseActionType.BOTH;
      } else {
        warehouseActions[warehouse] = WarehouseActionType.EXPORT;
      }
    }

    if (import || export) {
      return true;
    }
    return false;
  }

  List<ItemInventory> getListImport() {
    List<ItemInventory> result = listItem
        .where((element) =>
            WarehouseManager().getWarehouseById(warehouse)!.items![element.id] -
                element.actualAmount <
            0)
        .toList();
    return result;
  }

  void chooseSupplierForImport(String supplierName, ItemInventory item) {
    if (supplierName == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
      item.supplierId = null;
    }
    String? supplierId = SupplierManager().getSupplierIDByName(supplierName);
    if (supplierId != null) {
      item.supplierId = supplierId;
    }
    notifyListeners();
  }

  void setPrice(String value, ItemInventory e) {
    e.price = double.tryParse(value);
    notifyListeners();
  }

  void initImportDialog() {
    List<ItemInventory> list = getListImport();
    inputPrice.clear();
    // ignore: unused_local_variable
    for (var element in list) {
      inputPrice
          .add(NeutronInputNumberController(TextEditingController(text: '')));
    }
  }

  List<ItemInventory> getSubList() {
    return listItem.sublist(startIndex!, endIndex).toList();
  }
}
