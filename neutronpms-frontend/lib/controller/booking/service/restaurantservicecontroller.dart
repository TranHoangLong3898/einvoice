import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../modal/booking.dart';

class RestaurantServiceController extends ChangeNotifier {
  final Booking? booking;

  List<OutsideRestaurantService> resServices = [];
  Map<String, String> restaurantInfo = {};
  late String selectedResName;

  RestaurantServiceController(this.booking) {
    resServices = [];
    restaurantInfo = {};
    selectedResName = '';
    initialize();
  }

  void initialize() async {
    resServices = await booking!.getRestaurantServices();
    getListRestaurantNamesFromServices();
    notifyListeners();
  }

  void getListRestaurantNamesFromServices() {
    restaurantInfo[UITitleCode.STATUS_ALL] =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    selectedResName = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
    for (OutsideRestaurantService element in resServices) {
      restaurantInfo[element.restaurantId!] = element.restaurantName!;
    }
  }

  List<OutsideRestaurantService> getServicesBySelectedRestaurant() {
    if (selectedResName == UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      return resServices;
    }
    return resServices
        .where((element) => element.restaurantName == selectedResName)
        .toList();
  }

  void setSelectedRestaurant(String newValue) {
    if (selectedResName == newValue) {
      return;
    }
    selectedResName = newValue;
    notifyListeners();
  }
}

class DeleteRestaurantServiceController extends UpdateServiceController {
  @override
  List<String> getServiceItems() => [];

  @override
  bool isServiceItemsChanged() => true;

  @override
  void saveOldItems() {}

  @override
  void updateService() {}

  @override
  Future<String>? updateServiceToDatabase() {
    return null;
  }
}
