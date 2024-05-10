import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';

class RestaurantItemManager {
  final List<HotelItem> _dataRestaurantItems = [];

  List<HotelItem> get restaurantItems => _dataRestaurantItems;

  static final RestaurantItemManager _instance =
      RestaurantItemManager._singleton();
  RestaurantItemManager._singleton();

  factory RestaurantItemManager() => _instance;

  void update() {
    _dataRestaurantItems.clear();
    _dataRestaurantItems.addAll(ItemManager()
        .items
        .where((element) => element.type == ItemType.restaurant));
  }

  List<String?> getActiveItemsId() => _dataRestaurantItems
      .where((element) => element.isActive!)
      .map((element) => element.id)
      .toList();
  List<HotelItem> getActiveItems() {
    return _dataRestaurantItems.where((element) => element.isActive!).toList();
  }

  Map<String, dynamic> createItemMap({num? price, int? amount}) {
    return {'price': price, 'amount': amount};
  }

  // String getItemIDByName(String name) => _dataRestaurantItems
  //     .firstWhere((element) => element.name == name, orElse: () => null)
  //     ?.id;

  String? getItemNameByID(String id) =>
      _dataRestaurantItems.firstWhere((element) => element.id == id).name;

  double getPriceOfItem(String itemId) =>
      _dataRestaurantItems
          .firstWhere((element) => element.id == itemId)
          .sellPrice ??
      0;
}
