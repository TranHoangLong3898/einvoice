import 'package:ihotel/modal/hotelservice/hotelservice.dart';

class OtherHotelService extends HotelService {
  OtherHotelService({String? id, String? name, String? type, bool? isActive})
      : super(id: id, name: name, type: type, isActive: isActive);

  factory OtherHotelService.fromMap(dynamic doc) =>
      OtherHotelService(name: doc['name'], isActive: doc['active'] ?? false);
}
