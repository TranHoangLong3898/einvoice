import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants.dart';
import '../../util/uimultilanguageutil.dart';

class ActualPayment {
  String? id;
  double? amount;
  String? accountingId;
  DateTime? created;
  String? desc;
  String? _email;
  String? hotelId;
  String? method;
  String? status;
  String? supplier;
  String? type;

  ActualPayment(
      {this.id,
      this.amount,
      this.accountingId,
      this.created,
      String? email,
      this.hotelId,
      this.method,
      this.status,
      this.desc,
      this.supplier,
      this.type}) {
    _email = email;
  }

  ActualPayment.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    amount = doc.get('amount').toDouble();
    accountingId = doc.get('cost_management_id');
    created = doc.get('created').toDate();
    _email = doc.get('email');
    hotelId = doc.get('hotel_id');
    method = doc.get('method');
    status = doc.get('status');
    desc = doc.get('desc');
    supplier = doc.get('supplier');
    type = doc.get('type');
  }

  String? get author => _email == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : _email;
}
