import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/bikehotelservice.dart';

import '../handler/firebasehandler.dart';
import '../manager/servicemanager.dart';
import '../modal/service/bikerental.dart';
import '../util/messageulti.dart';
import 'generalmanager.dart';

class BikeRentalManager {
  List<BikeHotelService> dataBikes = [];
  Map<String, dynamic>? configs;

  static final BikeRentalManager _instance = BikeRentalManager._singleton();
  BikeRentalManager._singleton();
  factory BikeRentalManager() {
    return _instance;
  }

  void update() {
    dataBikes = ConfigurationManagement()
        .bikes
        .where((bike) => bike.isActive!)
        .toList();
    configs = ConfigurationManagement().bikeConfigs;
  }

  List<String> getTypes() => configs == null
      ? []
      : [
          MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_MANUAL),
          MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_AUTO)
        ];

  num getDefaultPrice(String type) => configs == null ? 0 : configs![type];

  num? getPrice(String bike) {
    try {
      return bike.isNotEmpty
          ? dataBikes.firstWhere((element) => element.id == bike).price
          : 0;
    } catch (e) {
      return 0;
    }
  }

  List<String> getAvailableBikesByTypeAndSupplierId(
      String type, String supplierId) {
    try {
      return dataBikes
          .where((bike) =>
              !(bike.isRent!) &&
              bike.bikeType == type &&
              bike.supplierId == supplierId)
          .map((bike) => bike.id!)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BikeRental>> getBikeRentalsByDateRangeFromCloud(
      DateTime startDate, DateTime endDate) async {
    final DateTime start =
        DateTime(startDate.year, startDate.month, startDate.day, 0);
    final DateTime end = DateTime(endDate.year, endDate.month, endDate.day, 24);

    return await FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('used', isGreaterThanOrEqualTo: start)
        .where('used', isLessThan: end)
        .where('cat', isEqualTo: ServiceManager.BIKE_RENTAL_CAT)
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<BikeRental> bikeRentals = [];
      for (var doc in querySnapshot.docs) {
        bikeRentals.add(BikeRental.fromSnapshot(doc));
      }
      return bikeRentals;
    }).catchError((e) {
      print(e.toString());
      return e;
    });
  }
}
