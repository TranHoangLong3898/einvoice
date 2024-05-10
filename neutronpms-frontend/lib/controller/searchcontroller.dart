import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../manager/generalmanager.dart';
import '../manager/sourcemanager.dart';
import '../modal/booking.dart';
import '../modal/status.dart';
import '../util/dateutil.dart';
import '../util/designmanagement.dart';

class SearchControllers extends ChangeNotifier {
  DateTime? startDate, endDate;
  String? sourceID;
  String selectDate =
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
  List<String> listSelect = [
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_DATE),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE),
  ];
  bool checkTaxDeclare = false;
  TextEditingController sIDController = TextEditingController();
  List<Booking> bookings = [];
  List<int> listStatus = [];
  List<String> selectedStatus = [];
  Map<String, dynamic> notes = {};

  Query? nextQuery;
  Query? preQuery;
  bool? forward;
  bool isShowNote = false;

  Query? recentQuery;
  QuerySnapshot? snapshotTemp;

  final int pageSize = 10;

  bool isLoading = false;

  DateTime now = Timestamp.now().toDate();

  SearchControllers() {
    for (var statusName in BookingStatus.statusNames.values) {
      if (statusName == 'moved') continue;
      String status = UITitleUtil.getTitleByCode(statusName);
      selectedStatus.add(status);
    }
    loadBookingSearch();
  }

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    if (startDate != null && startDate!.isAtSameMomentAs(newStart)) {
      return;
    }
    startDate = newStart;
    if (startDate != null && endDate != null) {
      if (startDate!.isAfter(endDate!)) {
        endDate = DateUtil.to24h(startDate!);
      } else if (endDate!.difference(startDate!).inDays > 30) {
        endDate = DateUtil.to24h(startDate!.add(const Duration(days: 30)));
      }
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    DateTime newEnd = DateUtil.to24h(date);
    if (startDate != null && endDate != null) {
      if (endDate!.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate!)) {
        return;
      }
    }
    endDate = newEnd;
    notifyListeners();
  }

  void setSelectDate(String value) {
    if (selectDate == value) return;
    selectDate = value;
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

  void setStatusID(String statusName, bool check) {
    if (check) {
      listStatus.add(BookingStatus.getStatusIDByName(statusName));
      selectedStatus.add(statusName);
    } else {
      listStatus.remove(BookingStatus.getStatusIDByName(statusName));
      selectedStatus.remove(statusName);
    }
    notifyListeners();
  }

  void setTaxDeclare(bool value) {
    if (value == checkTaxDeclare) return;
    checkTaxDeclare = value;
    notifyListeners();
  }

  List<String> getStatusWithoutMoved() {
    final List<String> statuses = BookingStatus.getStatusNames();
    statuses.removeWhere((element) => element == 'moved');
    return statuses.map((e) => UITitleUtil.getTitleByCode(e)).toList();
  }

  Query queryInitBooking() {
    Query initQuery =
        FirebaseHandler.hotelRef.collection(FirebaseHandler.colBookings);

    if (sIDController.text != '') {
      initQuery = initQuery.where('sid', isEqualTo: sIDController.text);
    } else {
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_TIME)) {
        initQuery = initQuery
            .where('created', isGreaterThanOrEqualTo: startDate)
            .where('created', isLessThanOrEqualTo: endDate)
            .orderBy('created');
      }
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE)) {
        initQuery = initQuery
            .where('in_date', isGreaterThanOrEqualTo: startDate)
            .where("in_date", isLessThanOrEqualTo: endDate)
            .orderBy('in_date');
      }
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE)) {
        initQuery = initQuery
            .where('out_date', isGreaterThanOrEqualTo: startDate)
            .where("out_date", isLessThanOrEqualTo: endDate)
            .orderBy('out_date');
      }
      if (sourceID != 'Source') {
        initQuery = initQuery.where('source', isEqualTo: sourceID);
      }
      if (listStatus.isNotEmpty) {
        initQuery = initQuery.where('status', whereIn: listStatus);
      }
      if (checkTaxDeclare) {
        initQuery = initQuery.where('tax_declare', isEqualTo: checkTaxDeclare);
      }
    }
    return initQuery;
  }

  void loadBookingSearch() async {
    if (startDate == null &&
        endDate == null &&
        sourceID == null &&
        listStatus.isEmpty &&
        sIDController.text == '' &&
        !checkTaxDeclare) {
      return;
    }
    try {
      isLoading = true;
      notifyListeners();
      bookings.clear();
      recentQuery = queryInitBooking();
      await queryInitBooking()
          .limit(pageSize)
          .get()
          .then((snapshot) => updateBookingSearchAndQuery(snapshot));
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Booking>> loadingDataBookingExcel() async {
    List<Booking> bookingsAll = [];
    bookingsAll.clear();
    await queryInitBooking().get().then((snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        if ((documentSnapshot.data() as Map)['group'] ?? false) {
          final Booking groupBooking =
              Booking.groupFromSnapshot(documentSnapshot);
          groupBooking.room = RoomManager().groupName;
          bookingsAll.add(groupBooking);
        } else {
          bookingsAll.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
    });

    return bookingsAll;
  }

  void updateBookingSearchAndQuery(QuerySnapshot snapshot) async {
    if (snapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = recentQuery!
            .endBeforeDocument(snapshotTemp!.docs.first)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = recentQuery!
            .startAfterDocument(snapshotTemp!.docs.last)
            .limit(pageSize);
      }
    } else {
      bookings.clear();
      notes.clear();
      snapshotTemp = snapshot;
      for (var documentSnapshot in snapshot.docs) {
        if ((documentSnapshot.data() as Map)['group'] ?? false) {
          final Booking groupBooking =
              Booking.groupFromSnapshot(documentSnapshot);
          groupBooking.room = RoomManager().groupName;
          bookings.add(groupBooking);
        } else {
          bookings.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      if (snapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = recentQuery!
              .endBeforeDocument(snapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          nextQuery = recentQuery!
              .startAfterDocument(snapshot.docs.last)
              .limit(pageSize);
          preQuery = null;
        }
      } else {
        nextQuery =
            recentQuery!.startAfterDocument(snapshot.docs.last).limit(pageSize);
        preQuery = recentQuery!
            .endBeforeDocument(snapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    for (var booking in bookings) {
      getNotes(booking);
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    sourceID = null;
    listStatus.clear();
    selectedStatus.clear();
    sIDController.text = '';
    bookings = [];
    checkTaxDeclare = false;
    isLoading = false;
    notifyListeners();
  }

  void getBookingSearchNextPage() async {
    if (nextQuery == null) return;

    forward = true;
    await nextQuery!.get().then((value) => updateBookingSearchAndQuery(value));
  }

  void getBookingSearchPreviousPage() async {
    if (preQuery == null) return;

    forward = false;
    await preQuery!.get().then((value) => updateBookingSearchAndQuery(value));
  }

  Color getColorByStatusBooking(String value) {
    if (value == UITitleUtil.getTitleByCode("booked")) {
      return Color(GeneralManager.hotel!.colors!['book']['main']);
    } else if (value == UITitleUtil.getTitleByCode("in")) {
      return Color(GeneralManager.hotel!.colors!['in']['main']);
    } else if (value == UITitleUtil.getTitleByCode("out")) {
      return Color(GeneralManager.hotel!.colors!['out']['main']);
    } else if (value == UITitleUtil.getTitleByCode("unconfirmed")) {
      return GeneralManager.hotel!.colors!['unconfirmed'] == null
          ? ColorManagement.bookingUnconfirmed
          : Color(GeneralManager.hotel!.colors!['unconfirmed']['main']);
    }
    return Colors.black;
  }

  num getPaymentTotal() => bookings.fold(
      0, (previousValue, element) => previousValue + element.deposit!);
  num getRoomChargeTotal() => bookings.fold(
      0, (previousValue, element) => previousValue + element.getRoomCharge());
  num getTotal() => bookings.fold(
      0, (previousValue, element) => previousValue + element.getTotalCharge()!);
  num getRemainTotal() => bookings.fold(
      0, (previousValue, element) => previousValue + element.getRemaining()!);

  void onChange() {
    isShowNote = !isShowNote;
    notifyListeners();
  }

  getNotes(Booking booking) async {
    notes[booking.sID!] = booking.group ?? false
        ? await booking.getNotesBySid() ?? ""
        : await booking.getNotes() ?? "";
  }
}
