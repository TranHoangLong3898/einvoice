import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/currentbookingcontroller.dart';
import 'package:ihotel/util/messageulti.dart';
import '../modal/room.dart';
import '../util/uimultilanguageutil.dart';
import 'generalmanager.dart';

class RoomManager extends ChangeNotifier {
  static final RoomManager _instance = RoomManager._internal();
  final String groupName = 'group';
  factory RoomManager() {
    return _instance;
  }
  RoomManager._internal();
  List<Room>? rooms = [], roomFull = [];
  String? idNoneRoom = '', nameNoneRoom = '', errorLog;
  CurrentBookingsController? currentBookingsController;
  bool isLoading = false;

  String statusFilter = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);

  void update(Map<String, dynamic> data) {
    roomFull!.clear();

    if (data.isEmpty) {
      rooms!.clear();
      return;
    }

    for (var item in data.entries) {
      final room = Room.fromSnaphot(item.value);
      room.id = item.key;
      roomFull!.add(room);
    }
    roomFull!.sort((a, b) {
      if (a.roomType!.compareTo(b.roomType!) == 0) {
        return a.id!.compareTo(b.id!);
      }
      return a.roomType!.compareTo(b.roomType!);
    });

    List<Room> newActiveRooms =
        roomFull!.where((element) => element.isDelete == false).toList();
    // if-else to prevent building twice after create/delete rooms
    // room dialog use this class, add or delete room => room dialog must renderer again
    if (newActiveRooms.length != rooms!.length) {
      currentBookingsController?.notifyListeners();
    }
    rooms = newActiveRooms;
    notifyListeners();
  }

  String getIdRoomByName(String roomName) {
    if (roomName == nameNoneRoom) return idNoneRoom!;
    return roomFull!
            .where((element) => element.isDelete == false)
            .firstWhere((element) => element.name == roomName)
            .id ??
        "";
  }

  String getRoomTypeById(String id) {
    if (id == nameNoneRoom) return idNoneRoom!;
    return roomFull!
            .where((element) => element.isDelete == false)
            .firstWhere((element) => element.id == id)
            .roomType ??
        "";
  }

  String getNameRoomById(String idRoom) {
    if (idRoom == idNoneRoom) return nameNoneRoom!;
    if (idRoom == 'virtual') return 'Virtual';
    if (idRoom == groupName) return 'Group';
    try {
      return roomFull!
              .where((element) => element.isDelete == false)
              .firstWhere((element) => element.id == idRoom)
              .name ??
          "";
    } catch (e) {
      return '';
    }
  }

  void cancelStream() {
    rooms = [];
    roomFull = [];
    currentBookingsController = null;
    print("asyncRoomsWithCloud: Cancelled");
  }

  List<Room> getRoomsPlus() {
    List<Room> result = [];
    for (var room in rooms!) {
      if (!result.any((element) => element.id == room.roomType)) {
        result.add(Room.type(id: room.roomType));
      }
      result.add(room);
    }
    return result;
  }

  List<String?> getRoomIDsPlus() =>
      getRoomsPlus().map((room) => room.id).toList();

  List<String?> getRoomIDs() => rooms!.map((room) => room.id).toList();

  Room getRoomByID(String id) => rooms!.firstWhere((room) => room.id == id);

  List<String> getRoomIDsByType(String type) => rooms!
      .where((room) => room.roomType == type)
      .map((room) => room.id!)
      .toList();

  List<String?> getStayingRoomIDs() => rooms!
      .where((room) => room.bookingID != null && room.bookingID!.isNotEmpty)
      .map((room) => room.name)
      .toList();

  String? getStayingBookingIDByRoomID(String id) {
    try {
      return rooms!
          .firstWhere((room) => room.id == id && room.bookingID != null)
          .bookingID;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleleRoom(String roomID) async {
    isLoading = true;
    notifyListeners();

    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('hotelmanager-deleteRoom');
      final result = await callable(
          {'hotel_id': GeneralManager.hotelID, 'room_id': roomID});
      isLoading = false;
      notifyListeners();
      return result.data == MessageCodeUtil.SUCCESS ? true : false;
    } on FirebaseFunctionsException catch (e) {
      errorLog = MessageUtil.getMessageByCode(e.message);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setStatusFilter(value) {
    statusFilter = value;
    notifyListeners();
  }
}
