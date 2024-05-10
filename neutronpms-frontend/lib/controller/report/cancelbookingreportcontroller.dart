import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class CancelBookingReportController extends ChangeNotifier {
  int? maxTimePeriod;
  String source = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  DateTime? startDate, endDate;

  List<Booking> bookings = [];

  StreamSubscription? subscription;

  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward, isLoading = false;

  final int pageSize = 10;
  num roomChargeOfCurrentPage = 0;
  int? statusProgress;

  CancelBookingReportController(this.statusProgress) {
    DateTime now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    loadBasicBookings();
  }

  Query getInitQueryBasicBookingByCreatedRange() {
    Query queryFilter = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where('cancelled', isGreaterThanOrEqualTo: startDate)
        .where('cancelled', isLessThanOrEqualTo: endDate)
        .where('status', isEqualTo: statusProgress)
        .orderBy('cancelled');
    if (source != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryFilter = queryFilter.where('source', isEqualTo: source);
    }
    return queryFilter;
  }

  void loadBasicBookings() async {
    isLoading = true;
    notifyListeners();
    bookings.clear();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((snapshotsBooking) {
      updateBasicBookingsAndQueries(snapshotsBooking);
    });
  }

  void setSource(String value) {
    if (source == value) return;
    source = value == UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
        ? UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
        : SourceManager().getSourceIDByName(value);
    isLoading = true;
    notifyListeners();
    bookings.clear();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((snapshotsBooking) {
      updateBasicBookingsAndQueries(snapshotsBooking);
    });
  }

  void updateBasicBookingsAndQueries(QuerySnapshot snapshot) {
    if (snapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryBasicBookingByCreatedRange()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryBasicBookingByCreatedRange()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      bookings.clear();
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
          preQuery = getInitQueryBasicBookingByCreatedRange()
              .endBeforeDocument(snapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQueryBasicBookingByCreatedRange()
              .startAfterDocument(snapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQueryBasicBookingByCreatedRange()
            .startAfterDocument(snapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryBasicBookingByCreatedRange()
            .endBeforeDocument(snapshot.docs.first)
            .limitToLast(pageSize);
      }
    }

    if (bookings.isNotEmpty) {
      roomChargeOfCurrentPage = bookings.fold(0,
          (previousValue, element) => previousValue + element.getRoomCharge());
    } else {
      roomChargeOfCurrentPage = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate!)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate!.compareTo(startDate!) < 0) {
      endDate = DateUtil.to24h(startDate!);
    }
    if (endDate!.difference(startDate!) > Duration(days: maxTimePeriod!)) {
      endDate = DateUtil.to24h(startDate!.add(Duration(days: maxTimePeriod!)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate!)) return;
    newDate = DateUtil.to24h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  void getBasicBookingsNextPage() {
    if (nextQuery == null) return;
    isLoading = true;
    notifyListeners();
    forward = true;
    subscription?.cancel();
    subscription = nextQuery!.snapshots().listen((snapshot) {
      updateBasicBookingsAndQueries(snapshot);
    });
  }

  void getBasicBookingsPreviousPage() {
    if (preQuery == null) return;
    isLoading = true;
    notifyListeners();
    forward = false;
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((snapshot) {
      updateBasicBookingsAndQueries(snapshot);
    });
  }

  void getBasicBookingsLastPage() {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limitToLast(pageSize)
        .snapshots()
        .listen((value) {
      updateBasicBookingsAndQueries(value);
      nextQuery = null;
    });
  }

  void getBasicBookingsFirstPage() {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((value) {
      updateBasicBookingsAndQueries(value);
      preQuery = null;
    });
  }

  void cancelStream() {
    subscription?.cancel();
    bookings.clear();
  }
}
