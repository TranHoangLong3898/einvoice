import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../warehousenote.dart';
import 'inventorycheck.dart';

class WarehouseNoteCheck extends WarehouseNote {
  WarehouseNoteCheck(
      {String? id,
      String? creator,
      DateTime? createdTime,
      DateTime? actualCreated,
      String? invoiceNumber,
      this.note,
      this.checkTime,
      this.warehouse,
      this.status,
      this.list,
      this.checker})
      : super(
            id: id,
            creator: creator,
            createdTime: createdTime,
            invoiceNumber: invoiceNumber,
            type: WarehouseNotesType.inventoryCheck,
            actualCreated: actualCreated);

  List<ItemInventory>? list = [];
  String? warehouse;
  String? checker;
  String? status;
  String? note;
  DateTime? checkTime;

  factory WarehouseNoteCheck.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> listMap = data['list'] as Map<String, dynamic>;
    List<ItemInventory> listItem = [];
    if (listMap.isNotEmpty) {
      listMap.forEach((idItem, mapData) {
        listItem.add(ItemInventory(
          id: idItem,
          amount: mapData['amount']?.toDouble(),
          note: mapData['note'],
          actualAmount: mapData['actual_amount']?.toDouble(),
        ));
      });
    }
    return WarehouseNoteCheck(
        id: doc.id,
        list: listItem,
        createdTime: (data['created_time'] as Timestamp).toDate(),
        actualCreated: (data['actual_created'] as Timestamp).toDate(),
        creator: data['creator'],
        invoiceNumber: data['invoice'],
        warehouse: data['warehouse'],
        status: data['status'],
        note: data['note'],
        checker: data['checker'],
        checkTime: data.containsKey('check_time')
            ? (data['check_time'] as Timestamp).toDate()
            : null);
  }

  factory WarehouseNoteCheck.fromDynamicData(
      String id,
      DateTime createdTime,
      DateTime checkTime,
      String invoiceNumber,
      String warehouse,
      String creator,
      String status,
      String type,
      String inventoryChecker,
      String note,
      Map<String, dynamic> dataList) {
    List<ItemInventory> listItem = [];
    if (dataList.isNotEmpty) {
      for (String idItem in dataList.keys) {
        Map<String, dynamic> warehouseMap =
            dataList[idItem] as Map<String, dynamic>;
        listItem.add(ItemInventory(
            id: idItem,
            amount: warehouseMap['amount'] as double,
            note: warehouseMap['note'],
            actualAmount: warehouseMap['actual_amount'] as double));
      }
    }
    return WarehouseNoteCheck(
        id: id,
        list: listItem,
        createdTime: createdTime,
        creator: creator,
        invoiceNumber: invoiceNumber,
        warehouse: warehouse,
        status: status,
        note: note,
        checker: inventoryChecker,
        checkTime: checkTime);
  }
}
