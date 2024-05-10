class RoomType {
  final String? name;
  final int? guest;
  final List<dynamic>? beds;
  final num? price;
  final num? minPrice;
  String? id;
  final bool? isDelete;
  final int? total;
  RoomType(
      {this.guest = 0,
      this.beds = const [],
      this.name = '',
      this.price = 0,
      this.id,
      this.isDelete,
      this.minPrice,
      this.total});

  factory RoomType.fromSnapShot(dynamic snapshot) {
    return RoomType(
        name: snapshot['name'],
        price: snapshot['price'],
        guest: snapshot['guest'],
        beds: snapshot['beds'],
        isDelete: snapshot['is_delete'],
        total: snapshot['num'],
        minPrice: snapshot['min_price']);
  }

  String getFirstBed() {
    try {
      if (beds!.contains('?')) {
        return '?';
      }
      return beds!.first.toString();
    } catch (e) {
      return '?';
    }
  }
}
