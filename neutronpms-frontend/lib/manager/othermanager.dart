import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/otherhotelservice.dart';

import '../handler/firebasehandler.dart';
import '../manager/servicemanager.dart';
import '../modal/service/other.dart';
import 'generalmanager.dart';

class OtherManager {
  List<OtherHotelService> dataOthers = [];

  static final OtherManager _instance = OtherManager._singleton();
  OtherManager._singleton();
  factory OtherManager() {
    return _instance;
  }

  void update() {
    dataOthers = ConfigurationManagement().others;
  }

  List<String> getActiveOtherServiceNames() => dataOthers
      .where((otherService) => otherService.isActive!)
      .map((other) => other.name.toString())
      .toList();

  List<String> getActiveOtherServiceIDs() => dataOthers
      .where((otherService) => otherService.isActive!)
      .map((other) => other.id.toString())
      .toList();

  String getFirstActiveOtherServiceID() {
    try {
      return getActiveOtherServiceIDs().first;
    } catch (e) {
      return '';
    }
  }

  String getServiceNameByID(String id) {
    try {
      return dataOthers.firstWhere((other) => other.id == id).name.toString();
    } catch (e) {
      return '';
    }
  }

  String getServiceIDByName(String name) {
    try {
      return dataOthers.firstWhere((other) => other.name == name).id.toString();
    } catch (e) {
      return '';
    }
  }

  Future<List<Other>> getOtherServicesByDateRangeFromCloud(
      DateTime startDate, DateTime endDate) async {
    final DateTime start =
        DateTime(startDate.year, startDate.month, startDate.day, 0);
    final DateTime end = DateTime(endDate.year, endDate.month, endDate.day, 24);

    return await FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('used', isGreaterThanOrEqualTo: start)
        .where('used', isLessThan: end)
        .where('cat', whereIn: [
          ServiceManager.OTHER_CAT,
          ServiceManager.EXTRA_SERVICE_CAT
        ])
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .get()
        .then((QuerySnapshot querySnapshot) {
          List<Other> services = [];
          for (var doc in querySnapshot.docs) {
            services.add(Other.fromSnapshot(doc));
          }
          return services;
        })
        .catchError((e) {
          print(e.toString());
          return e;
        });
  }
}
