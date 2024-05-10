abstract class HotelService {
  String? id;
  String? name;
  String? type;
  bool? isActive;
  HotelService({
    this.id,
    this.name,
    this.type,
    this.isActive = true,
  });

  HotelService.fromMap(dynamic doc);
}
