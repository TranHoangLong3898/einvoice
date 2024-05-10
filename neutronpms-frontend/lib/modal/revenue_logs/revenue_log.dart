import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class TypeRevenueLog {
  static const typeAdd = 1;
  static const typeMinus = 2;
  static const typeTransfer = 3;
  static const typeActualPayment = 4;
}

class RevenueLog {
  String? id;
  double amount;
  String? _author;
  DateTime? created;
  String? desc;
  num? type;
  String method;
  String? methodTo;
  Map<String, dynamic>? oldTotal;

  RevenueLog(
      {this.id,
      required this.amount,
      String? author,
      this.created,
      this.desc,
      this.type,
      this.oldTotal,
      required this.method,
      this.methodTo}) {
    _author = author;
  }

  factory RevenueLog.fromDocumentData(QueryDocumentSnapshot doc) {
    if (doc.get('type') == TypeRevenueLog.typeActualPayment) {
      String desc = doc.get('desc');
      List<String> arrDesc = desc.split(specificCharacter);
      desc =
          '${MessageUtil.getMessageByCode(arrDesc[0])} ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE_ACCOUNTING)} ${AccountingTypeManager.getNameById(arrDesc[1])} ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER)} ${SupplierManager().getSupplierNameByID(arrDesc[2])}';
      return RevenueLog(
          id: doc.id,
          amount: doc.get('amount').toDouble(),
          created: (doc.get('created') as Timestamp).toDate(),
          desc: desc,
          type: doc.get('type'),
          author: doc.get('email'),
          oldTotal: doc.get('data'),
          method: doc.get('method'));
    }

    if (doc.get('type') == TypeRevenueLog.typeTransfer) {
      return RevenueLog(
          id: doc.id,
          amount: doc.get('amount').toDouble(),
          created: (doc.get('created') as Timestamp).toDate(),
          desc: doc.get('desc'),
          type: doc.get('type'),
          author: doc.get('email'),
          oldTotal: doc.get('data'),
          method: doc.get('method_from'),
          methodTo: doc.get('method_to'));
    }

    return RevenueLog(
        id: doc.id,
        amount: doc.get('amount').toDouble(),
        created: (doc.get('created') as Timestamp).toDate(),
        desc: doc.get('desc'),
        type: doc.get('type'),
        author: doc.get('email'),
        oldTotal: doc.get('data'),
        method: doc.get('method'));
  }

  String? get author => _author == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : _author;

  String getTypeName() {
    switch (type) {
      case TypeRevenueLog.typeAdd:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_ADD);
      case TypeRevenueLog.typeMinus:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_MINUS);
      case TypeRevenueLog.typeTransfer:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_TRANSFER);
      case TypeRevenueLog.typeActualPayment:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_ACTUAL_PAYMENT);
      default:
        return UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TYPE_REVENUE_NONE);
    }
  }
}
