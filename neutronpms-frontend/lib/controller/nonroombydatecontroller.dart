import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/dateutil.dart';

class BookingNRoomByDateController extends ChangeNotifier {
  DateTime dateTime;
  final int pageSize = 10;
  StreamSubscription? _streamSubscription;
  bool? isLoading, forward;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  List<Booking> dataBooking = [];
  BookingNRoomByDateController(this.dateTime) {
    loadBookingNonRoom();
  }

  Query getInitQuery() {
    return FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where('room', isEqualTo: '')
        .where('stay_days', arrayContainsAny: [DateUtil.to12h(dateTime)]).where(
            'status',
            isEqualTo: BookingStatus.booked);
  }

  Future<void> loadBookingNonRoom() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshots) async {
      await updateloadBookingNonRoomAndQueries(snapshots);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateloadBookingNonRoomAndQueries(
      QuerySnapshot querySnapshot) async {
    dataBooking.clear();
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQuery()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQuery()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      snapshotTepm = querySnapshot;
      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          dataBooking.add(Booking.basicFromSnapshot(doc));
        }
      }
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQuery()
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQuery()
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQuery()
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQuery()
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void getBookingNonRoomNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = nextQuery!.snapshots().listen((value) {
      updateloadBookingNonRoomAndQueries(value);
    });
  }

  void getBookingNonRoomPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = preQuery!.snapshots().listen((value) {
      updateloadBookingNonRoomAndQueries(value);
    });
  }

  void getBookingNonRoomLastPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limitToLast(pageSize).snapshots().listen((value) {
      updateloadBookingNonRoomAndQueries(value);
      nextQuery = null;
    });
  }

  void getBookingNonRoomFirstPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateloadBookingNonRoomAndQueries(value);
      preQuery = null;
    });
  }
}
