import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';

class ChangeRoomController extends ChangeNotifier {
  final Booking booking;
  late String roomTypeID;
  late String room;
  List<String> rooms = [];
  List<num> prices = [];
  late DateTime inDate;
  late DateTime inDatePrice;
  late String ratePlanID;
  bool changing = false;
  bool isBefore12h = false;
  ChangeRoomController(this.booking) {
    changing = true;
    notifyListeners();
    initialize();
  }

  void initialize() async {
    booking.staydays = DateUtil.getStaysDay(booking.inDate!, booking.outDate!);
    roomTypeID = booking.roomTypeID!;
    room = booking.room!;
    ratePlanID = booking.ratePlanID!;
    prices = booking.price!;
    if (booking.status == BookingStatus.checkin) {
      final now = Timestamp.now().toDate();
      DateTime now12h = DateTime(now.year, now.month, now.day, 12);
      inDatePrice = now12h;
      if (now.isBefore(now12h)) {
        isBefore12h = true;
        inDate = now12h.add(const Duration(days: -1));
      } else {
        inDate = now12h;
      }
    } else {
      inDate = booking.inDate!;
    }
    await updateRooms();
  }

  void setRoomTypeID(String newRoomTypeID) async {
    if (newRoomTypeID != roomTypeID) {
      roomTypeID = newRoomTypeID;
      await updateRooms();
    }
  }

  void setRoom(String newRoom) {
    if (newRoom != room) {
      room = newRoom;
      notifyListeners();
    }
  }

  Future<void> updateRooms() async {
    rooms = await DailyAllotmentStatic()
        .getAvailableRoomsWithStaysDayAndRoomTypeiD(
            inDate, booking.outDate!, roomTypeID);

    if (roomTypeID == booking.roomTypeID) {
      if (!rooms.contains(booking.room)) {
        rooms.add(booking.room!);
      }
      room = rooms.isEmpty ? booking.room! : rooms.first;
    } else {
      room = rooms.isEmpty ? RoomManager().idNoneRoom! : rooms.first;
    }
    rooms = rooms.map((room) => RoomManager().getNameRoomById(room)).toList();
    changing = false;
    notifyListeners();
  }

  Future<String> changeRoom() async {
    if (!booking.canChangeRoom()) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.ROOM_CAN_NOT_CHANGE, [booking.name!]);
    }

    if (room.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_AVAILABLE_ROOM);
    }

    changing = true;
    notifyListeners();
    String? result;
    if (booking.status == BookingStatus.checkin) {
      result = await booking
          .update(roomTypeID: roomTypeID, room: room, priceParam: prices)
          .then((value) => value)
          .onError((error, stackTrace) {
        return error.toString();
      });
    } else if (booking.status == BookingStatus.booked) {
      result = await booking
          .update(
              priceParam: prices,
              roomTypeID: roomTypeID,
              room: room,
              inDateParam: inDate,
              saler: booking.saler,
              outDateParam: inDate.add(Duration(days: booking.lengthStay!)))
          .then((value) => value)
          .onError((error, stackTrace) {
        return error.toString();
      });
    }
    changing = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
