import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/status.dart';

import '../../handler/firebasehandler.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class BookingCanApproverController extends ChangeNotifier {
  DateTime? now, startDate, endDate;
  final int pageSize = 10;
  StreamSubscription? _streamSubscription;
  bool? isLoading, forward;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  List<Booking> bookings = [];
  List<Booking> bookingsNotGroupTepm = [];
  String stastus = "";
  List<String> listStatus = [
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE),
  ];

  BookingCanApproverController() {
    isLoading = true;
    now = DateTime.now();
    startDate = null;
    endDate = null;
    stastus = listStatus.first;
    loadBooking();
  }

  Query getInitQuery() {
    Query query = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('status', isEqualTo: BookingStatus.unconfirmed);
    if (endDate != null && startDate != null) {
      query = query
          .where(getStatus(), isGreaterThanOrEqualTo: startDate)
          .where(getStatus(), isLessThanOrEqualTo: endDate)
          .orderBy(getStatus());
    } else {
      query.orderBy(getStatus());
    }
    return query;
  }

  Future<void> loadBooking() async {
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
        if (documentSnapshot.get("source") == "virtual") continue;
        if (documentSnapshot.get('group')) {
          final Booking groupBooking =
              Booking.groupFromSnapshot(documentSnapshot);
          String room = ' ';
          for (var subBooking in groupBooking.subBookings!.entries) {
            room +=
                '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
          }
          groupBooking.room = room;
          bookingsNotGroupTepm.add(groupBooking);
        } else {
          bookingsNotGroupTepm.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      bookings.addAll(bookingsNotGroupTepm);
      sortDate();
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

  void sortDate() {
    if (stastus == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN)) {
      bookings.sort(((a, b) => a.inDate!.compareTo(b.inDate!)));
    }
    if (stastus == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT)) {
      bookings.sort(((a, b) => a.outDate!.compareTo(b.outDate!)));
    }
    if (stastus == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)) {
      bookings.sort(((a, b) => a.created!.compareTo(b.created!)));
    }
  }

  String getStatus() {
    if (stastus == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT)) {
      return "out_date";
    }
    if (stastus == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)) {
      return "created";
    }
    return "in_date";
  }

  void setStatus(String value) {
    if (stastus == value) return;
    stastus = value;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    startDate = DateUtil.to0h(now!);
    endDate = DateUtil.to24h(now!);
    if (startDate!.isAtSameMomentAs(newStart)) {
      return;
    }
    startDate = newStart;
    if (startDate!.isAfter(endDate!)) {
      endDate = DateUtil.to24h(startDate!);
    } else if (endDate!.difference(startDate!).inDays > 30) {
      endDate = DateUtil.to24h(startDate!.add(const Duration(days: 30)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    DateTime newEnd = DateUtil.to24h(date);
    if (endDate!.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate!)) {
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
