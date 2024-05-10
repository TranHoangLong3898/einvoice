import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../handler/firebasehandler.dart';
import '../manager/sourcemanager.dart';
import '../modal/booking.dart';
import '../modal/status.dart';
import '../modal/staydeclaration/countrydeclaration.dart';
import '../modal/staydeclaration/staydeclaration.dart';
import '../util/messageulti.dart';

class ListGuestDeclarationController extends ChangeNotifier {
  //search input
  DateTime? cin;
  DateTime? cout;
  String? sourceID;
  int? statusID;
  TextEditingController sIDController = TextEditingController();

  final String staying =
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STAYING);
  final String checkinToday =
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHECKIN_TODAY);
  final DateTime today12h = DateUtil.to12h(DateTime.now());
  final List<String> nationalities = [
    MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
    CountryDeclaration.VIETNAM,
    MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_OTHER_NATIONALITY),
  ];

  //fields for filter
  List<String> types = [];
  late String selectedType;
  late String selectedNationality;

  //results
  List<Booking> bookings = [];
  List<StayDeclaration> guests = [];
  List<StayDeclaration> filtedList = [];

  bool isLoading = false;

  ListGuestDeclarationController() {
    types = [staying, checkinToday];
    selectedType = types.first;
    selectedNationality = nationalities.first;
    guests = [];
  }

  void setInDate(DateTime date) {
    if (cin != null && DateUtil.equal(cin!, date)) return;
    cin = DateUtil.to12h(date);
    notifyListeners();
  }

  void setOutDate(DateTime date) {
    if (cout != null && DateUtil.equal(cout!, date)) return;
    cout = DateUtil.to12h(date);
    notifyListeners();
  }

  void setSourceID(String sourceName) {
    if (sourceName ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)) {
      sourceID = null;
    } else {
      sourceID = SourceManager().getSourceIDByName(sourceName);
    }
    notifyListeners();
  }

  void setStatusID(String statusName) {
    if (statusName ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS)) {
      statusID = null;
    } else {
      statusID = BookingStatus.getStatusIDByName(statusName);
    }
    notifyListeners();
  }

  void setNationality(String newNationality) {
    if (selectedNationality == newNationality) {
      return;
    }
    selectedNationality = newNationality;
    filterBookingByTypeAndNationality();
    notifyListeners();
  }

  List<String> getStatus() {
    final List<String> statuses = BookingStatus.getStatusNames();
    statuses
        .removeWhere((element) => element == 'moved' || element == 'repair');
    return statuses.map((e) => UITitleUtil.getTitleByCode(e)).toList();
  }

  void loadBookingSearch() async {
    if (cin == null &&
        cout == null &&
        sourceID == null &&
        statusID == null &&
        sIDController.text == '') {
      return;
    }
    isLoading = true;
    notifyListeners();

    bookings.clear();
    Query initQuery = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('has_declaration', isEqualTo: true);

    if (cin != null) {
      initQuery = initQuery.where('in_date', isEqualTo: cin);
    }
    if (cout != null) {
      initQuery = initQuery.where('out_date', isEqualTo: cout);
    }
    if (sourceID !=
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)) {
      initQuery = initQuery.where('source', isEqualTo: sourceID);
    }
    if (statusID != null) {
      initQuery = initQuery.where('status', isEqualTo: statusID);
    }
    if (sIDController.text != '') {
      initQuery = initQuery.where('sid', isEqualTo: sIDController.text.trim());
    }
    bookings.clear();
    guests.clear();
    await initQuery.get().then((snapshot) {
      print('getBookingWithTaxDeclare: ${snapshot.size} (bookings)');
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          dynamic data = doc.data();
          if (data['group'] ?? false) {
            Booking parentBooking = Booking.groupFromSnapshot(doc);
            for (var childBookingId in parentBooking.subBookings!.keys) {
              Booking childBooking =
                  Booking.fromBookingParent(childBookingId, parentBooking);
              if (childBooking.isTaxDeclare!) {
                bookings.add(childBooking);
              }
            }
          } else {
            bookings.add(Booking.fromSnapshot(doc));
          }
        }
        getListGuestFromBookings();
        filterBookingByTypeAndNationality();
      }
    });

    isLoading = false;
    notifyListeners();
  }

  void getListGuestFromBookings() {
    for (var booking in bookings) {
      for (var guestMap in booking.declareGuests!) {
        StayDeclaration stayDeclaration = StayDeclaration.fromJson(guestMap);
        stayDeclaration.roomId = booking.room;
        stayDeclaration.bookingId = booking.id;
        stayDeclaration.inDate = booking.inDate;
        stayDeclaration.outDate = booking.outDate;
        guests.add(stayDeclaration);
      }
    }
  }

  void filterBookingByTypeAndNationality() {
    filtedList.clear();
    filtedList.addAll(guests.where((element) {
      if (selectedNationality ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return true;
      }
      return selectedNationality == CountryDeclaration.VIETNAM
          ? element.nationality == CountryDeclaration.VIETNAM
          : element.nationality != CountryDeclaration.VIETNAM;
    }));
  }

  Booking getBookingContainGuest(StayDeclaration guest) {
    return bookings.firstWhere((booking) => booking.id == guest.bookingId);
  }

  void reset() {
    cin = null;
    cout = null;
    sourceID = null;
    statusID = null;
    sIDController.text = '';
    bookings = [];
    isLoading = false;
    notifyListeners();
  }
}
