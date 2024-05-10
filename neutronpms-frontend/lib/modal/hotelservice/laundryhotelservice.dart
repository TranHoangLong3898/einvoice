import 'package:ihotel/modal/hotelservice/hotelservice.dart';

class LaundryHotelService extends HotelService {
  num? piron;
  num? plaundry;
  LaundryHotelService(
      {String? id,
      String? name,
      String? type,
      this.piron,
      this.plaundry,
      bool? isActive})
      : super(id: id, name: name, type: type, isActive: isActive);

  factory LaundryHotelService.fromMap(dynamic doc) => LaundryHotelService(
      name: doc['name'],
      piron: doc['piron'],
      plaundry: doc['plaundry'],
      isActive: doc['active'] ?? false);
}
