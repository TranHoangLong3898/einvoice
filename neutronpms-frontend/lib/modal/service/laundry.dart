import 'package:cloud_firestore/cloud_firestore.dart';

import '../../manager/servicemanager.dart';
import 'service.dart';

class Laundry extends Service {
  final Map<String, dynamic>? items;

  Laundry({
    String? id,
    num? total,
    Timestamp? time,
    String? bookingID,
    this.items,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? sID,
    String? room,
    String? status,
    String? desc,
    String? saler,
    bool? isGroup,
  }) : super(
          id: id ?? "",
          created: time ?? Timestamp.now(),
          total: total ?? 0,
          status: status ?? "",
          cat: ServiceManager.LAUNDRY_CAT,
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          sID: sID ?? "",
          desc: desc ?? "",
          saler: saler ?? "",
          isGroup: isGroup ?? false,
        );

  factory Laundry.fromSnapShot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    return Laundry(
      id: doc.id,
      items: doc.get('items'),
      time: doc.get('created'),
      status: doc.get('status'),
      total: doc.get('total'),
      inDate: (doc.get('in') as Timestamp).toDate(),
      outDate: (doc.get('out') as Timestamp).toDate(),
      name: doc.get('name'),
      room: doc.get('room'),
      sID: doc.get('sid'),
      bookingID: doc.get('bid'),
      isGroup: doc.get('group'),
      desc: data.containsKey('desc') ? doc.get("desc") : "",
      saler: data.containsKey('email_saler') ? doc.get("email_saler") : "",
    );
  }

  num getPrice(String item, String type) => !items!.containsKey(item)
      ? 0
      : (items?[item] as Map).containsKey(type)
          ? items![item][type]['price']
          : 0;

  num getAmount(String item, String type) => !items!.containsKey(item)
      ? 0
      : (items?[item] as Map).containsKey(type)
          ? items![item][type]['amount']
          : 0;

  List<String>? getItems() {
    return items?.keys.toList();
  }

  @override
  num getTotal() {
    num sum = 0;
    num lprice = 0;
    num lamount = 0;
    num iprice = 0;
    num iamount = 0;
    items!.forEach((item, value) {
      lprice = (value as Map).containsKey("laundry")
          ? (value)['laundry']['price']
          : 0;
      iprice = (value).containsKey("iron") ? (value)['iron']['price'] : 0;
      lamount =
          (value).containsKey("laundry") ? (value)['laundry']['amount'] : 0;
      iamount = (value).containsKey("iron") ? (value)['iron']['amount'] : 0;
      sum += lprice * lamount + iprice * iamount;
    });
    return sum;
  }
}
