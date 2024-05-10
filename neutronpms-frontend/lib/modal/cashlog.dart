import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../manager/generalmanager.dart';

class CashLog {
  final DateTime? created;
  final String? desc;
  final num? amount;
  final List<String>? status;
  CashLog({this.created, this.desc, this.amount, this.status});

  factory CashLog.fromSnapshot(DocumentSnapshot doc) => CashLog(
        amount: doc.get('amount'),
        desc: doc.get('desc'),
        created: doc.get('created').toDate(),
        status: doc.get('status'),
      );

  Future<String> updateStatus(String status, String idCashLog) async {
    String result = await FirebaseFunctions.instance
        .httpsCallable('deposit-updateStatusPayment')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cashlog_id': idCashLog,
          'status': status
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    return result;
  }
}
