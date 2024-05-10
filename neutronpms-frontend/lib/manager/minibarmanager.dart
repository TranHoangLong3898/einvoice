import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';

class MinibarManager {
  final List<HotelItem> _dataMinibars = [];

  List<HotelItem> get minibars => _dataMinibars;

  static final MinibarManager _instance = MinibarManager._singleton();
  MinibarManager._singleton();
  factory MinibarManager() {
    return _instance;
  }

  void update() {
    _dataMinibars.clear();
    _dataMinibars.addAll(ItemManager()
        .items
        .where((element) => element.type == ItemType.minibar));
  }

  List<String> getActiveItemsId() {
    return _dataMinibars
        .where((minibar) => minibar.isActive!)
        .map((minibar) => minibar.id.toString())
        .toList();
  }

  List<HotelItem> getActiveItems() {
    return _dataMinibars.where((element) => element.isActive!).toList();
  }

  Map<String, dynamic> createItemMap({num? price, int? amount}) {
    return {'price': price, 'amount': amount};
  }

  String getItemNameByID(String id) {
    try {
      return _dataMinibars
          .firstWhere((minibar) => minibar.id == id)
          .name
          .toString();
    } catch (e) {
      return '';
    }
  }

  double? getPriceOfItem(String itemId) =>
      _dataMinibars.firstWhere((element) => element.id == itemId).sellPrice ??
      0;
}
