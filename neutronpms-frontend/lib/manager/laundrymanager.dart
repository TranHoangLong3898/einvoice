import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/laundryhotelservice.dart';

class LaundryManager {
  List<LaundryHotelService> dataLaundries = [];

  static final LaundryManager _instance = LaundryManager._singleton();
  LaundryManager._singleton();
  factory LaundryManager() {
    return _instance;
  }

  void update() {
    dataLaundries = ConfigurationManagement().laundries;
  }

  num? getLaundryPrice(String id) {
    try {
      return dataLaundries.firstWhere((laundry) => laundry.id == id).plaundry;
    } catch (e) {
      return 0;
    }
  }

  num? getIronPrice(String id) {
    try {
      return dataLaundries.firstWhere((laundry) => laundry.id == id).piron;
    } catch (e) {
      return 0;
    }
  }

  List<String> getActiveItems() {
    return dataLaundries
        .where((laudryService) => laudryService.isActive!)
        .map((laundry) => laundry.id.toString())
        .toList();
  }

  String getItemIDByName(String name) {
    try {
      return dataLaundries
          .firstWhere((laundry) => laundry.name == name)
          .id
          .toString();
    } catch (e) {
      return '';
    }
  }

  String getItemNameByID(String id) {
    try {
      return dataLaundries
          .firstWhere((laundry) => laundry.id == id)
          .name
          .toString();
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> createItemMap(
      {num? lprice, num? lamount, num? iprice, num? iamount}) {
    Map<String, dynamic> map = {};
    if (lamount! > 0) map['laundry'] = {'price': lprice, 'amount': lamount};
    if (iamount! > 0) map['iron'] = {'price': iprice, 'amount': iamount};

    return map;
  }
}
