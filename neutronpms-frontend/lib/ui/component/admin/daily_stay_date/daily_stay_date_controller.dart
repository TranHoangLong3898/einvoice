import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import '../../../../handler/firebasehandler.dart';
import '../../../../modal/booking.dart';
import '../../../../util/dateutil.dart';

class DailyStayDatesController extends ChangeNotifier {
  DateTime? staysDate;
  List<Booking> bookings = [];
  int? statusID;
  bool isLoading = false;
  num totalMoneyInDate = 0;

  DailyStayDatesController() {
    DateTime now = DateTime.now();
    staysDate = DateUtil.to12h(now);
    loadBasicBookings();
  }

  void setStayDates(DateTime date) {
    if (staysDate != null && DateUtil.equal(staysDate!, date)) return;

    staysDate = DateUtil.to12h(date);
    notifyListeners();
  }

  void loadBasicBookings() async {
    try {
      final Map<String, dynamic> mapContent = {};
      isLoading = true;
      notifyListeners();
      totalMoneyInDate = 0;
      bookings.clear();
      final Map<String, num> countRoomType = {};
      Query? initQuery =
          FirebaseHandler.hotelRef.collection(FirebaseHandler.colBasicBookings);
      initQuery = initQuery.where('stay_days', arrayContains: staysDate);
      if (statusID != null) {
        initQuery = initQuery.where('status', isEqualTo: statusID);
      }
      final snapshot = await initQuery.get();
      if (snapshot.docs.isNotEmpty) {
        for (var documentSnapshot in snapshot.docs) {
          final basicBooking = Booking.basicFromSnapshot(documentSnapshot);
          if (basicBooking.status == BookingStatus.repair ||
              basicBooking.status == BookingStatus.moved ||
              basicBooking.status == BookingStatus.cancel ||
              basicBooking.status == BookingStatus.noshow) continue;
          if (basicBooking.status == BookingStatus.booked ||
              basicBooking.status == BookingStatus.checkin ||
              basicBooking.status == BookingStatus.checkout) {
            totalMoneyInDate +=
                basicBooking.price![basicBooking.staydays!.indexOf(staysDate)];
          }
          if (countRoomType.containsKey(basicBooking.roomTypeID)) {
            countRoomType.addAll({
              basicBooking.roomTypeID!:
                  countRoomType[basicBooking.roomTypeID]! + 1
            });
          } else {
            countRoomType[basicBooking.roomTypeID!] = 1;
          }

          bookings.add(basicBooking);
          if (mapContent.containsKey('pay_at_hotel')) {
            if (mapContent['pay_at_hotel'][basicBooking.roomTypeID] == null) {
              mapContent['pay_at_hotel']
                  [basicBooking.roomTypeID] = {basicBooking.sourceID: 1};
            } else {
              if (mapContent['pay_at_hotel'][basicBooking.roomTypeID]
                      [basicBooking.sourceID] ==
                  null) {
                mapContent['pay_at_hotel'][basicBooking.roomTypeID]
                    [basicBooking.sourceID] = 1;
              } else {
                mapContent['pay_at_hotel'][basicBooking.roomTypeID]
                    [basicBooking.sourceID] += 1;
              }
            }
          } else {
            mapContent['pay_at_hotel'] = {
              basicBooking.roomTypeID: {basicBooking.sourceID: 1}
            };
          }

          if (mapContent.containsKey('prepaid')) {
            if (mapContent['prepaid'][basicBooking.roomTypeID] == null) {
              mapContent['prepaid']
                  [basicBooking.roomTypeID] = {basicBooking.sourceID: 1};
            } else {
              if (mapContent['prepaid'][basicBooking.roomTypeID]
                      [basicBooking.sourceID] ==
                  null) {
                mapContent['prepaid'][basicBooking.roomTypeID]
                    [basicBooking.sourceID] = 1;
              } else {
                mapContent['prepaid'][basicBooking.roomTypeID]
                    [basicBooking.sourceID] += 1;
              }
            }
          } else {
            mapContent['prepaid'] = {
              basicBooking.roomTypeID: {basicBooking.sourceID: 1}
            };
          }
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
    }
  }

  num getTotalBookingStay() {
    return bookings.length;
  }
}
