import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../handler/firebasehandler.dart';
import '../../modal/activity.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';

class LogBookingController extends ChangeNotifier {
  late DateTime startDate, endDate;
  DateTime now = DateTime.now();
  Map<String, Activity> activities = {};
  bool isLoading = false;
  DocumentSnapshot? lastActivityQueried;

  LogBookingController() {
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    getActivitiesFromCloud();
  }

  void getActivitiesFromCloud() {
    isLoading = true;
    notifyListeners();
    print('Starting get activities from cloud: ${DateTime.now()}');
    FirebaseHandler.hotelRef
        .collection('activities')
        .orderBy('id', descending: true)
        .get()
        .then((event) async {
      if (event.docs.isNotEmpty) {
        activities.clear();
        for (var element in event.docs) {
          lastActivityQueried = element;
          for (int i = lastActivityQueried!.get('activities').length - 1;
              i >= 0;
              i--) {
            Activity item =
                Activity.fromJson(lastActivityQueried!.get('activities')[i]);
            activities[
                    '${lastActivityQueried!.id}${item.createdTime.seconds * Random().nextInt(100)}'] =
                item;
          }
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void setStartDate(DateTime date) {
    DateTime newStart = DateUtil.to0h(date);
    if (startDate.isAtSameMomentAs(newStart)) return;
    startDate = newStart;
    if (startDate.isAfter(endDate)) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate).inDays > 7) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 7)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    if (DateUtil.equal(date, endDate)) return;
    DateTime newEnd = DateUtil.to24h(date);
    if (endDate.isAtSameMomentAs(newEnd) || newEnd.isBefore(startDate)) return;
    endDate = newEnd;
    notifyListeners();
  }

  Iterable<String> getLogBookingUserByDate(String email) {
    return activities.keys.toList().where((element) {
      return activities[element]!.email == email &&
          activities[element]!.createdTime.toDate().isAfter(startDate) &&
          activities[element]!.createdTime.toDate().isBefore(endDate);
    });
  }

  Iterable<String> getLogBooking(Booking booking, bool isGroup) {
    return isGroup
        ? activities.keys
            .toList()
            .where((element) => activities[element]!.bookingId == booking.sID)
            .where((element) =>
                activities[element]!.type == "service" ||
                activities[element]!.type == "deposit")
        : activities.keys
            .toList()
            .where((element) => activities[element]!.bookingId == booking.id);
  }

  Future<Booking?> getBookingDetailByID(String id, String type) async {
    Booking? bookings;
    String collection = (type == "deposit" || type == "service")
        ? FirebaseHandler.colBookings
        : FirebaseHandler.colBasicBookings;
    await FirebaseHandler.hotelRef
        .collection(collection)
        .doc(id)
        .get()
        .then((event) async {
      if (event.exists) {
        bool checkGroup =
            event.get("group") && collection == FirebaseHandler.colBookings;
        bookings = checkGroup
            ? Booking.groupFromSnapshot(event)
            : Booking.basicFromSnapshot(event);
        if (checkGroup) bookings!.declareGuests = [];
      }
    });
    notifyListeners();
    return bookings;
  }
}
