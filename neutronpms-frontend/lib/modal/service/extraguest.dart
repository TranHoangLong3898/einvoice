import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/servicemanager.dart';

import 'service.dart';

class ExtraGuest extends Service {
  num? number;
  num? price;
  String? type;
  DateTime? start;
  DateTime? end;

  ExtraGuest({
    String? id,
    num? total,
    this.number = 0,
    this.price = 0,
    this.type,
    this.start,
    this.end,
    String? status,
    String? bookingID,
    Timestamp? time,
    DateTime? inDate,
    DateTime? outDate,
    String? room,
    String? name,
    String? sID,
    bool? isGroup,
    String? saler,
  }) : super(
          id: id ?? "",
          created: time ?? Timestamp.now(),
          status: status ?? "",
          total: total ?? 0,
          cat: ServiceManager.EXTRA_GUEST_CAT,
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          room: room ?? "",
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
          saler: saler ?? "",
        );

  factory ExtraGuest.fromSnapshot(DocumentSnapshot doc) => ExtraGuest(
        id: doc.id,
        start: (doc.get('start') as Timestamp).toDate(),
        end: (doc.get('end') as Timestamp).toDate(),
        number: doc.get('number'),
        price: doc.get('price'),
        total: doc.get('total'),
        status: doc.get('status'),
        time: doc.get('created'),
        bookingID: doc.get('bid'),
        inDate: (doc.get('in') as Timestamp).toDate(),
        outDate: (doc.get('out') as Timestamp).toDate(),
        name: doc.get('name'),
        room: doc.get('room'),
        sID: doc.get('sid'),
        type: doc.get('type'),
        isGroup: doc.get('group'),
        saler: (doc.data() as Map<String, dynamic>).containsKey('email_saler')
            ? doc.get('email_saler')
            : "",
      );

  @override
  num getTotal() => (number ?? 0) * end!.difference(start!).inDays * price!;
}
