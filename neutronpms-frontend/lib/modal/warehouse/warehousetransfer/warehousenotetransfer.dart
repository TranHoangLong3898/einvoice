import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/itemmanager.dart';
import '../../../manager/warehousemanager.dart';
import '../../../util/numberutil.dart';
import '../warehousenote.dart';
import 'itemtransfer.dart';

class WarehouseNoteTransfer extends WarehouseNote {
  List<ItemTransfer>? list = [];
  WarehouseNoteTransfer({
    String? id,
    String? creator,
    DateTime? actualCreated,
    DateTime? createdTime,
    String? invoiceNumber,
    this.list,
  }) : super(
            id: id,
            creator: creator,
            createdTime: createdTime,
            invoiceNumber: invoiceNumber,
            type: WarehouseNotesType.transfer,
            actualCreated: actualCreated);

  factory WarehouseNoteTransfer.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemTransfer> listItem = [];
    if (listMap.isNotEmpty) {
      for (String idItem in listMap.keys) {
        (listMap[idItem] as Map<String, dynamic>)
            .forEach((fromWarehouse, valueMap) {
          (valueMap as Map<String, dynamic>).forEach((toWarehouse, amount) {
            listItem.add(ItemTransfer(
              id: idItem,
              amount: amount.toDouble(),
              fromWarehouse: fromWarehouse,
              toWarehouse: toWarehouse,
            ));
          });
        });
      }
    }
    return WarehouseNoteTransfer(
        id: doc.id,
        list: listItem,
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  static Map<String, dynamic> fromExcelFile(Sheet noteData) {
    Map<String, dynamic> result = {};
    WarehouseNoteTransfer? warehouseNoteData;
    List<ItemTransfer> list = [];
    List<int> listErrorRow = [];
    for (var i = 3; i < noteData.rows.length; i++) {
      String? itemId, fromWarehousId, toWarehouseId;
      double? amount;
      List<dynamic> rowValues = [];
      List<Data?> rowData = noteData.rows[i];
      bool isError = false;
      for (var j = 0; j < 4; j++) {
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
              fromWarehousId = WarehouseManager()
                  .getIdByName(rowData[j]!.value.toString().trim());
              rowValues.add(fromWarehousId);

              if (fromWarehousId == '' ||
                  !WarehouseManager()
                      .getActiveWarehouseName()
                      .contains(rowData[j]!.value.toString().trim())) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 2:
              toWarehouseId = WarehouseManager()
                  .getIdByName(rowData[j]!.value.toString().trim());
              rowValues.add(toWarehouseId);

              if (toWarehouseId == '') {
                listErrorRow.add(i);
                isError = true;
              }
              if (fromWarehousId == toWarehouseId) {
                listErrorRow.add(i);
                isError = true;
              }
              break;
            case 3:
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
      if (rowValues.where((element) => element != null).length == 4) {
        ItemTransfer existingItem = list.firstWhere(
          (element) =>
              element.id == itemId &&
              element.fromWarehouse == fromWarehousId &&
              element.toWarehouse == toWarehouseId,
          orElse: () => ItemTransfer(
              id: itemId,
              fromWarehouse: fromWarehousId,
              toWarehouse: toWarehouseId,
              amount: amount),
        );
        if (list.contains(existingItem)) {
          existingItem.amount = existingItem.amount! + amount!;
        } else {
          list.add(existingItem);
        }
        warehouseNoteData = WarehouseNoteTransfer(
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
