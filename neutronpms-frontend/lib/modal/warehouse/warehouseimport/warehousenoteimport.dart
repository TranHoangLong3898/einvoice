import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/warehousemanager.dart';
import '../../../util/numberutil.dart';
import '../warehousenote.dart';
import 'itemimport.dart';

class WarehouseNoteImport extends WarehouseNote {
  List<ItemImport>? list = [];
  String? returnInvoiceNum;
  double? totalCost;
  WarehouseNoteImport(
      {String? id,
      String? creator,
      String? invoiceNumber,
      DateTime? createdTime,
      DateTime? actualCreated,
      String? type,
      this.returnInvoiceNum,
      this.totalCost,
      this.list})
      : super(
            id: id,
            creator: creator,
            invoiceNumber: invoiceNumber,
            createdTime: createdTime,
            type: type,
            actualCreated: actualCreated);

  factory WarehouseNoteImport.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemImport> listItem = [];
    if (listMap.isNotEmpty) {
      listMap.forEach((idItem, arrayData) {
        for (dynamic objData in (arrayData as List<dynamic>)) {
          ItemImport itemImport = ItemImport(
              id: idItem,
              amount: objData['amount'].toDouble(),
              warehouse: objData['warehouse']);
          if (data['type'] == WarehouseNotesType.import) {
            itemImport.price = objData['price'].toDouble();
            itemImport.supplier = objData['supplier'];
          }
          listItem.add(itemImport);
        }
      });
    }
    return WarehouseNoteImport(
        id: doc.id,
        list: listItem,
        type: data['type'],
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        returnInvoiceNum: data['return_invoice_number'] ?? '',
        totalCost: data['total_cost'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteImport.fromDynamicData(
      String id,
      DateTime createdTime,
      DateTime actualCreated,
      String invoiceNumber,
      String creator,
      String type,
      String returnInvoiceNum,
      double totalCost,
      Map<String, dynamic> dataList) {
    List<ItemImport> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        double priceItem = dataList[idItem]['price'];
        String supplierItem = dataList[idItem]['supplier'];
        Map<String, dynamic> warehouseMap =
            dataList[idItem]['warehouses'] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, amount) {
          listItem.add(ItemImport(
              id: idItem,
              amount: amount as double,
              price: priceItem,
              supplier: supplierItem,
              warehouse: warehouseId));
        });
      }
    }
    return WarehouseNoteImport(
        id: id,
        list: listItem,
        createdTime: createdTime,
        invoiceNumber: invoiceNumber,
        creator: creator,
        returnInvoiceNum: returnInvoiceNum,
        totalCost: totalCost,
        actualCreated: actualCreated);
  }

  num getTotal() {
    return list!.fold(
        0,
        (previousValue, element) =>
            previousValue + element.amount! * element.price!);
  }

  static Map<String, dynamic> fromExcelFile(Sheet noteData) {
    Map<String, dynamic> result = {};
    WarehouseNoteImport? warehouseNoteData;
    List<ItemImport> list = [];
    List<int> listErrorRow = [];

    for (var i = 3; i < noteData.rows.length; i++) {
      List<Data?> rowData = noteData.rows[i];
      String? itemId, warehousId, supplierId;
      double? amount, price;
      List<dynamic>? rowValues = [];
      bool isError = false;

      for (var j = 0; j < 5; j++) {
        if (isError) continue;
        if (rowData[j] == null || rowData[j]!.value.toString().trim() == '') {
          if (j > 0 && rowValues[j - 1] != null) {
            listErrorRow.add(i);
            isError = true;
          }
          rowValues.add(null);
        } else if (j > 0 && rowValues[j - 1] == null) {
          listErrorRow.add(i);
          isError = true;
          rowValues.add(null);
        } else {
          switch (j) {
            case 0:
              itemId = ItemManager()
                  .getIdByName(rowData[j]!.value.toString().trim());
              rowValues.add(itemId);
              if (itemId == null) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 1:
              warehousId = WarehouseManager()
                  .getIdByName(rowData[j]!.value.toString().trim());

              rowValues.add(warehousId);
              if (warehousId == '' ||
                  !WarehouseManager()
                      .getActiveWarehouseName()
                      .contains(rowData[j]!.value.toString().trim())) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 2:
              supplierId = SupplierManager()
                  .getSupplierIDByName(rowData[j]!.value.toString().trim());
              rowValues.add(supplierId);
              if (supplierId == '' ||
                  !SupplierManager()
                      .getActiveSupplierNames()
                      .contains(rowData[j]!.value.toString().trim())) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 3:
              price = double.tryParse(rowData[j]!.value.toString().trim());
              rowValues.add(price);
              if (price == null) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 4:
              amount = double.tryParse(rowData[j]!.value.toString().trim());
              rowValues.add(amount);
              if (amount == null) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
          }
        }
      }
      if (rowValues.where((element) => element != null).length == 5) {
        ItemImport existingItem = list.firstWhere(
          (element) =>
              element.id == itemId &&
              element.warehouse == warehousId &&
              element.supplier == supplierId,
          orElse: () => ItemImport(
              id: itemId,
              warehouse: warehousId,
              supplier: supplierId,
              amount: amount,
              price: price),
        );
        if (list.contains(existingItem)) {
          existingItem.amount = existingItem.amount! + amount!;
        } else {
          list.add(existingItem);
        }

        warehouseNoteData = WarehouseNoteImport(
            list: list,
            invoiceNumber: NumberUtil.getRandomString(8),
            id: NumberUtil.getRandomID(),
            createdTime: DateTime.now());
      }
    }
    result['errors'] = listErrorRow;
    result['noteData'] = warehouseNoteData;
    return result;
  }
}
