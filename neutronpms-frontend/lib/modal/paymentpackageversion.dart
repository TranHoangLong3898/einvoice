import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPackageVersion {
  String? id;
  String? tradingCode;
  String? method;
  String? desc;
  String? nameBank;
  String? creater;
  String? package;
  String? status;
  num? amount;
  num? stillInDebt;
  DateTime? created;
  DateTime? expiredDate;

  PaymentPackageVersion(
      {this.id,
      this.tradingCode,
      this.method,
      this.desc,
      this.nameBank,
      this.creater,
      this.package,
      this.status,
      this.amount,
      this.stillInDebt,
      this.created,
      this.expiredDate});

  factory PaymentPackageVersion.fromJson(DocumentSnapshot doc) {
    return PaymentPackageVersion(
      id: doc.id,
      desc: doc.get("desc"),
      created: doc.get("created").toDate(),
      creater: doc.get("creater"),
      expiredDate: doc.get("expired_date").toDate(),
      method: doc.get("method"),
      nameBank: doc.get("nameBank"),
      tradingCode: doc.get("code_bank"),
      amount: doc.get("amount"),
      stillInDebt: doc.get("stillIn_debt"),
      package: doc.get("package"),
      status: doc.get("status"),
    );
  }
}
