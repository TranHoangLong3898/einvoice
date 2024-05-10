import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/status.dart';

import '../../../handler/firebasehandler.dart';
import '../../../modal/booking.dart';
import '../../../util/dateutil.dart';

class RevenueBySalerController extends ChangeNotifier {
  late DateTime now, startDate, endDate;
  final int pageSize = 10;
  StreamSubscription? _streamSubscription;
  bool? isLoading, forward;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  List<Booking> bookings = [];
  List<Booking> bookingsNotGroupTepm = [];
  String stastus = "";
  late TextEditingController teEmail;
  Map<String, double> mapCost = {};
  Map<String, double> mapCostExport = {};

  RevenueBySalerController() {
    isLoading = true;
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    teEmail = TextEditingController(text: "");
    loadBooking();
  }

  Query getInitQuery() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where("created", isGreaterThanOrEqualTo: startDate)
        .where("created", isLessThanOrEqualTo: endDate)
        .where('status', whereIn: [
      BookingStatus.booked,
      BookingStatus.checkin,
      BookingStatus.checkout,
    ]).orderBy("created");
    if (teEmail.text.isNotEmpty) {
      query = query.where("email_saler", isEqualTo: teEmail.text);
    }
    return query;
  }

  Future<void> loadBooking() async {
    print(52);
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshots) {
      print("InitLoadBooking");
      updateBookingAndQueries(snapshots);
    });
  }

  void cancelStream() async {
    await _streamSubscription?.cancel();
  }

  Future<void> updateBookingAndQueries(QuerySnapshot querySnapshot) async {
    bookings.clear();
    bookingsNotGroupTepm.clear();
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
      for (var documentSnapshot in querySnapshot.docs) {
        mapCost[documentSnapshot.get('sid')] = 0.0;
        if (documentSnapshot.get("source") == "virtual") continue;
        if (documentSnapshot.get('group')) {
          final Booking groupBooking =
              Booking.groupFromSnapshot(documentSnapshot);
          String room = ' ';
          for (var subBooking in groupBooking.subBookings!.entries) {
            mapCost[documentSnapshot.get('sid')] =
                (mapCost[documentSnapshot.get('sid')]! +
                    await getTotalCost(subBooking.key));
            room +=
                '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
          }
          groupBooking.room = room;
          bookingsNotGroupTepm.add(groupBooking);
        } else {
          mapCost[documentSnapshot.get('sid')] =
              mapCost[documentSnapshot.get('sid')]! +
                  await getTotalCost(documentSnapshot.id);
          bookingsNotGroupTepm.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      bookings.addAll(bookingsNotGroupTepm);
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

  Future<double> getTotalCost(String id) async {
    final doc = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .doc(id)
        .get();
    if (doc.exists) {
      return (doc.data())!.containsKey('total_cost')
          ? doc.get('total_cost')
          : 0;
    }
    return 0;
  }

  Future<List<Booking>> getAllBooking() async {
    List<Booking> bookingsExport = [];
    List<Booking> bookingsNotGroupTepmExprot = [];
    mapCostExport.clear();
    await getInitQuery().get().then((QuerySnapshot querySnapshot) async {
      for (var documentSnapshot in querySnapshot.docs) {
        mapCostExport[documentSnapshot.get('sid')] = 0;
        if (documentSnapshot.get("source") == "virtual") continue;
        if (documentSnapshot.get('group')) {
          final Booking groupBooking =
              Booking.groupFromSnapshot(documentSnapshot);
          String room = ' ';
          for (var subBooking in groupBooking.subBookings!.entries) {
            mapCostExport[documentSnapshot.get('sid')] =
                (mapCostExport[documentSnapshot.get('sid')]! +
                    await getTotalCost(subBooking.key));
            room +=
                '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
          }
          groupBooking.room = room;
          bookingsNotGroupTepmExprot.add(groupBooking);
        } else {
          mapCostExport[documentSnapshot.get('sid')] =
              (mapCostExport[documentSnapshot.get('sid')]! +
                  await getTotalCost(documentSnapshot.id));
          bookingsNotGroupTepmExprot
              .add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      bookingsExport.addAll(bookingsNotGroupTepmExprot);
    });
    return bookingsExport;
  }

  void setStatus(String value) {
    if (stastus == value) return;
    stastus = value;
    notifyListeners();
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

  void getAccountingNextPage() async {
    if (nextQuery == null) return;
    forward = true;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = nextQuery!.snapshots().listen((value) {
      updateBookingAndQueries(value);
    });
  }

  void getAccountingPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = preQuery!.snapshots().listen((value) {
      updateBookingAndQueries(value);
    });
  }

  void getAccountingLastPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limitToLast(pageSize).snapshots().listen((value) {
      updateBookingAndQueries(value);
      nextQuery = null;
    });
  }

  void getAccountingFirstPage() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription =
        getInitQuery().limit(pageSize).snapshots().listen((value) {
      updateBookingAndQueries(value);
      preQuery = null;
    });
  }
}
