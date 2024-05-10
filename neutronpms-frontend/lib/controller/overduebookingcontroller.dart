import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';

class OverdueBookingController extends ChangeNotifier {
  static final OverdueBookingController _instance =
      OverdueBookingController._singleton();
  OverdueBookingController._singleton();

  //{id, type, virtual}
  List<dynamic> overdueBookings = [];

  StreamSubscription? streamSubscription;
  factory OverdueBookingController() {
    return _instance;
  }

  void cancelStream() {
    overdueBookings.clear();
    streamSubscription?.cancel();
  }

  void getOverdueBookingsFromCloud() {
    streamSubscription?.cancel();
    try {
      FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colManagement)
          .doc(FirebaseHandler.colOverdueBookings)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> snapshotData = snapshot.data()!;
          overdueBookings.clear();
          Map<String, dynamic> overdueCheckinFromCloud =
              snapshotData['overdue_bookings']['checkin'] ?? {};
          Map<String, dynamic> overdueCheckoutFromCloud =
              snapshotData['overdue_bookings']['checkout'] ?? {};
          if (overdueCheckinFromCloud.isNotEmpty) {
            overdueCheckinFromCloud.forEach((key, value) {
              dynamic overdueBooking = value;
              overdueBooking['id'] = key;
              overdueBookings.add(overdueBooking);
            });
          }
          if (overdueCheckoutFromCloud.isNotEmpty) {
            overdueCheckoutFromCloud.forEach((key, value) {
              dynamic overdueBooking = value;
              overdueBooking['id'] = key;
              overdueBookings.add(overdueBooking);
            });
          }
          notifyListeners();
        }
      });
    } catch (e) {
      overdueBookings = [];
    }
  }
}
