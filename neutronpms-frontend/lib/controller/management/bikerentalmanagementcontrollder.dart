import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../modal/service/bikerental.dart';

class BikeRentalManagementController extends ChangeNotifier {
  late List<BikeRental> bikeRentals = [];
  DateTime startDate = DateUtil.to0h(DateTime.now());
  DateTime endDate = DateUtil.to24h(DateTime.now());

  /// tình trang xe đã nhân hay chưa
  late int rentalProgress;

  final int pageSize = 10;
  late bool isLoadding;
  BikeRentalManagementController(this.rentalProgress) {
    isLoadding = true;
    loadBikeRentals();
  }

  Query? nextQuery;
  Query? preQuery;
  bool? forward;

  Query getInitQueryBikeRentals() {
    return FirebaseFirestore.instance
        .collectionGroup(FirebaseHandler.colServices)
        .where('cat', isEqualTo: ServiceManager.BIKE_RENTAL_CAT)
        .where('progress',
            isEqualTo: rentalProgress == BikeRentalProgress.booked
                ? BikeRentalProgress.booked
                : BikeRentalProgress.checkin)
        .where('hotel', isEqualTo: GeneralManager.hotelID)
        .orderBy('start');
  }

  void updateBikeRentalsAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
      } else {
        preQuery = null;
      }
    } else {
      bikeRentals.clear();
      for (var doc in querySnapshot.docs) {
        bikeRentals.add(BikeRental.fromSnapshot(doc));
      }

      nextQuery = getInitQueryBikeRentals()
          .startAfterDocument(querySnapshot.docs.last)
          .limit(pageSize);
      preQuery = getInitQueryBikeRentals()
          .endBeforeDocument(querySnapshot.docs.first)
          .limitToLast(pageSize);
    }
    notifyListeners();
  }

  void loadBikeRentals() async {
    bikeRentals.clear();
    try {
      await getInitQueryBikeRentals().limit(pageSize).get().then(
          (QuerySnapshot querySnapshot) {
        updateBikeRentalsAndQueries(querySnapshot);
      }, onError: (err) => print(err.toString()));
    } catch (e) {
    } finally {
      isLoadding = false;
      notifyListeners();
    }
  }

  void getBikeRentalsNextPage() {
    if (nextQuery == null) return;
    forward = true;
    nextQuery!.get().then((value) => updateBikeRentalsAndQueries(value));
  }

  void getBikeRentalsPreviousPage() {
    if (preQuery == null) return;
    forward = false;
    preQuery!.get().then((value) => updateBikeRentalsAndQueries(value));
  }

  void getBikeRentalsFirstPage() {
    getInitQueryBikeRentals()
        .limit(pageSize)
        .get()
        .then((value) => updateBikeRentalsAndQueries(value));
  }

  void getBikeRentalsLastPage() {
    getInitQueryBikeRentals()
        .limitToLast(pageSize)
        .get()
        .then((value) => updateBikeRentalsAndQueries(value));
  }

  num getTotal() =>
      bikeRentals.fold(0, (pre, bikeRental) => pre + bikeRental.getTotal()!);

  Future<String> checkinBike(BikeRental bike) async {
    final now = Timestamp.now();
    Map<String, dynamic> map = {'progress': BikeRentalProgress.checkin};
    map['start'] = now.toDate().toString();
    map['delete'] = false;
    isLoadding = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('service-updateBikeRentalProgress')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': bike.bookingID,
          'bike_rental_id': bike.id,
          'data_update': map,
          if (bike.isGroup ?? false) 'booking_sid': bike.sID
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    if (result == MessageCodeUtil.SUCCESS) {
      bike.start = now;
      bike.deletable = false;
      bikeRentals.removeWhere((element) => element.id == bike.id);
    }
    isLoadding = false;
    notifyListeners();
    return result;
  }

  Future<String> checkoutBike(BikeRental bike) async {
    final now = Timestamp.now();
    num total = 0;
    Map<String, dynamic> map = {'progress': BikeRentalProgress.checkout};
    map['end'] = now.toDate().toString();
    map['used'] = now.toDate().toString();
    total = bike.getTotal()!;
    map['total'] = total;
    map['delete'] = false;
    isLoadding = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('service-updateBikeRentalProgress')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': bike.bookingID,
          'bike_rental_id': bike.id,
          'data_update': map,
          if (bike.isGroup ?? false) 'booking_sid': bike.sID
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    if (result == MessageCodeUtil.SUCCESS) {
      bikeRentals.removeWhere((element) => element.id == bike.id);
    }
    isLoadding = false;
    notifyListeners();
    return result;
  }
}
