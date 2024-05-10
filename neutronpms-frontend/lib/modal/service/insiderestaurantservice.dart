import 'package:cloud_firestore/cloud_firestore.dart';

import '../../manager/servicemanager.dart';
import 'service.dart';

class InsideRestaurantService extends Service {
  final Map<String, dynamic>? items;

  InsideRestaurantService({
    String? id,
    Timestamp? created,
    num? total,
    this.items,
    String? bookingID,
    String? status,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? room,
    String? sID,
    String? saler,
    bool? isGroup,
  }) : super(
          id: id ?? "",
          created: created ?? Timestamp.now(),
          total: total ?? 0,
          cat: ServiceManager.INSIDE_RESTAURANT_CAT,
          status: status ?? "",
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
          saler: saler ?? "",
        );

  factory InsideRestaurantService.fromSnapshot(DocumentSnapshot doc) =>
      InsideRestaurantService(
        id: doc.id,
        items: doc.get('items'),
        created: doc.get('created'),
        total: doc.get('total'),
        status: doc.get('status'),
        inDate: (doc.get('in') as Timestamp).toDate(),
        outDate: (doc.get('out') as Timestamp).toDate(),
        name: doc.get('name'),
        room: doc.get('room'),
        sID: doc.get('sid'),
        bookingID: doc.get('bid'),
        isGroup: doc.get('group'),
        saler: (doc.data() as Map<String, dynamic>).containsKey('email_saler')
            ? doc.get('email_saler')
            : "",
      );

  @override
  num getTotal() {
    num sum = 0;
    items?.forEach((key, value) {
      sum += (items?[key] as Map)['amount'] * (items?[key] as Map)['price'];
    });
    return sum;
  }

  num getPrice(String item) =>
      items!.containsKey(item) ? (items?[item] as Map)['price'] : 0;

  int getAmount(String item) =>
      items!.containsKey(item) ? (items?[item] as Map)['amount'] : 0;

  List<String>? getItems() => items?.keys.toList();
}
