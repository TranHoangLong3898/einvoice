import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import '../../../manager/itemmanager.dart';
import '../../../manager/warehousemanager.dart';
import '../../../util/numberutil.dart';
import '../warehousenote.dart';
import 'itemexport.dart';

class WarehouseNoteExport extends WarehouseNote {
  WarehouseNoteExport({
    String? id,
    String? creator,
    String? type,
    DateTime? createdTime,
    String? invoiceNumber,
    DateTime? actualCreated,
    this.list,
  }) : super(
            id: id,
            creator: creator,
            createdTime: createdTime,
            invoiceNumber: invoiceNumber,
            type: type,
            actualCreated: actualCreated);

  List<ItemExport>? list = [];

  factory WarehouseNoteExport.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemExport> listItem = [];
    if (listMap.isNotEmpty) {
      for (String idItem in listMap.keys) {
        Map<String, dynamic> warehouseMap =
            listMap[idItem] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, amount) {
          listItem.add(ItemExport(
              id: idItem, amount: amount.toDouble(), warehouse: warehouseId));
        });
      }
    }
    return WarehouseNoteExport(
        id: doc.id,
        list: listItem,
        type: doc['type'],
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteExport.fromDynamicData(
      String id,
      DateTime createdTime,
      DateTime actualCreated,
      String invoiceNumber,
      String creator,
      String type,
      Map<String, dynamic> dataList) {
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
    return WarehouseNoteExport(
        id: id,
        list: listItem,
        createdTime: createdTime,
        creator: creator,
        invoiceNumber: invoiceNumber,
        actualCreated: actualCreated);
  }

  static Map<String, dynamic> fromExcelFile(Sheet noteData) {
    WarehouseNoteExport? warehouseNoteData;
    Map<String, dynamic> result = {};
    List<int> listErrorRow = [];
    List<ItemExport> list = [];

    for (var i = 3; i < noteData.rows.length; i++) {
      List<Data?> rowData = noteData.rows[i];
      String? itemId, warehousId;
      double? amount;
      List<dynamic>? rowValues = [];
      bool isError = false;

      for (var j = 0; j < 3; j++) {
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
      if (rowValues.where((element) => element != null).length == 3) {
        ItemExport existingItem = list.firstWhere(
          (element) => element.id == itemId && element.warehouse == warehousId,
          orElse: () =>
              ItemExport(id: itemId, amount: amount, warehouse: warehousId),
        );
        if (list.contains(existingItem)) {
          existingItem.amount = existingItem.amount! + amount!;
        } else {
          list.add(existingItem);
        }
      }
      warehouseNoteData = WarehouseNoteExport(
          list: list,
          invoiceNumber: NumberUtil.getRandomString(8),
          id: NumberUtil.getRandomID(),
          createdTime: DateTime.now());
    }

    result['errors'] = listErrorRow;
    result['noteData'] = warehouseNoteData;

    return result;
  }
}
