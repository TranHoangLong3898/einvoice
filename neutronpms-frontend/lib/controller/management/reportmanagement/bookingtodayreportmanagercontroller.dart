// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../handler/firebasehandler.dart';
import '../../../manager/generalmanager.dart';
import '../../../manager/roomtypemanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../util/dateutil.dart';

class BookingToDayReportManagementController extends ChangeNotifier {
  DateTime? staysDate = DateTime.now();
  List<Booking> bookings = [];
  List<Booking> bookingGroupTemp = [];
  List<Map<String, dynamic>> listRoomType = [];
  Map<String, String> mapNoteBooking = {};
  List<String> setListSid = [];
  StreamSubscription? subscription;
  bool isLoading = false;
  bool isShowNote = false;

  int pageSize = 10;

  /// Được sử dụng cho phân trang ở [BookingToDayReportManagementController]
  late int startIndex;

  /// Được sử dụng cho phân trang ở [BookingToDayReportManagementController]
  late int endIndex;

  /// Được sử dụng cho phân trang
  late int currentPage;

  BookingToDayReportManagementController() {
    staysDate = DateUtil.to12h(Timestamp.now().toDate());
    loadDataBooking();
  }

  Query loadBookingOutInStaying() {
    return FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContains: staysDate)
        .where('status', whereIn: [
      BookingStatus.booked,
      BookingStatus.checkin,
      BookingStatus.checkout,
    ]).orderBy('stay_days');
    // .orderBy('status', descending: true)
  }

  void loadDataBooking() async {
    isLoading = true;
    notifyListeners();
    subscription?.cancel();
    subscription = loadBookingOutInStaying().snapshots().listen((event) async {
      mapNoteBooking.clear();
      bookings.clear();
      bookingGroupTemp.clear();
      setListSid.clear();
      listRoomType.clear();
      for (var element in event.docs) {
        if (element.exists) {
          final data = (element.data() as Map<String, dynamic>);
          setListSid.add(element.get("sid"));
          mapNoteBooking[element.get("sid")] =
              data.containsKey('notes') ? element.get('notes') : '';
        }
      }
      for (var element in setListSid.toSet()) {
        await getBookingBySid(element);
      }
      initializePageIndex();
      isLoading = false;
      notifyListeners();
    });
  }

  void setDate(DateTime newDate) {
    if (staysDate != null && DateUtil.equal(staysDate!, newDate)) return;
    staysDate = DateUtil.to12h(newDate);
    bookings.clear();
    bookingGroupTemp.clear();
    setListSid.clear();
    listRoomType.clear();
    loadDataBooking();
  }

  void getBookingsPreviousPage() async {
    if (currentPage <= 1) return;
    currentPage--;
    startIndex = startIndex - pageSize;
    endIndex = startIndex + pageSize;
    notifyListeners();
  }

  void getBookingsNextPage() async {
    if (currentPage * pageSize >= bookings.length) return;
    currentPage++;
    startIndex = (currentPage - 1) * pageSize;
    if (bookings.length >= currentPage * pageSize) {
      endIndex = currentPage * pageSize;
    } else {
      endIndex = bookings.length;
    }
    notifyListeners();
  }

  void initializePageIndex() {
    currentPage = 1;
    startIndex = 0;
    if (bookings.length < pageSize) {
      endIndex = bookings.length;
    } else {
      endIndex = pageSize;
    }
  }

  void cancelStream() {
    subscription?.cancel();
    bookings.clear();
  }

  num getAllRevenueOfBooking() {
    num totalRevenue = 0;
    for (var element in bookings) {
      totalRevenue += element.getRevenue();
    }
    return totalRevenue;
  }

  num getAverageRoomPriceBooking() {
    num totalAverageRoomPrice = 0;
    for (var booking in bookings) {
      totalAverageRoomPrice +=
          (booking.getRoomCharge() / booking.lengthStay!).round();
    }
    return totalAverageRoomPrice;
  }

  Future<List<Booking>> exportToExcel() async {
    List<Booking> bookingExport = [];
    await loadBookingOutInStaying().get().then((snapshot) {
      for (var booking in snapshot.docs) {
        bookingExport.add(Booking.fromSnapshot(booking));
      }
    });
    if (bookingExport.isEmpty) return [];
    return bookingExport;
  }

  Future getBookingBySid(String sid) async {
    await FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBookings)
        .where('sid', isEqualTo: sid)
        .get()
        .then((querySnapshot) {
      int lengthStay = 0;
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        if (doc.get("source") == "virtual") continue;
        bookingGroupTemp.clear();
        if (doc.get('group')) {
          final Booking groupBooking =
              Booking.groupFromSnapshotOfBookingToday(doc);
          for (var subBooking in groupBooking.subBookings!.entries) {
            if (subBooking.value["status"] != BookingStatus.noshow &&
                subBooking.value["status"] != BookingStatus.cancel) {
              listRoomType.add({
                sid: RoomTypeManager()
                    .getRoomTypeNameByID(subBooking.value['room_type'])
              });
              lengthStay += (subBooking.value['out_date'] as Timestamp)
                  .toDate()
                  .difference(
                      (subBooking.value['in_date'] as Timestamp).toDate())
                  .inDays;
            }
          }
          groupBooking.lengthStay = lengthStay;
          groupBooking.roomTypeID = getListRoomTypeForGroup(sid);
          bookingGroupTemp.add(groupBooking);
        } else {
          bookingGroupTemp.add(Booking.fromSnapshot(doc));
        }
      }
      bookings.addAll(bookingGroupTemp);
    });
  }

  String getListRoomTypeForGroup(String sid) {
    String descRoomType = "";
    Map<String, String> groupedMap = {};
    for (var map in listRoomType) {
      String name = map[sid] ?? "";
      groupedMap[name] = groupedMap.containsKey(name) ? name : name;
    }
    // In danh sách đã gộp
    for (var entry in groupedMap.entries) {
      if (entry.key == null) continue;
      descRoomType += "${entry.key}, ";
    }
    return descRoomType;
  }

  void onChange(bool newValue) {
    isShowNote = !newValue;
    notifyListeners();
  }
}
