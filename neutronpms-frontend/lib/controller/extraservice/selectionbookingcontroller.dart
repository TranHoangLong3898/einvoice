import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/roommanager.dart';
import '../../manager/bookingmanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';

class SelectionBookingMode {
  static const sID = 'sID';
  static final stayingRoom =
      MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_STAYING_ROOM);
  static final virtual =
      MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_VIRTUAL_BOOKING);
  static final modes = [sID, stayingRoom, virtual];
}

class SelectionBookingController extends ChangeNotifier {
  String selectionMode = SelectionBookingMode.stayingRoom;
  DateTime? inDate = DateUtil.to12h(Timestamp.now().toDate());
  DateTime? outDate;
  String? room =
      MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CHOOSE_ROOM);

  //false = display non-group-booking and parent-booking of group-booking
  //true  = display non-group-booking and sub-booking of group-booking
  bool isSearchIncludeSubBooking = false;

  SelectionBookingController({bool? isSearchDetail}) {
    isSearchIncludeSubBooking = isSearchDetail ?? false;
    // search();
  }
  TextEditingController sIDController = TextEditingController();
  List<Booking>? bookings = [];

  void setMode(String newMode) {
    if (newMode == selectionMode) return;
    selectionMode = newMode;
    bookings!.clear();
    notifyListeners();
  }

  void setInDate(DateTime date) {
    if (inDate != null && DateUtil.equal(inDate!, date)) return;

    inDate = DateUtil.to12h(date);
    notifyListeners();
  }

  void setRoom(String newRoom) {
    if (newRoom == room) return;
    room = newRoom;
    notifyListeners();
  }

  void setOutDate(DateTime date) {
    if (outDate != null && DateUtil.equal(outDate!, date)) return;

    outDate = DateUtil.to12h(date);
    notifyListeners();
  }

  void search() async {
    if (selectionMode == SelectionBookingMode.virtual &&
        inDate == null &&
        outDate == null &&
        sIDController.text == '') return;

    bookings = null;
    notifyListeners();
    if (selectionMode == SelectionBookingMode.virtual) {
      bookings = await BookingManager().searchBookings(
          statusID: BookingStatus.booked,
          sourceID: SourceManager.virtualSource,
          inDate: inDate,
          outDate: outDate);
    } else if (selectionMode == SelectionBookingMode.sID) {
      bookings = await BookingManager()
          .getBookingsBySID(sIDController.text, isSearchIncludeSubBooking);
    } else if (selectionMode == SelectionBookingMode.stayingRoom) {
      if (room ==
          MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CHOOSE_ROOM)) {
        bookings = [];
        notifyListeners();
        return;
      }
      bookings = await BookingManager().searchBookingStayingRoom(
          statusID: BookingStatus.checkin,
          room: RoomManager().getIdRoomByName(room!),
          isSearchIncludeSubBooking: isSearchIncludeSubBooking);
    }
    notifyListeners();
  }

  List<String?> getStayingRoom() => RoomManager().getStayingRoomIDs();

  void reset() {
    inDate = null;
    outDate = null;
    room = null;
    sIDController.text = '';
    bookings = [];
    notifyListeners();
  }
}
