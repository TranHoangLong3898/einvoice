import 'package:ihotel/modal/hotelservice/hotelservice.dart';

class BikeHotelService extends HotelService {
  //type of bike: auto or manual
  String? bikeType;
  num? price;
  bool? isRent;
  String? supplierId;
  BikeHotelService(
      {String? id,
      String? type,
      this.price,
      bool? isActive,
      this.bikeType,
      this.isRent,
      this.supplierId})
      : super(
            type: type ?? "",
            isActive: isActive ?? false,
            id: id ?? "",
            name: id ?? "");

  factory BikeHotelService.fromMap(dynamic doc) => BikeHotelService(
      bikeType: doc['type'],
      price: doc['price'],
      isRent: doc['rented'] ?? false,
      supplierId: doc['supplier'],
      isActive: doc['active'] ?? false);
}
