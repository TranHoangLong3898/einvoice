import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/itemmanager.dart';
import '../../../manager/warehousemanager.dart';
import '../../../util/numberutil.dart';
import '../warehousenote.dart';
import 'itemliquidation.dart';

class WarehouseNoteLiquidation extends WarehouseNote {
  List<ItemLiquidation>? list = [];
  WarehouseNoteLiquidation(
      {String? id,
      String? creator,
      String? invoiceNumber,
      DateTime? createdTime,
      DateTime? actualCreated,
      this.list})
      : super(
            id: id,
            creator: creator,
            invoiceNumber: invoiceNumber,
            createdTime: createdTime,
            type: WarehouseNotesType.liquidation,
            actualCreated: actualCreated);

  factory WarehouseNoteLiquidation.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemLiquidation> listItem = [];
    if (listMap.isNotEmpty) {
      listMap.forEach((idItem, arrayData) {
        for (dynamic objData in (arrayData as List<dynamic>)) {
          listItem.add(ItemLiquidation(
              id: idItem,
              amount: objData['amount'].toDouble(),
              price: objData['price'].toDouble(),
              warehouse: objData['warehouse']));
        }
      });
    }
    return WarehouseNoteLiquidation(
        id: doc.id,
        list: listItem,
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteLiquidation.fromDynamicData(
      String id,
      DateTime createdTime,
      DateTime actualCreated,
      String invoiceNumber,
      String creator,
      String type,
      Map<String, dynamic> dataList) {
    List<ItemLiquidation> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        double priceItem = dataList[idItem]['price'];
        Map<String, dynamic> warehouseMap =
            dataList[idItem]['warehouses'] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, amount) {
          listItem.add(ItemLiquidation(
              id: idItem,
              amount: amount as double,
              price: priceItem,
              warehouse: warehouseId));
        });
      }
    }
    return WarehouseNoteLiquidation(
        id: id,
        list: listItem,
        createdTime: createdTime,
        invoiceNumber: invoiceNumber,
        creator: creator,
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
    WarehouseNoteLiquidation? warehouseNoteData;
    List<ItemLiquidation> list = [];
    List<int> listErrorRow = [];
    for (var i = 3; i < noteData.rows.length; i++) {
      String? itemId, warehousId;
      double? amount, price;
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
              price = double.tryParse(rowData[j]!.value.toString().trim());
              rowValues.add(price);

              if (price == null) {
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
        ItemLiquidation existingItem = list.firstWhere(
          (element) =>
              element.id == itemId &&
              element.warehouse == warehousId &&
              element.price == price,
          orElse: () => ItemLiquidation(
              id: itemId, amount: amount, price: price, warehouse: warehousId),
        );
        if (list.contains(existingItem)) {
          existingItem.amount = existingItem.amount! + amount!;
        } else {
          list.add(existingItem);
        }
        warehouseNoteData = WarehouseNoteLiquidation(
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
