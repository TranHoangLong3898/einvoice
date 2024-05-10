import 'package:cloud_firestore/cloud_firestore.dart';

import '../../manager/servicemanager.dart';
import '../../modal/service/service.dart';

class Other extends Service {
  String? type;
  String? supplierID;
  Timestamp? date;

  Other({
    this.type,
    num? total,
    this.supplierID,
    String? desc,
    this.date,
    Timestamp? time,
    String? status,
    String? bookingID,
    String? id,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? room,
    String? sID,
    String? saler,
    bool? isGroup,
  }) : super(
          id: id ?? "",
          created: time ?? Timestamp.now(),
          status: status ?? "",
          total: total ?? 0,
          cat: ServiceManager.OTHER_CAT,
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          desc: desc ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
          saler: saler ?? "",
        );

  factory Other.fromSnapshot(DocumentSnapshot doc) => Other(
        id: doc.id,
        desc: doc.get('desc'),
        supplierID: doc.get('supplier'),
        total: doc.get('total'),
        time: doc.get('created'),
        date: doc.get('used'),
        status: doc.get('status'),
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
  num? getTotal() => total;
}
