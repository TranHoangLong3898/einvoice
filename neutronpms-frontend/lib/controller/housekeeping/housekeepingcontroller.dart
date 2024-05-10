import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../modal/booking.dart';
import '../../modal/room.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';
import '../../util/messageulti.dart';

class HouseKeepingPageController extends ChangeNotifier {
  late DateTime now;
  late DateTime dayInTime;
  List<Booking?> outBookings = [],
      inBookings = [],
      inForBookings = [],
      repairBookings = [];
  StreamSubscription? outBookingsSubscription;
  StreamSubscription? inBookingsSubscription;
  StreamSubscription? inForBookingsSubscription;
  StreamSubscription? repairBookingsSubscription;

  int sortType = RoomSortType.name;
  late bool vacantOvernight;
  final String _sharedReferenceKey = 'sort-room-type';

  HouseKeepingPageController() {
    vacantOvernight = GeneralManager.hotel!.vacantOvernight!;
    initialize();
  }

  void initialize() async {
    now = DateUtil.to12h(Timestamp.now().toDate());
    dayInTime = DateTime.now();
    var sharedReference = await SharedPreferences.getInstance();
    sortType = sharedReference.getInt(_sharedReferenceKey) ?? RoomSortType.name;
    // sortType = RoomSortType.status;
    asyncInTodayBookings();
    asyncOutTodayBookings();
    asyncRepairTodayBookings();
    asyncInTodayForBookings();
  }

  void asyncOutTodayBookings() {
    print('asyncOutTodayBookings: Init');
    Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream =
        FirebaseFirestore
            .instance
            .collection('hotels')
            .doc(GeneralManager.hotelID)
            .collection(FirebaseHandler.colBasicBookings)
            .where('status',
                whereIn: [BookingStatus.booked, BookingStatus.checkin])
            .where('out_date', isEqualTo: now)
            .snapshots();
    outBookingsSubscription = collectionStream.listen((snapshots) {
      print("asyncOutTodayBookings: Run");
      outBookings.clear();
      for (var doc in snapshots.docs) {
        outBookings.add(Booking.fromSnapshot(doc));
      }
      notifyListeners();
    }, onDone: () => print('asyncOutTodayBookings: Done'), cancelOnError: true);
  }

  void asyncInTodayForBookings() {
    print('asyncInForBookings: Init');
    Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream =
        FirebaseFirestore.instance
            .collection('hotels')
            .doc(GeneralManager.hotelID)
            .collection(FirebaseHandler.colBasicBookings)
            .where('status', isEqualTo: BookingStatus.checkin)
            .snapshots();
    inForBookingsSubscription = collectionStream.listen((snapshots) {
      print("asyncInForBookings: Run");
      inForBookings.clear();
      for (var doc in snapshots.docs) {
        inForBookings.add(Booking.fromSnapshot(doc));
      }
      notifyListeners();
    }, onDone: () => print('asyncInForBookings: Done'), cancelOnError: true);
  }

  void asyncInTodayBookings() {
    print('asyncInTodayBookings: Init');
    Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream =
        FirebaseFirestore.instance
            .collection('hotels')
            .doc(GeneralManager.hotelID)
            .collection(FirebaseHandler.colBasicBookings)
            .where('status', isEqualTo: BookingStatus.booked)
            .where('in_date', isEqualTo: now)
            .snapshots();
    inBookingsSubscription = collectionStream.listen((snapshots) {
      print("asyncInTodayBookings: Run");
      inBookings.clear();
      for (var doc in snapshots.docs) {
        inBookings.add(Booking.basicFromSnapshot(doc));
      }
      notifyListeners();
    }, onDone: () => print('asyncInTodayBookings: Done'), cancelOnError: true);
  }

  void asyncRepairTodayBookings() {
    print('asyncRepairTodayBookings: Init');
    Stream collectionStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBasicBookings)
        .where('status', isEqualTo: BookingStatus.repair)
        .where('stay_days', arrayContains: now)
        .snapshots();
    repairBookingsSubscription = collectionStream.listen((snapshots) {
      print("asyncRepairTodayBookings: Run");
      repairBookings.clear();
      for (var doc in snapshots.docs) {
        repairBookings.add(Booking.basicFromSnapshot(doc));
      }
      notifyListeners();
    },
        onDone: () => print('asyncRepairTodayBookings: Done'),
        cancelOnError: true);
  }

  void cancelStream() {
    outBookingsSubscription?.cancel();
    inBookingsSubscription?.cancel();
    repairBookingsSubscription?.cancel();
    inForBookingsSubscription?.cancel();
    outBookings.clear();
    inBookings.clear();
    repairBookings.clear();
    inForBookings.clear();
    print('asyncInTodayBookings: Cancelled');
    print('asyncOutTodayBookings: Cancelled');
    print('asyncRepairTodayBookings: Cancelled');
    print("asyncInForBookings: Cancelled");
  }

  String? getBed(String roomID) {
    return inBookings
        .firstWhere((booking) => booking?.room == roomID, orElse: () => null)
        ?.bed;
  }

  int getExtraBed(String roomID) {
    return inBookings
            .firstWhere((booking) => booking?.room == roomID,
                orElse: () => null)
            ?.extraBed ??
        0;
  }

  bool isInToday(String roomID) =>
      inBookings.any((booking) => booking?.room == roomID);

  bool isOutToday(String roomID) =>
      outBookings.any((booking) => booking?.room == roomID);

  Booking? getBookingWithInByRoomID(String roomID) {
    return inForBookings
        .where((element) =>
            element!.inDate!.isBefore(now) && element.outDate!.isAfter(now))
        .firstWhere((booking) => booking?.room == roomID, orElse: () => null);
  }

  Booking? getBookingInByRoomIdInDay(String? roomID) {
    return inForBookings
        .where((element) =>
            element?.inDate?.day == dayInTime.day &&
            element?.inDate?.month == dayInTime.month &&
            element?.inDate?.year == dayInTime.year)
        .firstWhere((booking) => booking?.room == roomID, orElse: () => null);
  }

  Booking? getBookingInByRoomID(String roomID) => inBookings
      .firstWhere((booking) => booking?.room == roomID, orElse: () => null);

  Booking? getBookingOutByRoomID(String roomID) => outBookings
      .firstWhere((booking) => booking?.room == roomID, orElse: () => null);

  bool isRepair(String roomID) =>
      repairBookings.any((booking) => booking?.room == roomID);

  void setSortType(int? newType) async {
    if (newType == null || newType == sortType) {
      return;
    }
    sortType = newType;
    var sharedReference = await SharedPreferences.getInstance();
    sharedReference.setInt(_sharedReferenceKey, sortType);
    notifyListeners();
  }

  Future<String> updateVacantOvernight(bool value) async {
    if (vacantOvernight == value) return "";
    vacantOvernight = value;
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateVacantOvernight")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'vacantvernight': vacantOvernight,
    }).then((value) async {
      notifyListeners();
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      return value.data;
    }).onError((e, stackTrace) {
      return (e as FirebaseFunctionsException).message;
    });
  }

  Future<String> updateAllVacantOvernight(List<Room> rooms) async {
    List<String> listRoomId = [];
    rooms.where((element) => element.vacantOvernight!).forEach((element) {
      listRoomId.add(element.id!);
    });
    if (listRoomId.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.ALL_CHECKED_ROOM);
    }
    return await FirebaseFunctions.instance
        .httpsCallable("hotelmanager-updateAllVacantOvernight")
        .call({
      'hotel_id': GeneralManager.hotelID,
      'vacantvernight': listRoomId,
    }).then((value) async {
      notifyListeners();
      GeneralManager.updateHotel(GeneralManager.hotel!.id!);
      return value.data;
    }).onError((e, stackTrace) {
      return (e as FirebaseFunctionsException).message;
    });
  }

  Future<String> saveNotes(Room room, String note) async {
    if (room.note == note) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-addNoteRoom')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'room_id': room.id,
      'notes': note
    }).then((value) => value.data);
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
