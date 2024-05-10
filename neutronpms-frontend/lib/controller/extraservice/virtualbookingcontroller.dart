import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../handler/firebasehandler.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';

class VirtualBookingManagementController extends ChangeNotifier {
  final pageSize = 10;
  bool isLoading = false;
  List<Booking> bookings = [];
  Query? nextQuery;
  Query? prevQuery;
  Query? recentQuery;
  Query? query;
  DateTime? dateTime;
  String selectDate = UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  List<String> listSelect = [
    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_TIME),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE),
  ];

  Query queryInitBooking() {
    isLoading = true;
    notifyListeners();
    Query initQuery = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('virtual', isEqualTo: true)
        .where('status', isEqualTo: BookingStatus.booked);

    if (selectDate != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_TIME)) {
        initQuery = initQuery
            .where('created', isGreaterThanOrEqualTo: DateUtil.to0h(dateTime!))
            .where('created', isLessThanOrEqualTo: DateUtil.to24h(dateTime!))
            .orderBy('created');
      }
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE)) {
        initQuery = initQuery.where('in_date', isEqualTo: dateTime);
      }
      if (selectDate ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE)) {
        initQuery = initQuery.where('out_date', isEqualTo: dateTime);
      }
    } else {
      initQuery = initQuery.orderBy('out_date');
    }
    return initQuery;
  }

  bool? forward;

  StreamSubscription? subscription;

  VirtualBookingManagementController() {
    query = queryInitBooking().limit(pageSize);
    asyncVirtualBookings();
  }

  void loadBookingSearch() async {
    if (dateTime == null &&
        selectDate != UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      return;
    }
    query = queryInitBooking().limit(pageSize);
    asyncVirtualBookings();
  }

  void asyncVirtualBookings() {
    print("asyncVirtualBookings: Init");
    subscription = query!.snapshots().listen((snapshots) {
      print("asyncVirtualBookings: Run");

      bookings.clear();
      for (var doc in snapshots.docs) {
        bookings.add(Booking.virtualFromSnapshot(doc));
      }
      notifyListeners();

      if (snapshots.size == 0) {
        if (forward == null) {
          nextQuery = null;
          prevQuery = null;
        } else if (forward!) {
          nextQuery = null;
          prevQuery = recentQuery;
        } else {
          prevQuery = null;
          nextQuery = recentQuery;
        }
      } else {
        recentQuery = query;
        nextQuery = queryInitBooking()
            .startAfterDocument(snapshots.docs.last)
            .limit(pageSize);
        prevQuery = queryInitBooking()
            .endBeforeDocument(snapshots.docs.first)
            .limit(pageSize);
      }
      isLoading = false;
      notifyListeners();
    }, onDone: () => print('asyncVirtualBookings: Done'), cancelOnError: true);
  }

  void cancelStream() {
    subscription?.cancel();
    print("asyncVirtualBookings: Cancel");
  }

  void nextPage() {
    if (nextQuery == null) return;

    forward = true;
    query = nextQuery;
    cancelStream();
    asyncVirtualBookings();
  }

  void previousPage() {
    if (prevQuery == null) return;

    forward = false;
    query = prevQuery;
    cancelStream();
    asyncVirtualBookings();
  }

  String getEmptyPageNotes() {
    if (forward == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);
    }
    if (forward!) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NO_DATA_AND_PRESS_PREVIOUS_TO_GET_BACK);
    } else {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NO_DATA_AND_PRESS_NEXT_TO_GET_BACK);
    }
  }

  void setDateTime(DateTime date) {
    if (dateTime != null && DateUtil.equal(dateTime!, date)) return;

    dateTime = DateUtil.to12h(date);
    notifyListeners();
  }

  void setSelectDate(String value) {
    if (selectDate == value) return;
    selectDate = value;
    if (value == UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
      dateTime = null;
    }
    notifyListeners();
  }
}

class VirtualBookingController extends ChangeNotifier {
  Booking? addedBooking;
  Booking? booking;
  TextEditingController teName = TextEditingController();
  TextEditingController tePhone = TextEditingController();
  TextEditingController teEmail = TextEditingController();
  TextEditingController teSID = TextEditingController();

  DateTime outDate = DateUtil.to12h(Timestamp.now().toDate());

  bool isAdd = false;
  bool processing = false;

  VirtualBookingController(this.booking) {
    isAdd = booking == null;

    if (booking != null) {
      outDate = booking!.outDate!;
      teName.text = booking!.name!;
      tePhone.text = booking!.phone!;
      teEmail.text = booking!.email!;
      teSID.text = booking!.sID!;
    } else {
      teSID.text = "";
    }
  }

  void disposeAllTextEditingController() {
    teName.dispose();
    tePhone.dispose();
    teEmail.dispose();
    teSID.dispose();
  }

  void setOutDate(DateTime newOutDate) {
    newOutDate = DateUtil.to12h(newOutDate);
    if (DateUtil.equal(newOutDate, outDate)) return;

    final now12h = DateUtil.to12h(Timestamp.now().toDate());
    if (newOutDate.compareTo(now12h) < 0) return;

    outDate = newOutDate;
    notifyListeners();
  }

  Future<String> updateVirtualBooking() async {
    if (processing) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    processing = true;
    notifyListeners();
    String result;
    if (isAdd) {
      final now12h = DateUtil.to12h(Timestamp.now().toDate());
      addedBooking = Booking.virtual(
          inDate: now12h,
          outDate: outDate,
          name: teName.text,
          phone: tePhone.text,
          email: teEmail.text,
          sID: teSID.text);
      result = await addedBooking!
          .addVirtual()
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    } else {
      result = await booking!
          .updateVirtual(
              outDate: outDate,
              name: teName.text,
              phone: tePhone.text,
              email: teEmail.text)
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    }
    processing = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }

  Booking getAddedBooking() {
    return addedBooking!;
  }
}
