import 'package:cloud_firestore/cloud_firestore.dart';

import '../../manager/servicemanager.dart';
import 'service.dart';

class OutsideRestaurantService extends Service {
  final List<DishRestaurantService>? items;
  final String? restaurantId;
  final String? restaurantName;
  final double? discount;
  final double? surcharge;

  OutsideRestaurantService({
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
    bool? isGroup,
    this.restaurantId,
    this.restaurantName,
    this.discount,
    this.surcharge,
  }) : super(
          id: id ?? "",
          created: created ?? Timestamp.now(),
          total: total ?? 0,
          cat: ServiceManager.OUTSIDE_RESTAURANT_CAT,
          status: status ?? "",
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
        );

  factory OutsideRestaurantService.fromSnapshot(DocumentSnapshot doc) {
    List<DishRestaurantService> dishes = (doc.get('items') as List)
        .map((e) => DishRestaurantService.fromMap(e))
        .toList();
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return OutsideRestaurantService(
      id: doc.id,
      items: dishes,
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
      restaurantId: data.containsKey('res_id') ? data['res_id'] : '',
      restaurantName: data.containsKey('res_name') ? data['res_name'] : '',
      discount: data.containsKey('discount') ? data['discount'].toDouble() : 0,
      surcharge:
          data.containsKey('surcharge') ? data['surcharge'].toDouble() : 0,
    );
  }

  @override
  num? getTotal() => total;

  double get itemCharge => items!.fold(
      0,
      (previousValue, element) =>
          previousValue + element.price * element.quantity);

  double get totalBill => itemCharge + surcharge!;
}

class DishRestaurantService {
  String name;
  double price;
  int quantity;

  DishRestaurantService(this.name, this.price, this.quantity);

  factory DishRestaurantService.fromMap(Map<String, dynamic> data) =>
      DishRestaurantService(
          data['name'], data['price']?.toDouble(), data['quantity']);
}
