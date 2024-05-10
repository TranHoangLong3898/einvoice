import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/manager/generalmanager.dart';

import '../../manager/servicemanager.dart';

class Service {
  num? total;
  final Timestamp? created;
  final Timestamp? used;
  final String? id;
  final String? cat;
  final String? bookingID;
  final String? name;
  final DateTime? inDate;
  final DateTime? outDate;
  final String? sID;
  String? status;
  final String? room;
  bool? deletable;
  String? desc;
  String? saler;
  bool? isGroup;
  Service(
      {this.created,
      this.id,
      this.total,
      this.cat,
      this.status,
      this.bookingID,
      this.used,
      this.name,
      this.inDate,
      this.outDate,
      this.deletable = true,
      this.room,
      this.desc,
      this.sID,
      this.isGroup,
      this.saler}) {
    total = getTotal();
    status ??= ServiceManager().getStatuses()[0];
  }

  factory Service.fromSnapshot(DocumentSnapshot doc) => Service(
      id: doc.id,
      total: doc.get('total'),
      status: doc.get('status').isEmpty ? "open" : doc.get('status'),
      created: doc.get('created'),
      used: doc.get('used'),
      bookingID: doc.get('bid'),
      inDate: (doc.get('in') as Timestamp).toDate(),
      outDate: (doc.get('out') as Timestamp).toDate(),
      name: doc.get('name'),
      room: doc.get('room'),
      isGroup: doc.get('group'),
      sID: doc.get('sid'),
      deletable: (doc.data() as Map<String, dynamic>).containsKey('delete')
          ? doc.get('delete')
          : true,
      desc: (doc.data() as Map<String, dynamic>).containsKey('desc')
          ? doc.get('desc')
          : '',
      saler: (doc.data() as Map<String, dynamic>).containsKey('email_saler')
          ? doc.get('email_saler')
          : '',
      cat: doc.get('cat'));

  num? getTotal() => total;

  Future<String> updateStatus(String status) async {
    return await FirebaseFunctions.instance
        .httpsCallable('service-updateStatusService')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': bookingID,
          if (isGroup ?? false) 'booking_sid': sID,
          'service_id': id,
          'service_status': status
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }
}
