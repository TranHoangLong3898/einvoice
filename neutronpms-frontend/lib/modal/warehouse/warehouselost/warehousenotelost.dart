import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/itemmanager.dart';
import '../../../manager/warehousemanager.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../warehouselost/itemlost.dart';
import '../warehousenote.dart';

class WarehouseNoteLost extends WarehouseNote {
  WarehouseNoteLost({
    String? id,
    String? creator,
    DateTime? createdTime,
    String? invoiceNumber,
    DateTime? actualCreated,
    this.list,
  }) : super(
            id: id,
            creator: creator,
            createdTime: createdTime,
            invoiceNumber: invoiceNumber,
            type: WarehouseNotesType.lost,
            actualCreated: actualCreated);

  List<ItemLost>? list = [];

  factory WarehouseNoteLost.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemLost> listItem = [];
    if (listMap.isNotEmpty) {
      for (String idItem in listMap.keys) {
        (listMap[idItem] as Map<String, dynamic>).forEach((warehouseId, value) {
          (value as Map<String, dynamic>).forEach((status, amount) {
            listItem.add(ItemLost(
              id: idItem,
              amount: amount,
              status: status,
              warehouse: warehouseId,
            ));
          });
        });
      }
    }
    return WarehouseNoteLost(
        id: doc.id,
        list: listItem,
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteLost.fromDynamicData(
    String id,
    DateTime createdTime,
    DateTime actualCreated,
    String invoiceNumber,
    String creator,
    String type,
    Map<String, dynamic> dataList,
  ) {
    List<ItemLost> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        Map<String, dynamic> warehouseMap =
            dataList[idItem] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, value) {
          listItem.add(ItemLost(
            id: idItem,
            amount: value['amount'].toDouble(),
            status: value['status'],
            warehouse: warehouseId,
          ));
        });
      }
    }
    return WarehouseNoteLost(
        id: id,
        list: listItem,
        createdTime: createdTime,
        creator: creator,
        invoiceNumber: invoiceNumber,
        actualCreated: actualCreated);
  }

  static Map<String, dynamic> fromExcelFile(Sheet noteData) {
    Map<String, dynamic> result = {};
    WarehouseNoteLost? warehouseNoteData;
    List<ItemLost> list = [];
    List<int> listErrorRow = [];
    List<String> listStatus = [
      MessageCodeUtil.LOST,
      MessageCodeUtil.BROKEN,
      MessageCodeUtil.EXPIRED
    ];
    for (var i = 3; i < noteData.rows.length; i++) {
      String? itemId, warehousId, status;
      double? amount;
      List<Data?> rowData = noteData.rows[i];
      List<dynamic>? rowValues = [];
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
              status = rowData[j]!.value.toString().trim();
              if (!listStatus.contains(status)) {
                listErrorRow.add(i);
                isError = true;
                rowValues.add(null);
              } else {
                rowValues.add(status);
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
        ItemLost existingItem = list.firstWhere(
          (element) =>
              element.id == itemId &&
              element.warehouse == warehousId &&
              element.status == status,
          orElse: () => ItemLost(
              id: itemId,
              warehouse: warehousId,
              status: status,
              amount: amount),
        );
        if (list.contains(existingItem)) {
          existingItem.amount = existingItem.amount! + amount!;
        } else {
          list.add(existingItem);
        }
        warehouseNoteData = WarehouseNoteLost(
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
