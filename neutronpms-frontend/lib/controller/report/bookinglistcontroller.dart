import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../manager/roommanager.dart';
import '../../manager/roomtypemanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';

class BookingListType {
  static const inToday = 0;
  static const outToday = 1;
  static const stayToday = 2;
  static const nonRoom = 3;
  static const nonSource = 4;
}

class BookingListController extends ChangeNotifier {
  DateTime? startDate, endDate;
  DateTime now = DateTime.now();
  late int type;
  bool isInitQueryBasicBookings = false;
  List<Booking> bookings = [];
  List<Booking> bookingsNotGroupTepm = [];
  List<Booking> bookingsGroupTepm = [];
  StreamSubscription? subscription;
  StreamSubscription? subscriptionGroup;
  bool isLoading = false;
  bool isShowNote = false;
  Map<String, String>? mapBreakFast = {};
  Map<String, String> mapNotes = {};
  List<Map<String, Map<String, int>>> breakFast = [];
  List<Map<String, dynamic>> listRoomType = [];
  String statusBreakFast = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  bool? isBreakFast;
  List<String> listBreakFast = [
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
    UITitleUtil.getTitleByCode(UITitleCode.YES),
    UITitleUtil.getTitleByCode(UITitleCode.NO)
  ];
  //false = get all bookings, true = only get bookings with tax_declare = true
  bool isFilter = false;
  int pageSize = 10;

  /// Được sử dụng cho phân trang ở [BookingListController]
  late int startIndex;

  /// Được sử dụng cho phân trang ở [BookingListController]
  late int endIndex;

  /// Được sử dụng cho phân trang
  int? currentPage;

  BookingListController(this.type) {
    startDate = DateUtil.to0h(now);
    endDate = type == BookingListType.stayToday
        ? startDate!.add(const Duration(days: 7))
        : DateUtil.to12h(now);
    loadDataBooking();
  }

  CollectionReference<Map<String, dynamic>> getInitColectionBookings() {
    return FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBookings);
  }

  Stream? loadBookingNonRomandSource(int type) {
    Stream? collectionStream;
    if (type == BookingListType.nonRoom) {
      collectionStream = getInitColectionBookings()
          .where('group', isEqualTo: false)
          .where('room', isEqualTo: '')
          .where('status', isEqualTo: BookingStatus.booked)
          .snapshots();
    } else if (type == BookingListType.nonSource) {
      collectionStream = getInitColectionBookings()
          .where('group', isEqualTo: false)
          .where('source', isEqualTo: SourceManager.noneSourceId)
          .where('status', whereIn: [
        BookingStatus.booked,
        BookingStatus.checkin
      ]).snapshots();
    }
    return collectionStream;
  }

  Query? loadBookingInOutStaying(int type) {
    Query? queryData;
    if (type == BookingListType.inToday) {
      queryData = getInitColectionBookings()
          .where('in_date', isGreaterThanOrEqualTo: startDate)
          .where('in_date', isLessThanOrEqualTo: endDate)
          .where('status', isEqualTo: BookingStatus.booked)
          .orderBy("in_date");
    } else if (type == BookingListType.outToday) {
      queryData = getInitColectionBookings()
          .where('out_date', isGreaterThanOrEqualTo: startDate)
          .where('out_date', isLessThanOrEqualTo: endDate)
          .where('status', whereIn: [
        BookingStatus.booked,
        BookingStatus.checkin
      ]).orderBy("out_date");
    } else if (type == BookingListType.stayToday) {
      queryData = getInitColectionBookings()
          .where('out_date', isGreaterThanOrEqualTo: startDate)
          .where('out_date', isLessThanOrEqualTo: endDate)
          .where('status', isEqualTo: BookingStatus.checkin)
          .orderBy("out_date");
    }
    return queryData;
  }

  void loadDataBooking() async {
    isLoading = true;
    notifyListeners();
    //trường hợp nonroom and nonsource
    subscription?.cancel();
    subscription = chekNoRoomAndSource()
        ? loadBookingNonRomandSource(type)!
            .listen((event) => updateBookingsAndQueries(event))
        //trường hợp in out staying
        : loadBookingInOutStaying(type)!
            .snapshots()
            .listen((event) => updateBookingsAndQueries(event));
  }

  void updateBookingsAndQueries(QuerySnapshot querySnapshot) {
    bookings.clear();
    bookingsNotGroupTepm.clear();
    breakFast.clear();
    listRoomType.clear();
    mapBreakFast!.clear();
    mapNotes.clear();
    breakFast.clear();
    initializePageIndex();
    print("asyncListBookings: type - $type");
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        if (doc.get("source") == "virtual" &&
            (type == BookingListType.inToday ||
                type == BookingListType.outToday)) continue;
        if (doc.get('group')) {
          final Booking groupBooking = Booking.groupFromSnapshot(doc);
          String room = ' ';
          num amoutGuest = 0;
          int lengthStay = 0;
          for (var subBooking in groupBooking.subBookings!.entries) {
            switch (type) {
              case BookingListType.inToday:
                room +=
                    '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
                amoutGuest +=
                    (subBooking.value['adult'] + subBooking.value['child']);
                getBreakFastGroupandTypeRoom(doc.get('sid'), subBooking);
                break;
              case BookingListType.outToday:
                room +=
                    '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
                amoutGuest +=
                    (subBooking.value['adult'] + subBooking.value['child']);
                getBreakFastGroupandTypeRoom(doc.get('sid'), subBooking);
                break;
              case BookingListType.stayToday:
                if (subBooking.value['status'] == BookingStatus.checkin) {
                  if (isBreakFast != null) {
                    if (subBooking.value['breakfast'] == isBreakFast) {
                      room +=
                          '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
                      amoutGuest += (subBooking.value['adult'] +
                          subBooking.value['child']);
                      getBreakFastGroupandTypeRoom(doc.get('sid'), subBooking);
                    }
                  } else {
                    room +=
                        '${RoomManager().getNameRoomById(subBooking.value['room'])}, ';
                    amoutGuest +=
                        (subBooking.value['adult'] + subBooking.value['child']);
                    getBreakFastGroupandTypeRoom(doc.get('sid'), subBooking);
                  }
                }
                break;
            }
            getNotesBooking(
                Booking.fromBookingParent(subBooking.key, groupBooking));
            lengthStay += (subBooking.value['out_date'] as Timestamp)
                .toDate()
                .difference((subBooking.value['in_date'] as Timestamp).toDate())
                .inDays;
          }
          getListBreakFastorGroup(doc.get('sid'));
          groupBooking.lengthStay = lengthStay;
          groupBooking.room = room;
          groupBooking.roomTypeID = getListRoomTypeForGroup(doc.get('sid'));
          groupBooking.adult = amoutGuest;
          if (mapBreakFast![doc.get("sid")] != null) {
            bookingsNotGroupTepm.add(groupBooking);
          }
        } else {
          getNotesBooking(Booking.fromSnapshot(doc));
          isBreakFast != null
              ? doc.get('breakfast') == isBreakFast
                  ? bookingsNotGroupTepm.add(Booking.fromSnapshot(doc))
                  : ""
              : bookingsNotGroupTepm.add(Booking.fromSnapshot(doc));
        }
      }
      bookings.addAll(bookingsNotGroupTepm);
    }
    initializePageIndex();
    if (chekNoRoomAndSource()) {
      initQueryWithBookingGroup(type);
    }
    isLoading = false;
    notifyListeners();
  }

  void cancelStream() {
    if (subscription != null) {
      subscription!.cancel();
    }
    if (subscriptionGroup != null) {
      subscriptionGroup!.cancel();
    }
  }

  Future<void> initQueryWithBookingGroup(int type) async {
    if (isInitQueryBasicBookings) {
      bookings.addAll(bookingsGroupTepm);
      isLoading = false;
      notifyListeners();
      return;
    }
    isInitQueryBasicBookings = true;
    Query? queryBasicBookings;
    if (type == BookingListType.nonRoom) {
      queryBasicBookings = FirebaseFirestore.instance
          .collection('hotels')
          .doc(GeneralManager.hotelID)
          .collection(FirebaseHandler.colBasicBookings)
          .where('group', isEqualTo: true)
          .where('room', isEqualTo: '')
          .where('status', isEqualTo: BookingStatus.booked);
    } else if (type == BookingListType.nonSource) {
      queryBasicBookings = FirebaseFirestore.instance
          .collection('hotels')
          .doc(GeneralManager.hotelID)
          .collection(FirebaseHandler.colBasicBookings)
          .where('group', isEqualTo: true)
          .where('source', isEqualTo: SourceManager.noneSourceId)
          .where('status',
              whereIn: [BookingStatus.booked, BookingStatus.checkin]);
    }

    subscriptionGroup?.cancel();
    subscriptionGroup =
        queryBasicBookings!.snapshots().listen((basicBookingsDocs) async {
      bookings.clear();
      bookings.addAll(bookingsNotGroupTepm);
      bookingsGroupTepm.clear();
      if (basicBookingsDocs.docs.isNotEmpty) {
        for (var doc in basicBookingsDocs.docs) {
          bookingsGroupTepm.add(Booking.fromSnapshot(doc));
        }
        bookings.addAll(bookingsGroupTepm);
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  String getTitle() {
    if (type == BookingListType.inToday) {
      return UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_CHECKING_IN_TODAY);
    } else if (type == BookingListType.outToday) {
      return UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_CHECKING_OUT_TODAY);
    } else if (type == BookingListType.stayToday) {
      return UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_STAYING_TODAY);
    } else if (type == BookingListType.nonRoom) {
      return UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_NON_ROOM_BOOKINGS);
    } else if (type == BookingListType.nonSource) {
      return UITitleUtil.getTitleByCode(
          UITitleCode.SIDEBAR_NON_SOURCE_BOOKINGS);
    }
    return '';
  }

  void setFilter() {
    isFilter = !isFilter;
    notifyListeners();
  }

  List<Booking>? getBookingsByFilter() {
    print(chekNoRoomAndSource());
    return chekNoRoomAndSource()
        ? bookings
            .where((element) => !isFilter || element.isTaxDeclare == true)
            .toList()
        : bookings
            .sublist(startIndex, endIndex)
            .where((element) => !isFilter || element.isTaxDeclare == true)
            .toList();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate!)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate!.compareTo(startDate!) < 0) {
      endDate = DateUtil.to12h(startDate!);
    }
    if (endDate!.difference(startDate!) > const Duration(days: 7)) {
      endDate = DateUtil.to24h(startDate!.add(const Duration(days: 7)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate!)) return;
    newDate = DateUtil.to12h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  bool chekNoRoomAndSource() {
    return type == BookingListType.nonRoom || type == BookingListType.nonSource;
  }

  Future<List<Booking>> exportToExcel() async {
    return bookings
        .where((element) => !isFilter || element.isTaxDeclare == true)
        .toList();
  }

  get getLengthBookings => bookings
      .where((element) => !isFilter || element.isTaxDeclare == true)
      .length;

  String getListRoomTypeForGroup(String sid) {
    String descRoomType = "";
    Map<String, String> groupedMap = {};
    for (var map in listRoomType) {
      String name = map[sid] ?? "";
      groupedMap[name] = groupedMap.containsKey(name) ? name : name;
    }
    // In danh sách đã gộp
    for (var entry in groupedMap.entries) {
      // ignore: unnecessary_null_comparison
      if (entry.key == null) continue;
      descRoomType += "${entry.key}, ";
    }
    return descRoomType;
  }

  void getListBreakFastorGroup(String sid) {
    String descBreakFast = "";
    Map<String, int> groupedMap = {};
    for (var map in breakFast) {
      if (map[sid] == null) continue;
      for (var element in map[sid]!.entries) {
        if (groupedMap.containsKey(element.key)) {
          groupedMap[element.key] = groupedMap[element.key]! + element.value;
        } else {
          groupedMap[element.key] = element.value;
        }
      }
    }
    // In danh sách đã gộp
    for (var entry in groupedMap.entries) {
      descBreakFast += "${entry.key}(${entry.value}), ";
      mapBreakFast![sid] = descBreakFast;
    }
  }

  void getBreakFastGroupandTypeRoom(
      String sid, MapEntry<String, dynamic> data) {
    listRoomType.add(
        {sid: RoomTypeManager().getRoomTypeNameByID(data.value['room_type'])});
    breakFast.add({
      sid: {
        data.value['breakfast']
            ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YES)
            : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NO): 1
      }
    });
  }

  void setStatusBreakFast(value) {
    if (statusBreakFast == value) return;
    statusBreakFast = value;
    isBreakFast =
        statusBreakFast != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
            ? statusBreakFast == UITitleUtil.getTitleByCode(UITitleCode.YES)
            : null;
    notifyListeners();
  }

  void getBookingsPreviousPage() async {
    if (currentPage! <= 1) return;
    currentPage = currentPage! - 1;
    startIndex = startIndex - pageSize;
    endIndex = startIndex + pageSize;
    notifyListeners();
  }

  void getBookingsNextPage() async {
    if (currentPage! * pageSize >= getLengthBookings) return;
    currentPage = currentPage! + 1;
    startIndex = (currentPage! - 1) * pageSize;
    if (getLengthBookings >= currentPage! * pageSize) {
      endIndex = currentPage! * pageSize;
    } else {
      endIndex = getLengthBookings;
    }
    notifyListeners();
  }

  void initializePageIndex() {
    currentPage = 1;
    startIndex = 0;
    if (getLengthBookings < pageSize) {
      endIndex = getLengthBookings;
    } else {
      endIndex = pageSize;
    }
  }

  void getNotesBooking(Booking bookings) async {
    mapNotes[bookings.sID!] = (await bookings.getNotes())!;
    notifyListeners();
  }

  void onChange(bool newValue) {
    isShowNote = !newValue;
    notifyListeners();
  }
}
