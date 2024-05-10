import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/modal/guest_report.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../handler/firebasehandler.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/excelulti.dart';

class GuestReportController extends ChangeNotifier {
  late DateTime now, startDate, endDate;
  bool isLoading = false;
  List<GuestReport?> guestReports = [];

  GuestReportController() {
    now = DateTime.now();
    startDate = DateUtil.to12h(now);
    endDate = DateUtil.to12h(now);
    loadBasicBookings();
  }

  Query getInitQueryBookingByStayingDate() {
    if (!DateUtil.equal(startDate, endDate)) {
      return FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBasicBookings)
          .where('stay_days',
              arrayContainsAny: DateUtil.getStaysDay(startDate, endDate)
                ..add(endDate))
          .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
          .orderBy('status', descending: true);
    }
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days',
            arrayContainsAny: DateUtil.getStaysDay(startDate, endDate))
        .where('status', isGreaterThanOrEqualTo: BookingStatus.booked)
        .orderBy('status', descending: true);
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to12h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to12h(startDate);
    if (endDate.difference(startDate) > const Duration(days: 7)) {
      endDate = DateUtil.to12h(startDate.add(const Duration(days: 7)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to12h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  void loadBasicBookings() async {
    isLoading = true;
    notifyListeners();
    guestReports.clear();
    for (var date in DateUtil.getStaysDay(startDate, endDate)) {
      guestReports.add(GuestReport(id: date));
    }
    if (!DateUtil.equal(startDate, endDate)) {
      guestReports.add(GuestReport(id: endDate));
    }
    getInitQueryBookingByStayingDate().get().then((snapshotsBooking) {
      updateBasicBookingsAndQueries(snapshotsBooking);
    });
  }

  void updateBasicBookingsAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size != 0) {
      for (var documentSnapshot in querySnapshot.docs) {
        Booking? booking = Booking.basicFromSnapshot(documentSnapshot);
        final guestReportNewDate = guestReports.firstWhere(
            (element) => DateUtil.equal(element!.id!, booking.inDate!),
            orElse: () => null);
        if (guestReportNewDate != null) {
          if (booking.typeTourists == TypeTourists.unknown) {
            guestReportNewDate.newGuestCountUnknown =
                (guestReportNewDate.newGuestCountUnknown! +
                    booking.adult! +
                    booking.child! +
                    booking.extraGuest!);
          } else if (booking.typeTourists == TypeTourists.domestic) {
            guestReportNewDate.newGuestCountDomestic =
                (guestReportNewDate.newGuestCountDomestic! +
                    booking.adult! +
                    booking.child! +
                    booking.extraGuest!);
          } else if (booking.typeTourists == TypeTourists.foreign) {
            guestReportNewDate.newGuestCountForeign =
                (guestReportNewDate.newGuestCountForeign! +
                    booking.adult! +
                    booking.child! +
                    booking.extraGuest!);
          }
        }
        for (var currentDate in booking.staydays!) {
          if (currentDate == booking.inDate ||
              (currentDate as DateTime).isAfter(booking.outTime!)) continue;
          final guestReportCurrentDate = guestReports.firstWhere(
            (element) => DateUtil.equal(element!.id!, currentDate),
            orElse: () => null,
          );

          // ignore: unnecessary_null_comparison
          if (guestReportCurrentDate != null) {
            if (booking.typeTourists == TypeTourists.unknown) {
              guestReportCurrentDate.inhouseCountUnknown =
                  (guestReportCurrentDate.inhouseCountUnknown! +
                      booking.adult! +
                      booking.child! +
                      booking.extraGuest!);
            } else if (booking.typeTourists == TypeTourists.domestic) {
              guestReportCurrentDate.inhouseCountDomestic =
                  (guestReportCurrentDate.inhouseCountDomestic! +
                      booking.adult! +
                      booking.child! +
                      booking.extraGuest!);
            } else if (booking.typeTourists == TypeTourists.foreign) {
              guestReportCurrentDate.inhouseCountForeign =
                  (guestReportCurrentDate.inhouseCountForeign! +
                      booking.adult! +
                      booking.child! +
                      booking.extraGuest!);
            }
          }
        }
      }
    }
    isLoading = false;
    notifyListeners();
  }

  num getTotalNewGuestUnknown() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.newGuestCountUnknown!);
  }

  num getTotalInhouseGuestUnknown() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.inhouseCountUnknown!);
  }

  num getTotalNewGuestDomestic() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.newGuestCountDomestic!);
  }

  num getTotalInhouseGuestDomestic() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.inhouseCountDomestic!);
  }

  num getTotalNewGuestForeign() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.newGuestCountForeign!);
  }

  num getTotalInhouseGuestForeign() {
    return guestReports.fold(
        0,
        (previousValue, element) =>
            previousValue + element!.inhouseCountForeign!);
  }

  num getTotalGuest() {
    return guestReports.fold(0,
        (previousValue, element) => previousValue + element!.getTotalGuest());
  }

  String exportToExcel() {
    List<DateTime> differentDate = DateUtil.getStaysDay(startDate, endDate);
    if (!DateUtil.equal(startDate, endDate)) {
      differentDate.add(endDate);
    }
    if (differentDate.length != guestReports.length) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CLICK_REFRESH_BUTTON_FIRST);
    } else if (!DateUtil.equal(differentDate[0], guestReports[0]!.id!)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CLICK_REFRESH_BUTTON_FIRST);
    }

    ExcelUlti.exportGuestReport(guestReports, startDate, endDate);
    return '';
  }
}
