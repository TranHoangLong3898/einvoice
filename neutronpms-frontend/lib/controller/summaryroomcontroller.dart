import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/booking.dart';

import '../handler/firebasehandler.dart';
import '../manager/roommanager.dart';
import '../modal/status.dart';
import '../util/dateutil.dart';

class SummaryRoomController extends ChangeNotifier {
  String? idRoom;
  bool isLoading = false;
  List<Booking> bookings = [];
  late Booking bookingParent;
  late DateTime now, startDate, endDate;
  Map<String, num> dataCost = {};
  late num totalCostBookingAndRoom,
      totalAllChargeBooking,
      totalCostRoom,
      totalCostBooke = 0;
  SummaryRoomController(this.idRoom) {
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    loadCost();
  }

  Query getInitQueryCost() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .where('room_type', isEqualTo: RoomManager().getRoomTypeById(idRoom!))
        .where('room', isEqualTo: idRoom)
        .orderBy('created');
    return query;
  }

  Query getInitQueryBasicBooking() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('out_date', isGreaterThanOrEqualTo: startDate)
        .where('out_date', isLessThanOrEqualTo: endDate)
        .where('room_type', isEqualTo: RoomManager().getRoomTypeById(idRoom!))
        .where('room', isEqualTo: idRoom)
        .orderBy('out_date');
    return query;
  }

  Future<void> loadCost() async {
    isLoading = true;
    notifyListeners();
    totalCostBookingAndRoom = 0;
    totalAllChargeBooking = 0;
    totalCostBooke = 0;
    totalCostRoom = 0;
    bookings.clear();
    await getInitQueryCost().get().then((querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        totalCostBookingAndRoom += documentSnapshot.get("amount");
        totalCostRoom += documentSnapshot.get("amount");
      }
    });
    await getInitQueryBasicBooking().get().then((querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        final data = (doc.data() as Map<String, dynamic>);
        num totalCost = 0;
        totalCost = data.containsKey('total_cost') ? doc.get('total_cost') : 0;
        if (doc.exists) {
          if (doc.get("status") == BookingStatus.checkin ||
              doc.get("status") == BookingStatus.booked ||
              doc.get("status") == BookingStatus.cancel ||
              doc.get("status") == BookingStatus.noshow) {
            if (totalCost > 0) {
              totalCostBookingAndRoom += totalCost;
              totalCostBooke += totalCost;
              await getInitBooking(doc, totalCost);
            }
          }
          if (doc.get("status") == BookingStatus.checkout) {
            if (totalCost > 0) {
              totalCostBooke += totalCost;
              totalCostBookingAndRoom += totalCost;
            }
            await getInitBooking(doc, totalCost);
          }
        }
      }
    });
    for (var element in bookings
        .where((element) => element.status == BookingStatus.checkout)) {
      totalAllChargeBooking += element.getTotalCharge()!;
    }
    isLoading = false;
    notifyListeners();
  }

  getInitBooking(QueryDocumentSnapshot<Object?> document, num totalCost) async {
    await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(document.get("group") ? document.get("sid") : document.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        if (doc.get("group")) {
          bookingParent = Booking.groupFromSnapshot(doc);
          if (bookingParent.room!
                  .split(", ")
                  .firstWhere((element) =>
                      RoomManager().getIdRoomByName(element) == idRoom)
                  .isNotEmpty &&
              bookingParent.roomTypeID!
                  .split(", ")
                  .firstWhere((element) =>
                      element == RoomManager().getRoomTypeById(idRoom!))
                  .isNotEmpty) {
            dataCost[document.id] = totalCost;
            bookings.add(Booking.fromBookingParent(document.id, bookingParent));
          }
        } else {
          dataCost[doc.id] = totalCost;
          bookings.add(Booking.fromSnapshot(doc));
        }
      }
    });
  }

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    if (startDate.isAtSameMomentAs(newStart)) {
      return;
    }
    startDate = newStart;
    if (startDate.isAfter(endDate)) {
      endDate = DateUtil.to24h(startDate);
    } else if (endDate.difference(startDate).inDays > 30) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 30)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    DateTime newEnd = DateUtil.to24h(date);
    if (endDate.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate)) {
      return;
    }
    endDate = newEnd;
    notifyListeners();
  }
}
