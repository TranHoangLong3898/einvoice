import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';

import '../handler/firebasehandler.dart';
import '../modal/service/bikerental.dart';
import '../modal/service/extraguest.dart';
import '../modal/service/laundry.dart';
import '../modal/service/minibar.dart';
import '../modal/service/other.dart';
import '../modal/service/service.dart';
import 'generalmanager.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() {
    return _instance;
  }

  static const String MINIBAR_CAT = 'minibar';
  static const String EXTRA_GUEST_CAT = 'extra_guest';
  static const String LAUNDRY_CAT = 'laundry';
  static const String BIKE_RENTAL_CAT = 'bike_rental';
  static const String OTHER_CAT = 'other';
  static const String EXTRA_SERVICE_CAT = 'extra_service';
  static const String EXTRA_HOUR = 'extra_hour';
  static const String OUTSIDE_RESTAURANT_CAT = 'restaurant';
  static const String INSIDE_RESTAURANT_CAT = 'inside_restaurant';
  static const String ELECTRICITY_CAT = 'electricity';
  static const String WATER_CAT = 'water';

  static List<String> cats = [
    MINIBAR_CAT,
    INSIDE_RESTAURANT_CAT,
    OUTSIDE_RESTAURANT_CAT,
    EXTRA_GUEST_CAT,
    LAUNDRY_CAT,
    BIKE_RENTAL_CAT,
    OTHER_CAT
  ];

  List<dynamic> _dataStatuses = [];

  ServiceManager._internal();

  Future<void> update(Map<String, dynamic> data) async {
    _dataStatuses = data['statuses'] ?? [];
  }

  List<String> getStatuses() {
    return _dataStatuses
        .map((element) => element['status'].toString())
        .toList();
  }

  List<String> getStatusesByRole(List<String> roles) {
    List<String> result = [];

    try {
      for (var mapStatus in _dataStatuses) {
        if ((mapStatus['role'] as List)
            .any((element) => roles.contains(element))) {
          result.add(mapStatus['status']);
        }
      }
    } catch (e) {}

    return result;
  }

  bool isStatusDone(String status) {
    try {
      return _dataStatuses
          .firstWhere((element) => element['status'] == status)['done'];
    } catch (e) {
      return false;
    }
  }

  Future<List<Service>> getServicesByDateFromCloud(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day, 0);
    final end = DateTime(date.year, date.month, date.day, 24);

    final query = FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('used', isGreaterThanOrEqualTo: start)
        .where('used', isLessThan: end)
        .where('hotel', isEqualTo: GeneralManager.hotelID);

    return await query.get().then((snapshot) {
      List<Service> services = [];
      for (var doc in snapshot.docs) {
        services.add(Service.fromSnapshot(doc));
      }
      return services;
    }).catchError((e) {
      print(e.toString());
      return e;
    });
  }

  Future<Service> getServiceByIDFromCloud(
      String bookingID, String serviceID) async {
    return await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(bookingID)
        .collection(FirebaseHandler.colServices)
        .doc(serviceID)
        .get()
        .then((doc) {
      final cat = doc.get('cat');
      if (cat == MINIBAR_CAT) {
        return Minibar.fromSnapshot(doc);
      } else if (cat == EXTRA_GUEST_CAT) {
        return ExtraGuest.fromSnapshot(doc);
      } else if (cat == LAUNDRY_CAT) {
        return Laundry.fromSnapShot(doc);
      } else if (cat == BIKE_RENTAL_CAT) {
        return BikeRental.fromSnapshot(doc);
      } else if (cat == OTHER_CAT) {
        return Other.fromSnapshot(doc);
      } else if (cat == OUTSIDE_RESTAURANT_CAT) {
        return OutsideRestaurantService.fromSnapshot(doc);
      } else if (cat == INSIDE_RESTAURANT_CAT) {
        return InsideRestaurantService.fromSnapshot(doc);
      } else {
        return Service.fromSnapshot(doc);
      }
    }).catchError((e) {
      print(e);
      return e;
    });
  }
}
