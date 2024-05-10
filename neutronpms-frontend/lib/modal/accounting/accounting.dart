import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../constants.dart';

class Accounting {
  String? id;
  double? amount;
  String? _author;
  DateTime? created;
  String? desc;
  String? status;
  String? supplier;
  String? type;
  double? actualPayment;
  int? costType;
  String? room;
  String? roomType;
  String? idBooking;
  String? sidBooking;
  String? invoiceNum;

  Accounting(
      {this.id,
      this.amount,
      String? author,
      this.created,
      this.desc,
      this.status,
      this.supplier,
      this.type,
      this.actualPayment,
      this.costType,
      this.room,
      this.roomType,
      this.invoiceNum,
      this.idBooking,
      this.sidBooking}) {
    _author = author;
  }

  Accounting.fromDocumentData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    id = doc.id;
    amount = doc.get('amount').toDouble();
    actualPayment = doc.get('actual_payment').toDouble();
    created = (doc.get('created') as Timestamp).toDate();
    desc = doc.get('desc');
    status = doc.get('status');
    supplier = doc.get('supplier');
    type = doc.get('type');
    costType = data.containsKey('cost_type') ? doc.get('cost_type') : 0;
    room = data.containsKey('room') ? doc.get('room') : "";
    roomType = data.containsKey('room_type') ? doc.get('room_type') : "";
    idBooking = data.containsKey('id') ? doc.get('id') : "";
    sidBooking = data.containsKey('sid') ? doc.get('sid') : "";
    invoiceNum = data.containsKey('invoice_num') ? doc.get('invoice_num') : "";
    _author = doc.get('author');
  }

  Accounting.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    id = doc.id;
    amount = doc.get('amount').toDouble();
    actualPayment = doc.get('actual_payment').toDouble();
    created = (doc.get('created') as Timestamp).toDate();
    desc = doc.get('desc');
    status = doc.get('status');
    supplier = doc.get('supplier');
    type = doc.get('type');
    costType = data.containsKey('cost_type') ? doc.get('cost_type') : 0;
    room = data.containsKey('room') ? doc.get('room') : "";
    roomType = data.containsKey('room_type') ? doc.get('room_type') : "";
    idBooking = data.containsKey('id') ? doc.get('id') : "";
    sidBooking = data.containsKey('sid') ? doc.get('sid') : "";
    invoiceNum = data.containsKey('invoice_num') ? doc.get('invoice_num') : "";
    _author = doc.get('author');
  }

  Accounting.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    amount = doc.get('amount').toDouble();
    actualPayment = doc.get('actual_payment').toDouble();
    created = (doc.get('created') as Timestamp).toDate();
    desc = doc.get('desc');
    status = doc.get('status');
    supplier = doc.get('supplier');
    type = doc.get('type');
    invoiceNum = (doc.data() as Map<String, dynamic>)['invoice_num'] ?? '';
    _author = doc.get('author');
  }

  String? get author => _author == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : _author;

  double get remain => (amount ?? 0) - (actualPayment ?? 0);

  Future<String> delete() async {
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-deleteCostManagement')
        .call({'hotel_id': GeneralManager.hotelID, 'cost_management_id': id})
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        });
  }
}

class AccountingType {
  String? id, name;
  late bool isActive;

  AccountingType({this.id, this.name, this.isActive = false});

  AccountingType.fromMapEntry(MapEntry entry) {
    id = entry.key;
    name = entry.value['name'];
    isActive = entry.value['active'];
  }

  String get statusName => UITitleUtil.getTitleByCode(
      isActive ? UITitleCode.STATUS_ACTIVE : UITitleCode.STATUS_DEACTIVE);
}
