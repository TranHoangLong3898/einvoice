import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/channelmanager.dart';
import '../../manager/generalmanager.dart';
import '../../manager/roomtypemanager.dart';
import '../../util/dateutil.dart';

class CMBookingController extends ChangeNotifier {
  String dateFilter = "LastModifiedDate";
  final filters = ["LastModifiedDate", "BookingDate", "CheckIn", "CheckOut"];
  String bookingStatus = "";
  final statuses = [
    "",
    "Confirmed",
    "Cancelled",
    "Cancelled With Penalty",
    "No Show",
    "No Show With Penalty",
    "Operational",
    "Completed"
  ];

  List<String> roomTypeNames = [];
  TextEditingController valuePeriod = TextEditingController();
  late String selectedRoomType;
  late String selectedRoomTypePeriod;
  String? updateReleasePeriodErrorFromAPI;
  bool updating = false;

  dynamic bookings;

  DateTime start = Timestamp.now().toDate();
  DateTime end = Timestamp.now().toDate();

  TextEditingController numberController = TextEditingController();

  bool processing = false;

  String? notifyBookingErrorFromAPI;
  String? syncBookingErrorFromAPI;

  CMBookingController() {
    initialize();
  }
  void initialize() async {
    updating = true;
    notifyListeners();
    roomTypeNames = ChannelManager().getMappedRoomTypeNames();
    selectedRoomType = roomTypeNames.isNotEmpty
        ? RoomTypeManager().getRoomTypeIDByName(roomTypeNames.first)
        : '';
    selectedRoomTypePeriod = roomTypeNames.isNotEmpty
        ? RoomTypeManager().getRoomTypeIDByName(roomTypeNames.first)
        : '';
    updating = false;
    notifyListeners();
  }

  void changeDateFilter(String dateFilter) {
    this.dateFilter = dateFilter;
    notifyListeners();
  }

  void changeBookingStatus(String bookingStatus) {
    this.bookingStatus = bookingStatus;
    notifyListeners();
  }

  void setStart(DateTime date) {
    start = DateUtil.to12h(date);
    if (start.compareTo(end) > 0) {
      end = start;
    }
    notifyListeners();
  }

  void setEnd(DateTime date) {
    end = DateUtil.to12h(date);
    notifyListeners();
  }

  Future<bool?> getBookings() async {
    try {
      final number = num.tryParse(numberController.text.replaceAll(',', ''));
      if (end.compareTo(start) < 0) return false;
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-getbookings');
      if (processing) return null;
      processing = true;
      final data = (await callable({
        "hotel": GeneralManager.hotelID,
        "startDate": DateUtil.dateToHLSString(start),
        "endDate": DateUtil.dateToHLSString(end),
        "dateFilter": dateFilter,
        'bookingStatus': bookingStatus,
        if (number != null) 'numberBookings': number,
      }))
          .data;

      processing = false;
      if (data['result']) {
        bookings = data['reservation'];
      } else {
        bookings = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      processing = false;
      bookings = null;
      notifyListeners();
      return false;
    }
  }

  Future syncBooking(booking) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-syncbooking');
      if (processing) return null;
      processing = true;
      final result = (await callable(
              {"hotel": GeneralManager.hotelID, "booking": booking}))
          .data;
      processing = false;
      syncBookingErrorFromAPI = result['error'];
      return result['result'];
    } catch (e) {
      processing = false;
      syncBookingErrorFromAPI =
          MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR);
      return false;
    }
  }

  Future<bool?> notifyBooking(String bookingID) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-notifybooking');
      if (processing) return null;
      processing = true;
      final data = (await callable(
              {'hotel': GeneralManager.hotelID, "bookingID": bookingID}))
          .data;
      processing = false;
      notifyBookingErrorFromAPI = MessageUtil.getMessageByCode(data['error']);
      return data['result'];
    } catch (e) {
      processing = false;
      return false;
    }
  }

  void changeSelectedRoomTypePeriod(String selectedRoomTypeNameParam) async {
    if (selectedRoomTypeNameParam == '') return;
    if (RoomTypeManager().getRoomTypeIDByName(selectedRoomTypeNameParam) ==
        selectedRoomTypePeriod) return;
    selectedRoomTypePeriod =
        RoomTypeManager().getRoomTypeIDByName(selectedRoomTypeNameParam);
    notifyListeners();
  }

  Future<dynamic> updateReleasePeriod() async {
    try {
      updating = true;
      notifyListeners();
      final value = num.tryParse(valuePeriod.text.replaceAll(',', ''));
      if (value == null || value < 0) {
        updateReleasePeriodErrorFromAPI =
            MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_NUMBER);
        updating = false;
        notifyListeners();
        return false;
      }
      if (end.compareTo(start) < 0) {
        updating = false;
        notifyListeners();
        return false;
      }

      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-updateReleasePeriod');
      final data = (await callable({
        "hotel": GeneralManager.hotelID,
        "roomID":
            ChannelManager().getCMRoomTypeIDByPMSRoomTypeID(selectedRoomType),
        "from": DateUtil.dateToHLSString(start),
        "to": DateUtil.dateToHLSString(end),
        'value': value,
      }))
          .data;
      updateReleasePeriodErrorFromAPI =
          MessageUtil.getMessageByCode(data['error']);
      updating = false;
      notifyListeners();
      return data['result'];
    } catch (e) {
      print(e.toString());
      updating = false;
      notifyListeners();
      return false;
    }
  }
}
