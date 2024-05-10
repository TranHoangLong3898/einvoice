import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/modal/service/deposit.dart';

import '../handler/firebasehandler.dart';
import '../modal/booking.dart';
import '../modal/status.dart';

class BookingManager {
  static final BookingManager _instance = BookingManager._internal();
  factory BookingManager() {
    return _instance;
  }
  BookingManager._internal();

  Future<List<Booking>?> getBookingByOutDateRange(
      DateTime start, DateTime end) async {
    try {
      List<Booking> bookings = [];

      final DateTime startDate =
          DateTime(start.year, start.month, start.day, 0);
      final DateTime endDate = DateTime(end.year, end.month, end.day, 24);

      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .where('out_time',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('out_time', isLessThan: Timestamp.fromDate(endDate))
          .where('status', isEqualTo: BookingStatus.checkout)
          .orderBy('out_time')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          bookings.add(Booking.fromSnapshot(doc));
        }
      });
      return bookings;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Booking>> getBookingsBySID(
      String sID, bool isSearchIncludeSubBooking) async {
    try {
      List<Booking> bookings = [];

      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .where('sid', isEqualTo: sID)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          if (doc.get('group')) {
            Booking parent = Booking.groupFromSnapshot(doc);
            //add sub booking
            if (isSearchIncludeSubBooking) {
              for (var idChildBooking in parent.subBookings!.keys) {
                bookings.add(Booking.fromBookingParent(idChildBooking, parent));
              }
            } else {
              //add parent booking
              bookings.add(parent);
            }
          } else {
            bookings.add(Booking.fromSnapshot(doc));
          }
        }
      });
      return bookings;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<Booking?> getBookingByID(String id) async {
    Booking? result = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(id)
        .get()
        .then((value) {
      if (value.exists) {
        if (value.data()?['group'] ?? false) {
          return Booking.groupFromSnapshot(value);
        } else {
          return Booking.fromSnapshot(value);
        }
      }
    }).catchError((onError) {
      print(onError);
      return onError;
    });
    return result;
  }

  Future<Booking> getBookingGroupByID(String id) async {
    final Booking result = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(id)
        .get()
        .then((value) => Booking.groupFromSnapshot(value))
        .catchError((onError) => onError);
    return result;
  }

  Future<Booking?> getBasicBookingByID(String id) async {
    try {
      return await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBasicBookings)
          .doc(id)
          .get()
          .then((DocumentSnapshot doc) => Booking.basicFromSnapshot(doc));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Booking>> searchBookings(
      {DateTime? inDate,
      DateTime? outDate,
      String? sourceID,
      int? statusID,
      String? room,
      String? sID}) async {
    try {
      if (inDate == null &&
          outDate == null &&
          sourceID == null &&
          statusID == null &&
          room == null &&
          sID == null) {
        return [];
      }

      dynamic query =
          FirebaseHandler.hotelRef.collection(FirebaseHandler.colBookings);
      if (inDate != null) {
        query = query.where('in_date', isEqualTo: inDate);
      }
      if (outDate != null) {
        query = query.where('out_date', isEqualTo: outDate);
      }
      if (sourceID != null) {
        query = query.where('source', isEqualTo: sourceID);
      }
      if (statusID != null) {
        query = query.where('status', isEqualTo: statusID);
      }
      if (sID != null) {
        query = query.where('sid', isEqualTo: sID);
      }
      if (room != null) {
        query = query.where('room', isEqualTo: room);
      }

      List<Booking> bookings = [];

      final snapshot = await (query as Query).get();

      for (var doc in snapshot.docs) {
        bookings.add(Booking.fromSnapshot(doc));
      }

      return bookings;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<Booking>> searchBookingStayingRoom(
      {int? statusID, String? room, bool? isSearchIncludeSubBooking}) async {
    try {
      isSearchIncludeSubBooking ??= false;
      if (statusID == null && room == null) {
        return [];
      }
      Query query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBasicBookings)
          .where('status', isEqualTo: statusID)
          .where('room', isEqualTo: room);

      List<Booking> bookings = [];
      final snapshot = await query.get();
      for (var doc in snapshot.docs) {
        if (doc.get('group')) {
          final bookingGroupDoc = await FirebaseHandler.hotelRef
              .collection(FirebaseHandler.colBookings)
              .doc(doc.get('sid'))
              .get();
          Booking parent = Booking.groupFromSnapshot(bookingGroupDoc);
          //add sub booking
          if (isSearchIncludeSubBooking) {
            bookings.add(Booking.fromBookingParent(doc.id, parent));
          } else {
            //add parent booking
            bookings.add(parent);
          }
        } else {
          final booking = await FirebaseHandler.hotelRef
              .collection(FirebaseHandler.colBookings)
              .doc(doc.id)
              .get();
          bookings.add(Booking.fromSnapshot(booking));
        }
      }
      return bookings;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<Deposit?> getDepositOfBookingByDepositId(
      String bookingId, String depositId) async {
    try {
      Deposit deposit = await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(bookingId)
          .collection(FirebaseHandler.colDeposits)
          .doc(depositId)
          .get()
          .then((value) => Deposit.fromSnapshot(value));
      return deposit;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
