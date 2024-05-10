import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../../handler/firebasehandler.dart';
import '../../../manager/generalmanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../util/dateutil.dart';

class ReprtBreakfastManagementController extends ChangeNotifier {
  DateTime? staysDate = DateTime.now();
  List<Booking> bookings = [];
  StreamSubscription? subscription;
  bool isLoading = false;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward;
  List<String> meals = [
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LUNCH),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DINNER),
  ];
  late String selectMeal;

  final int pageSize = 10;

  ReprtBreakfastManagementController() {
    selectMeal = meals.first;
    staysDate = DateUtil.to12h(Timestamp.now().toDate());
    loadDataBooking();
  }

  Query loadBookingHaveBreakfast() {
    print(staysDate);
    Query queryData;
    queryData = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContains: staysDate)
        .where('status', whereIn: [
      BookingStatus.booked,
      BookingStatus.checkin,
      BookingStatus.checkout,
    ]).orderBy('stay_days');
    if (selectMeal == UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryData = queryData
          .where('breakfast', isEqualTo: true)
          .where('lunch', isEqualTo: true)
          .where('dinner', isEqualTo: true);
    }
    if (selectMeal ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST)) {
      queryData = queryData.where('breakfast', isEqualTo: true);
    }
    if (selectMeal ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LUNCH)) {
      queryData = queryData.where('lunch', isEqualTo: true);
    }
    if (selectMeal ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DINNER)) {
      queryData = queryData.where('dinner', isEqualTo: true);
    }
    // .orderBy('status', descending: true)
    return queryData;
  }

  void loadDataBooking() async {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = loadBookingHaveBreakfast()
        .snapshots()
        .listen((event) => updateBookingsAndQueries(event));
  }

  void updateBookingsAndQueries(QuerySnapshot snapshot) {
    bookings.clear();
    if (snapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = loadBookingHaveBreakfast()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = loadBookingHaveBreakfast()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      snapshotTepm = snapshot;
      for (var booking in snapshot.docs) {
        bookings.add(Booking.fromSnapshot(booking));
      }
      if (snapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = loadBookingHaveBreakfast()
              .endBeforeDocument(snapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = loadBookingHaveBreakfast()
              .startAfterDocument(snapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = loadBookingHaveBreakfast()
            .startAfterDocument(snapshot.docs.last)
            .limit(pageSize);
        preQuery = loadBookingHaveBreakfast()
            .endBeforeDocument(snapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void setDate(DateTime newDate) {
    if (staysDate != null && DateUtil.equal(staysDate!, newDate)) return;
    staysDate = DateUtil.to12h(newDate);
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = loadBookingHaveBreakfast()
        .snapshots()
        .listen((event) => updateBookingsAndQueries(event));
    notifyListeners();
  }

  void getBasicBookingsNextPage() {
    if (nextQuery == null) return;
    isLoading = true;
    notifyListeners();
    forward = true;
    subscription?.cancel();
    subscription = nextQuery!.snapshots().listen((snapshot) {
      updateBookingsAndQueries(snapshot);
    });
  }

  void getBasicBookingsPreviousPage() {
    if (preQuery == null) return;
    isLoading = true;
    notifyListeners();
    forward = false;
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((snapshot) {
      updateBookingsAndQueries(snapshot);
    });
  }

  void getBasicBookingsLastPage() {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = loadBookingHaveBreakfast()
        .limitToLast(pageSize)
        .snapshots()
        .listen((value) {
      updateBookingsAndQueries(value);
      nextQuery = null;
    });
  }

  void getBasicBookingsFirstPage() {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        loadBookingHaveBreakfast().limit(pageSize).snapshots().listen((value) {
      updateBookingsAndQueries(value);
      preQuery = null;
    });
  }

  void cancelStream() {
    subscription?.cancel();
    bookings.clear();
  }

  void setMeal(String value) {
    if (selectMeal == value) return;
    selectMeal = value;
    notifyListeners();
    loadDataBooking();
  }

  Future<List<Booking>> exportToExcel() async {
    List<Booking> bookingExport = [];
    await loadBookingHaveBreakfast().get().then((snapshot) {
      for (var booking in snapshot.docs) {
        bookingExport.add(Booking.fromSnapshot(booking));
      }
    });
    if (bookingExport.isEmpty) return [];
    return bookingExport;
  }
}
