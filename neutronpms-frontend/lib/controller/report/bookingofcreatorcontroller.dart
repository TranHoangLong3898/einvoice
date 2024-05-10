import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/status.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/usermanager.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class BookingOfCreatorController extends ChangeNotifier {
  DateTime? now, startDate, endDate;
  final int pageSize = 10;
  bool? isLoading, forward;
  Query? nextQuery, preQuery;
  QuerySnapshot? snapshotTepm;
  List<Booking> bookings = [];
  List<Booking> bookingsNotGroupTepm = [];

  BookingOfCreatorController() {
    isLoading = true;
    now = DateTime.now();
    startDate = DateUtil.to0h(now!);
    endDate = DateUtil.to24h(now!);
    loadBooking();
  }

  Query getInitQuery() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('creator', isEqualTo: UserManager.user!.email)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .orderBy('created');
  }

  Future<void> loadBooking() async {
    isLoading = true;
    notifyListeners();
    await getInitQuery().limit(pageSize).get().then((snapshots) {
      updateBookingAndQueries(snapshots);
    });
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

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
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
    await nextQuery!.get().then((snapshots) {
      updateBookingAndQueries(snapshots);
    });
  }

  void getAccountingPreviousPage() async {
    if (preQuery == null) return;
    forward = false;
    isLoading = true;
    notifyListeners();
    await preQuery!.get().then((snapshots) {
      updateBookingAndQueries(snapshots);
    });
  }

  void getAccountingLastPage() async {
    isLoading = true;
    notifyListeners();
    await getInitQuery().limitToLast(pageSize).get().then((snapshots) {
      updateBookingAndQueries(snapshots);
      nextQuery = null;
    });
  }

  void getAccountingFirstPage() async {
    isLoading = true;
    notifyListeners();
    await getInitQuery().limit(pageSize).get().then((snapshots) {
      updateBookingAndQueries(snapshots);
      preQuery = null;
    });
  }

  String getStatusByBookingStatus(int status) {
    if (status == BookingStatus.unconfirmed) {
      return UITitleUtil.getTitleByCode(UITitleCode.STATUSNAME_UNCONFIRMED);
    }
    return "";
  }
}
