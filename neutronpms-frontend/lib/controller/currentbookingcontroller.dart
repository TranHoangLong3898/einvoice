import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import '../handler/firebasehandler.dart';
import '../manager/generalmanager.dart';
import '../manager/roommanager.dart';
import '../modal/booking.dart';
import '../modal/coordinate.dart';
import '../modal/status.dart';
import '../util/dateutil.dart';

class CurrentBookingsController extends ChangeNotifier {
  static final CurrentBookingsController _instance =
      CurrentBookingsController._singleton();
  CurrentBookingsController._singleton();

  List<Booking> bookings = [];
  List<Booking> bookingsOf7Day = [];
  List<Booking> bookingsOf15Day = [];
  List<Booking> bookingsOf25Day = [];
  List<Booking> bookingsOf30Day = [];
  StreamSubscription? bookingSubscription,
      bookingSubscription15Day,
      bookingSubscription25Day,
      bookingSubscription30Day;
  DateTime? currentDate, currentDate15Day, currentDate25Day, currentDate30Day;

  factory CurrentBookingsController() {
    return _instance;
  }

  void init() {
    currentDate = DateUtil.to12h(
        Timestamp.now().toDate().subtract(const Duration(days: 1)));
    asyncBookingsWithCloud();
  }

  void asyncBookingsWithCloud() {
    bookingSubscription?.cancel();
    print('asyncBookingsWithCloud: Init');
    List<DateTime> lstDates =
        List.generate(8, (index) => currentDate!.add(Duration(days: index)));
    DailyAllotmentStatic().listenDailyAllotmentFromCloud(currentDate!);
    Stream stream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where("stay_days", arrayContainsAny: lstDates)
        .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
        .orderBy('status', descending: true)
        .snapshots();
    bookingSubscription = stream.listen((snapshots) {
      if (bookingsOf7Day.isNotEmpty) {
        for (var booking in bookingsOf7Day) {
          bookings.removeWhere((element) => element.id == booking.id);
        }
      }
      print(
          "asyncBookingsWithCloud: Run ${DateUtil.dateToString(currentDate!)}");
      bookingsOf7Day.clear();
      for (var doc in snapshots.docs) {
        bookingsOf7Day.add(Booking.basicFromSnapshot(doc));
      }
      combineAllBookings();
      notifyListeners();
    });
  }

  Future<void> getAsyncBookingsWithCloudOf15Day() async {
    bookingSubscription15Day?.cancel();
    currentDate15Day = DateUtil.to12h(
        DateTime(currentDate!.year, currentDate!.month, currentDate!.day + 8));

    List<DateTime> lstDates = List.generate(
        8, (index) => currentDate15Day!.add(Duration(days: index)));
    DailyAllotmentStatic().listenDailyAllotmentFromCloud(currentDate15Day!);
    Stream stream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where("stay_days", arrayContainsAny: lstDates)
        .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
        .orderBy('status', descending: true)
        .snapshots();
    bookingSubscription15Day = stream.listen((snapshots) {
      if (bookingsOf15Day.isNotEmpty) {
        for (var booking in bookingsOf15Day) {
          bookings.removeWhere((element) => element.id == booking.id);
        }
      }
      print(
          "asyncBookingsWithCloud15Day: Run ${DateUtil.dateToString(currentDate15Day!)} - ${lstDates.last}");
      bookingsOf15Day.clear();
      for (var doc in snapshots.docs) {
        bookingsOf15Day.add(Booking.basicFromSnapshot(doc));
      }
      combineAllBookings();
      notifyListeners();
    });
  }

  Future<void> getAsyncBookingsWithCloudOf25Day() async {
    bookingSubscription25Day?.cancel();
    currentDate25Day = DateUtil.to12h(
        DateTime(currentDate!.year, currentDate!.month, currentDate!.day + 16));
    List<DateTime> lstDates = List.generate(
        10, (index) => currentDate25Day!.add(Duration(days: index)));
    DailyAllotmentStatic().listenDailyAllotmentFromCloud(currentDate25Day!);
    Stream stream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where("stay_days", arrayContainsAny: lstDates)
        .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
        .orderBy('status', descending: true)
        .snapshots();
    bookingSubscription25Day = stream.listen((snapshots) async {
      if (bookingsOf25Day.isNotEmpty) {
        for (var booking in bookingsOf25Day) {
          bookings.removeWhere((element) => element.id == booking.id);
        }
      }
      print(
          "asyncBookingsWithCloud30Day: Run ${DateUtil.dateToString(currentDate25Day!)} - ${lstDates.last}");
      bookingsOf25Day.clear();
      for (var doc in snapshots.docs) {
        bookingsOf25Day.add(Booking.basicFromSnapshot(doc));
      }
      combineAllBookings();
      notifyListeners();
    });
  }

  Future<void> getAsyncBookingsWithCloud30Day() async {
    bookingSubscription30Day?.cancel();
    currentDate30Day = DateUtil.to12h(
        DateTime(currentDate!.year, currentDate!.month, currentDate!.day + 26));

    List<DateTime> lstDates5Day = List.generate(
        5, (index) => currentDate30Day!.add(Duration(days: index)));
    DailyAllotmentStatic().listenDailyAllotmentFromCloud(currentDate30Day!);
    Stream stream5Of30Day = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where("stay_days", arrayContainsAny: lstDates5Day)
        .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
        .orderBy('status', descending: true)
        .snapshots();
    bookingSubscription30Day = stream5Of30Day.listen((snapshots) {
      if (bookingsOf30Day.isNotEmpty) {
        for (var booking in bookingsOf30Day) {
          bookings.removeWhere((element) => element.id == booking.id);
        }
      }
      print(
          "asyncBookingsWithCloud5OF30Day: Run ${DateUtil.dateToString(currentDate30Day!)} - ${lstDates5Day.last}");
      bookingsOf30Day.clear();
      for (var doc in snapshots.docs) {
        bookingsOf30Day.add(Booking.basicFromSnapshot(doc));
      }
      combineAllBookings();
      notifyListeners();
    });
  }

  Future combineAllBookings() async {
    bookings.clear();
    if (bookingsOf7Day.isNotEmpty) {
      bookings.addAll(bookingsOf7Day);
    }
    if (bookingsOf15Day.isNotEmpty) {
      bookings.addAll(bookingsOf15Day);
    }
    if (bookingsOf25Day.isNotEmpty) {
      bookings.addAll(bookingsOf25Day);
    }
    if (bookingsOf30Day.isNotEmpty) {
      bookings.addAll(bookingsOf30Day);
    }
    // print("${bookings.length} ------------ $bookings");
    notifyListeners();
  }

  void cancelStream() {
    bookingSubscription?.cancel();
    bookingSubscription15Day?.cancel();
    bookingSubscription25Day?.cancel();
    bookingSubscription30Day?.cancel();
    bookings.clear();
    bookingsOf7Day.clear();
    bookingsOf15Day.clear();
    bookingsOf25Day.clear();
    bookingsOf30Day.clear();
    print('asyncBookingsWithCloud: Cancelled');
  }

  //return coordinate of booking object
  Coordinate? getBookingCoordinate(Booking booking) {
    if (booking.room == '' ||
        RoomManager()
                .rooms!
                .indexWhere((element) => element.id == booking.room) ==
            -1) return null;
    DateTime inTime = ((GeneralManager.hotel!.hourBookingMonthly ==
                BookingInOutByHour.monthly) &&
            booking.bookingType == BookingType.monthly)
        ? DateTime(booking.inTime!.year, booking.inTime!.month,
            booking.inTime!.day, 00)
        : booking.inTime!;
    DateTime outTime = ((GeneralManager.hotel!.hourBookingMonthly ==
                BookingInOutByHour.monthly) &&
            booking.bookingType == BookingType.monthly)
        ? DateTime(booking.outTime!.year, booking.outTime!.month,
            booking.outTime!.day, 23, 59)
        : booking.outTime!;

    //real stayday of booking
    final stayDays = List.generate(booking.lengthStay!,
        (index) => booking.inDate!.add(Duration(days: index)));

    //stayDaysInView to display on screen
    final stayDaysInView = stayDays.where((stayday) =>
        stayday.compareTo(currentDate!) >= 0 &&
        stayday.compareTo(currentDate!
                .add(Duration(days: GeneralManager.sizeDatesForBoard + 1))) <
            0);

    //if stayDaysInView null -> not display -> return null
    if (stayDaysInView.isEmpty) return null;
    //horizontal index
    double bookingIndex =
        stayDaysInView.first.difference(currentDate!).inDays.toDouble();
    double lengthRender = stayDaysInView.length.toDouble();

    lengthRender += outTime
            .difference(stayDaysInView.last.add(const Duration(days: 1)))
            .inSeconds /
        (24 * 60 * 60);

    lengthRender -= inTime.difference(stayDaysInView.first).inMilliseconds /
        (24 * 60 * 60 * 1000);

    bookingIndex += inTime.difference(stayDaysInView.first).inMilliseconds /
        (24 * 60 * 60 * 1000);

    if (bookingIndex < 0) {
      lengthRender += bookingIndex;
      bookingIndex = 0;
    }
    if (bookingIndex + lengthRender > (GeneralManager.sizeDatesForBoard + 1)) {
      lengthRender -=
          bookingIndex + lengthRender - (GeneralManager.sizeDatesForBoard + 1);
    }
    if (lengthRender <= 0) return null;

    if (lengthRender < 0.2) lengthRender = 0.2;

    List<String?> roomTypeList = RoomTypeManager().getRoomTypeIDsActived();
    roomTypeList = roomTypeList
        .where((roomTypeId) =>
            RoomManager().getRoomIDsByType(roomTypeId!).isNotEmpty)
        .toList();
    int countRoomType = roomTypeList.indexOf(booking.roomTypeID) + 1;
    return Coordinate(
        left: (bookingIndex + 1) * GeneralManager.cellWidth,
        top: (RoomManager().getRoomIDsPlus().indexOf(booking.room) -
                    countRoomType) *
                GeneralManager.cellHeight +
            countRoomType * GeneralManager.roomTypeCellHeight,
        length: lengthRender * GeneralManager.cellWidth);
  }

  void setDate(DateTime date) {
    date = DateUtil.to12h(date);
    if (date.compareTo(currentDate!) == 0) return;

    final now12h = DateUtil.to12h(Timestamp.now().toDate());
    final lastDate =
        now12h.add(Duration(days: 500 - GeneralManager.sizeDatesForBoard));
    if (date.compareTo(lastDate) > 0) date = lastDate;

    currentDate = date;
    cancelStream();

    asyncBookingsWithCloud();
    if (GeneralManager.sizeDatesForBoard == 15) {
      getAsyncBookingsWithCloudOf15Day();
    }
    if (GeneralManager.sizeDatesForBoard == 30) {
      getAsyncBookingsWithCloudOf15Day();
      getAsyncBookingsWithCloudOf25Day();
      getAsyncBookingsWithCloud30Day();
    }
  }

  void toggleFilterBooking() {
    GeneralManager.isFilterTaxDeclare = !GeneralManager.isFilterTaxDeclare;
    notifyListeners();
    GeneralManager().saveFilterTaxDeclareToLocal();
  }
}
