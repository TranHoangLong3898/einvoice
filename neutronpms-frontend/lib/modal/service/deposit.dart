import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../manager/generalmanager.dart';
import '../../manager/sourcemanager.dart';

class Deposit {
  String? desc;
  num? amount;
  final Timestamp? created;
  String? method;
  final String? sID;
  final String? bookingID;
  final String? id;
  String? status;
  final String? name;
  final DateTime? inDate;
  final DateTime? outDate;
  final String? room;
  String? transferredBID;
  final String? transferredID;
  final String? sourceID;
  DateTime? confirmDate;
  num? actualAmount;
  String? note;
  String? referenceNumber;
  DateTime? referencDate;

  setDesc(String desc) {
    this.desc = desc;
  }

  setAmount(num amount) {
    this.amount = amount;
  }

  setMethod(String method) {
    this.method = method;
  }

  setTransferredBID(String transferredBID) {
    this.transferredBID = transferredBID;
  }

  setActualAmount(num amount) {
    actualAmount = amount;
  }

  setNote(String note) {
    this.note = note;
  }

  setReferenceNumber(String referenceNumber) {
    this.referenceNumber = referenceNumber;
  }

  setReferencDate(DateTime? referencDate) {
    this.referencDate = referencDate;
  }

  Deposit({
    this.id,
    this.bookingID,
    this.desc,
    this.amount,
    this.created,
    this.method,
    this.sID,
    this.status,
    this.name,
    this.room,
    this.inDate,
    this.outDate,
    this.transferredBID,
    this.transferredID,
    this.sourceID,
    this.confirmDate,
    this.actualAmount,
    this.referenceNumber,
    this.note,
    this.referencDate,
  });

  factory Deposit.fromSnapshot(DocumentSnapshot doc) => Deposit(
        amount: doc.get('amount'),
        desc: doc.get('desc'),
        method: doc.get('method'),
        sID: doc.get('sid'),
        created: doc.get('created'),
        id: doc.id,
        status: doc.get('status'),
        inDate: (doc.get('in') as Timestamp).toDate(),
        outDate: (doc.get('out') as Timestamp).toDate(),
        name: doc.get('name'),
        room: (doc.data() as Map<String, dynamic>).containsKey('room')
            ? doc.get('room')
            : 'group',
        sourceID: (doc.data() as Map<String, dynamic>).containsKey('source')
            ? doc.get('source')
            : SourceManager.noneSourceId,
        transferredBID:
            (doc.data() as Map<String, dynamic>).containsKey('transferred_bid')
                ? doc.get('transferred_bid')
                : null,
        transferredID:
            (doc.data() as Map<String, dynamic>).containsKey('transferred_id')
                ? doc.get('transferred_id')
                : null,
        bookingID: doc.get('bid'),
        confirmDate:
            (doc.data() as Map<String, dynamic>).containsKey('confirm_date')
                ? (doc.get('confirm_date') as Timestamp).toDate()
                : null,
        actualAmount:
            (doc.data() as Map<String, dynamic>).containsKey('actual_amount')
                ? doc.get('actual_amount')
                : 0,
        note: (doc.data() as Map<String, dynamic>).containsKey('note')
            ? doc.get('note')
            : '',
        referenceNumber:
            (doc.data() as Map<String, dynamic>).containsKey('reference_number')
                ? doc.get('reference_number')
                : '',
        referencDate:
            (doc.data() as Map<String, dynamic>).containsKey('reference_date')
                ? (doc.get('reference_date') as Timestamp).toDate()
                : null,
      );

  Future<String> updateStatus(String status) async {
    String result = await FirebaseFunctions.instance
        .httpsCallable('deposit-updateStatusPayment')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': bookingID,
          'status': status,
          'payment_id': id
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    return result;
  }

  Future<String> updatePaymentManager() async {
    String result = await FirebaseFunctions.instance
        .httpsCallable('deposit-updatePaymentManager')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': bookingID,
          'payment_id': id,
          'payment_amount': amount,
          'payment_method': method,
          'payment_desc': desc,
          'payment_actual_amount': actualAmount,
          'payment_note': note,
          'payment_reference_number': referenceNumber,
          if (referencDate != null)
            'payment_referenc_date': referencDate.toString(),
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    return result;
  }
}
