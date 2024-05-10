import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';

class RepairController extends ChangeNotifier {
  late final Booking booking;

  late DateTime inDate;
  late DateTime outDate;
  late TextEditingController teDesc;
  bool updating = false;

  RepairController(this.booking) {
    teDesc = TextEditingController(text: booking.name ?? '');
    final now12h = DateUtil.to12h(Timestamp.now().toDate());

    inDate = booking.inDate ?? now12h;

    outDate = booking.outDate ?? inDate.add(const Duration(days: 1));
  }

  void disposeAllTextEditingControllers() {
    teDesc.dispose();
  }

  DateTime getFirstDate() {
    final now = Timestamp.now().toDate();
    final now12h = DateUtil.to12h(now);
    if (now.compareTo(now12h) >= 0) {
      return now12h;
    } else {
      return now12h.subtract(const Duration(days: 1));
    }
  }

  DateTime getLastDate() {
    final now = Timestamp.now().toDate();
    return now.add(const Duration(days: 499));
  }

  void setInDate(DateTime inDate) async {
    if (DateUtil.equal(inDate, this.inDate)) {
      return;
    }

    this.inDate = DateUtil.to12h(inDate);
    if (outDate.compareTo(this.inDate) <= 0) {
      outDate = this.inDate.add(const Duration(days: 1));
    }

    notifyListeners();
  }

  void setOutDate(DateTime outDate) async {
    if (DateUtil.equal(outDate, this.outDate)) {
      return;
    }

    final outDate12h = DateUtil.to12h(outDate);

    if (outDate12h.compareTo(inDate) <= 0) {
      return;
    }

    this.outDate = outDate12h;

    notifyListeners();
  }

  Future<String> updateRepair() async {
    updating = true;
    notifyListeners();
    String result;
    if (booking.isEmpty!) {
      result = await Booking(
        name: teDesc.text,
        room: booking.room,
        roomTypeID: booking.roomTypeID,
        inDate: inDate,
        inTime: inDate,
        outDate: outDate,
        outTime: outDate,
        status: BookingStatus.repair,
      ).add();
    } else {
      result = await booking
          .update(
            name: teDesc.text,
            room: booking.room,
            roomTypeID: booking.roomTypeID,
            inDateParam: inDate,
            outDateParam: outDate,
          )
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    }

    updating = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
