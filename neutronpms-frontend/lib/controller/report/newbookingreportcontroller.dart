import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/modal/status.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class NewBookingReportController extends ChangeNotifier {
  late int maxTimePeriod;
  String statusSource = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  late DateTime startDate, endDate;

  List<Booking> bookings = [];
  Map<String, String> mapNotes = {};
  bool isShowNote = false;

  StreamSubscription? subscription, subscriptionLengthStayAndRoomCharge;

  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward, isLoading = false;

  final int pageSize = 10;
  num lengthStay = 0,
      roomCharge = 0,
      roomChargeOfCurrentPage = 0,
      totalLengthStayOnPage = 0;

  NewBookingReportController() {
    DateTime now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    maxTimePeriod = GeneralManager.hotel!.isProPackage() ? 30 : 7;
    loadBasicBookings();
  }

  Query getInitQueryBasicBookingByCreatedRange() {
    Query queryFilter = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .where('virtual', isEqualTo: false)
        .orderBy('created')
        .where('status', whereIn: [
      BookingStatus.booked,
      BookingStatus.checkin,
      BookingStatus.checkout,
      BookingStatus.unconfirmed,
    ]);
    if (statusSource != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      queryFilter = queryFilter.where('source', isEqualTo: statusSource);
    }
    return queryFilter;
  }

  num getAverageRoomRate(Booking booking) =>
      (booking.getRoomCharge() / booking.lengthStay!).round();

  void loadBasicBookings() async {
    isLoading = true;
    notifyListeners();
    getTotalLengthStayAndTotalRoomCharge();
    bookings.clear();
    mapNotes.clear();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((snapshotsBooking) {
      updateBasicBookingsAndQueries(snapshotsBooking);
    });
  }

  void setsetStatusSource(String value) {
    if (statusSource == value) return;
    statusSource = value == UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
        ? UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
        : SourceManager().getSourceIDByName(value);
    isLoading = true;
    notifyListeners();
    getTotalLengthStayAndTotalRoomCharge();
    bookings.clear();
    mapNotes.clear();
    subscription?.cancel();
    subscription = getInitQueryBasicBookingByCreatedRange()
        .limit(pageSize)
        .snapshots()
        .listen((snapshotsBooking) {
      updateBasicBookingsAndQueries(snapshotsBooking);
    });
  }

  void getTotalLengthStayAndTotalRoomCharge() async {
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    if (inMonthId == outMonthId) {
      subscriptionLengthStayAndRoomCharge?.cancel();
      subscriptionLengthStayAndRoomCharge = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .doc(inMonthId)
          .snapshots()
          .listen((snapshotsDaily) {
        if (snapshotsDaily.exists) {
          final result =
              getTotalMoneyFromSnapshot(snapshotsDaily, inDay, outDay);
          lengthStay = result[0];
          roomCharge = result[1];
        } else {
          lengthStay = 0;
          roomCharge = 0;
        }
      });
    } else {
      subscriptionLengthStayAndRoomCharge?.cancel();
      subscriptionLengthStayAndRoomCharge = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .where(FieldPath.documentId, whereIn: [inMonthId, outMonthId])
          .snapshots()
          .listen((snapshots) {
            num roomChargeTepm = 0;
            num lengthStayTepm = 0;
            if (snapshots.docs.first.exists) {
              final resultOne =
                  getTotalMoneyFromSnapshot(snapshots.docs.first, inDay, '');
              lengthStay = resultOne[0];
              roomCharge = resultOne[1];
            }
            if (snapshots.docs.last.exists) {
              final resultTwo =
                  getTotalMoneyFromSnapshot(snapshots.docs.last, '', outDay);
              lengthStay += resultTwo[0];
              roomCharge += resultTwo[1];
            } else {
              roomCharge = roomChargeTepm;
              lengthStay = lengthStayTepm;
            }
          });
    }
  }

  void updateBasicBookingsAndQueries(QuerySnapshot snapshot) {
    roomChargeOfCurrentPage = 0;
    totalLengthStayOnPage = 0;
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
      mapNotes.clear();
      snapshotTepm = snapshot;
      for (var booking in snapshot.docs) {
        if (booking.get('group')) {
          Booking bookingGroup = Booking.groupFromSnapshot(booking);
          int lengthStay = 0;
          for (var subBooking in bookingGroup.subBookings!.entries) {
            if (subBooking.value['status'] == BookingStatus.cancel ||
                subBooking.value['status'] == BookingStatus.noshow) {
              continue;
            }
            Booking subBookingTepm =
                Booking.fromBookingParent(subBooking.key, bookingGroup);
            lengthStay += subBookingTepm.lengthStay!;
            getNotesBooking(
                Booking.fromBookingParent(subBooking.key, bookingGroup));
          }
          bookingGroup.lengthStay = lengthStay;
          if (bookingGroup.lengthStay != 0) {
            bookings.add(bookingGroup);
          }
        } else {
          bookings.add(Booking.fromSnapshot(booking));
          getNotesBooking(Booking.fromSnapshot(booking));
        }
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

      totalLengthStayOnPage += bookings.fold(
          0,
          (previousValue, element) =>
              previousValue + (element.lengthStay ?? 0));
    }
    isLoading = false;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > Duration(days: maxTimePeriod)) {
      endDate = DateUtil.to24h(startDate.add(Duration(days: maxTimePeriod)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
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
    subscriptionLengthStayAndRoomCharge?.cancel();
    bookings.clear();
    mapNotes.clear();
  }

  List<num> getTotalMoneyFromSnapshot(
      DocumentSnapshot snapshot, String inDay, String outDay) {
    List<dynamic> newBookingsList = [];
    List<Map<String, dynamic>> roomTypeList = [];
    List<Map<String, dynamic>> sourceList = [];
    List<dynamic> dataOfMonth = [];
    List<num> result = [];
    final data = snapshot.get('data') as Map<String, dynamic>;
    if (outDay == '') {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) >= num.parse(inDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    } else if (inDay == '') {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) <= num.parse(outDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    } else {
      for (var keyOfData in data.keys) {
        if (num.parse(keyOfData) >= num.parse(inDay) &&
            num.parse(keyOfData) <= num.parse(outDay)) {
          dataOfMonth.add(data[keyOfData]);
        }
      }
    }

    for (var item in dataOfMonth) {
      if (item['new_booking'] != null) newBookingsList.add(item['new_booking']);
    }

    for (var doc in newBookingsList) {
      if (doc['pay_at_hotel'] != null) {
        roomTypeList.add(doc['pay_at_hotel']);
      }
      if (doc['prepaid'] != null) {
        roomTypeList.add(doc['prepaid']);
      }
    }

    for (var item in roomTypeList) {
      for (var element in item.values) {
        sourceList.add(element);
      }
    }

    result.add(sourceList.fold(
        0,
        (pre, value) =>
            pre +
            value.values.fold(0,
                (previousValue, element) => previousValue + element['num'])));

    result.add(sourceList.fold(
        0,
        (pre, value) =>
            pre +
            value.values.fold(
                0,
                (previousValue, element) =>
                    previousValue + element['room_charge'])));

    return result;
  }

  void getNotesBooking(Booking bookings) async {
    mapNotes[bookings.sID!] = (await bookings.getNotes())!;
    notifyListeners();
  }

  void onChange(bool newValue) {
    isShowNote = !newValue;
    notifyListeners();
  }

  String getStatusByBookingStatus(int status) {
    if (status == BookingStatus.unconfirmed) {
      return UITitleUtil.getTitleByCode(UITitleCode.STATUSNAME_UNCONFIRMED);
    }
    return "";
  }

  // Future<List<Booking>> getAllBookingForExporting() async {
  //   List<Booking> list = [];
  //   await getInitQueryBasicBookingByCreatedRange().get().then((value) {
  //     for (var booking in value.docs) {
  //       if (booking.get('group')) {
  //         Booking bookingGroup = Booking.groupFromSnapshot(booking);
  //         int lengthStay = 0;
  //         for (var subBooking in bookingGroup.subBookings!.entries) {
  //           if (subBooking.value['status'] == BookingStatus.cancel ||
  //               subBooking.value['status'] == BookingStatus.noshow) {
  //             continue;
  //           }
  //           Booking subBookingTepm =
  //               Booking.fromBookingParent(subBooking.key, bookingGroup);
  //           lengthStay += subBookingTepm.lengthStay!;
  //         }
  //         bookingGroup.lengthStay = lengthStay;
  //         if (bookingGroup.lengthStay != 0) {
  //           list.add(bookingGroup);
  //         }
  //       } else {
  //         list.add(Booking.fromSnapshot(booking));
  //       }
  //     }
  //   });
  //   notifyListeners();
  //   return list;
  // }
}
