import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../warehousenote.dart';
import 'itemreturn.dart';

class WarehouseNoteReturn extends WarehouseNote {
  WarehouseNoteReturn({
    String? id,
    String? creator,
    DateTime? createdTime,
    DateTime? actualCreated,
    String? invoiceNumber,
    this.importInvoiceNumber,
    this.list,
  }) : super(
            id: id,
            creator: creator,
            createdTime: createdTime,
            invoiceNumber: invoiceNumber,
            type: WarehouseNotesType.returnToSupplier,
            actualCreated: actualCreated);

  List<ItemReturn>? list = [];
  String? importInvoiceNumber;

  factory WarehouseNoteReturn.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemReturn> listItem = [];
    if (listMap.isNotEmpty) {
      listMap.forEach((idItem, arrayData) {
        for (dynamic objData in (arrayData as List<dynamic>)) {
          listItem.add(ItemReturn(
              id: idItem,
              amount: objData['amount'].toDouble(),
              price: objData['price'].toDouble(),
              warehouse: objData['warehouse']));
        }
      });
    }
    return WarehouseNoteReturn(
        id: doc.id,
        list: listItem,
        createdTime: (data['created_time'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        importInvoiceNumber: data['import_invoice_number'],
        actualCreated: data.containsKey('actual_created')
            ? (data['actual_created'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteReturn.fromDynamicData(
      String id,
      DateTime createdTime,
      DateTime actualCreated,
      String invoiceNumber,
      String importInvoiceNumber,
      String creator,
      String type,
      Map<String, dynamic> dataList) {
    List<ItemReturn> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        Map<String, dynamic> warehouseMap =
            dataList[idItem] as Map<String, dynamic>;
        warehouseMap.forEach((warehouseId, amount) {
          listItem.add(ItemReturn(
              id: idItem, amount: amount as double, warehouse: warehouseId));
        });
      }
    }
    return WarehouseNoteReturn(
        id: id,
        list: listItem,
        createdTime: createdTime,
        creator: creator,
        invoiceNumber: invoiceNumber,
        importInvoiceNumber: importInvoiceNumber,
        actualCreated: actualCreated);
  }
}
