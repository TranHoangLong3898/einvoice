import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/modal/status.dart';
import '../../manager/accountingtypemanager.dart';
import '../../manager/generalmanager.dart';
import '../../manager/paymentmethodmanager.dart';
import '../../manager/roommanager.dart';
import '../../manager/roomtypemanager.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';

class RevenueReportController extends ChangeNotifier {
  int? maxTimePeriod;
  late DateTime startDate, endDate;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery, preQuery;
  bool? forward, isLoading = false;
  num revenueTotal = 0;
  final int pageSize = 10;

  late num rChargeTotal,
      minibarTotal,
      extraHourTotal,
      extraGuestTotal,
      electricityTotal,
      waterTotal,
      laudryTotal,
      bikeRentalTotal,
      otherTotal,
      restaurantTotal,
      insideRestaurantTotal,
      discountTotal,
      mountnGuestTotal,
      verageRatetotal,
      occTotal,
      roomAvailableTotal,
      roomTotal,
      roomSoldTotal,
      costTotal = 0;

  List<Booking> bookings = [];
  Set<String> setRoomType = {};
  Set<String> dataSetMethod = {};
  Set<String> dataSetTypeCost = {};

  RevenueReportController() {
    DateTime now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    maxTimePeriod = GeneralManager.hotel!.isAdvPackage() ? 30 : 7;
    loadRevenues();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to0h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to24h(startDate);
    if (endDate.difference(startDate) > Duration(days: maxTimePeriod!)) {
      endDate = DateUtil.to24h(startDate.add(Duration(days: maxTimePeriod!)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to24h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  Query getInitQueryBookingByOutDateRange(DateTime start, DateTime end) {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('out_time', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('out_time', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('status', isEqualTo: BookingStatus.checkout)
        .orderBy('out_time');
  }

  void updateRevenuesAndQueries(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      for (var documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> snapshotData =
            documentSnapshot.data() as Map<String, dynamic>;
        if (snapshotData.containsKey('group') &&
            documentSnapshot.get('group')) {
          Booking bookingGroup = Booking.groupFromSnapshot(documentSnapshot);
          bookingGroup.status = BookingStatus.checkout;
          int lengthStay = 0;
          for (var subBooking in bookingGroup.subBookings!.entries) {
            if (subBooking.value['status'] == BookingStatus.cancel ||
                subBooking.value['status'] == BookingStatus.noshow) {
              continue;
            }
            Booking subBookingTepm =
                Booking.fromBookingParent(subBooking.key, bookingGroup);
            lengthStay += subBookingTepm.lengthStay!;
            setRoomType.add(RoomTypeManager()
                .getRoomTypeNameByID(subBooking.value['room_type']));
          }
          bookingGroup.lengthStay = lengthStay;
          bookingGroup.roomTypeID = getListRoomTypeForGroup();
          // if (bookingGroup.lengthStay != 0) {
          //   bookings.add(bookingGroup);
          // }
          bookings.add(bookingGroup);
        } else {
          bookings.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      snapshotTepm = querySnapshot;
      if (querySnapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
              .endBeforeDocument(querySnapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
              .startAfterDocument(querySnapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
            .startAfterDocument(querySnapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQueryBookingByOutDateRange(startDate, endDate)
            .endBeforeDocument(querySnapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void loadRevenues() async {
    isLoading = true;
    notifyListeners();
    bookings.clear();
    await getTotalRevenue();
    getInitQueryBookingByOutDateRange(startDate, endDate)
        .limit(pageSize)
        .get()
        .then((QuerySnapshot querySnapshot) {
      updateRevenuesAndQueries(querySnapshot);
    });
  }

  void getRevenueReportNextPage() async {
    if (nextQuery == null) return;
    isLoading = true;
    notifyListeners();
    bookings.clear();
    forward = true;
    nextQuery!.get().then((value) => updateRevenuesAndQueries(value));
  }

  void getRevenueReportPreviousPage() async {
    if (preQuery == null) return;
    isLoading = true;
    notifyListeners();
    bookings.clear();
    forward = false;
    preQuery!.get().then((value) => updateRevenuesAndQueries(value));
  }

  void getRevenueReportFirstPage() {
    isLoading = true;
    notifyListeners();
    bookings.clear();
    getInitQueryBookingByOutDateRange(startDate, endDate)
        .limit(pageSize)
        .get()
        .then((QuerySnapshot querySnapshot) {
      updateRevenuesAndQueries(querySnapshot);
      preQuery = null;
    });
  }

  void getRevenueReportLastPage() {
    isLoading = true;
    notifyListeners();
    bookings.clear();
    getInitQueryBookingByOutDateRange(startDate, endDate)
        .limitToLast(pageSize)
        .get()
        .then((QuerySnapshot querySnapshot) {
      updateRevenuesAndQueries(querySnapshot);
      nextQuery = null;
    });
  }

  // get revenue from daily data
  Future<void> getTotalRevenue() async {
    final dailyData = await FirebaseHandler().getDailyData(startDate, endDate);
    if (dailyData.isEmpty) {
      revenueTotal = 0;
    } else {
      revenueTotal = dailyData
          .where((element) => element['revenue'] != null)
          .fold(
              0,
              (previousValue, element) =>
                  previousValue + element['revenue']['total']);
    }
  }

  Future<String> updateStatusInvoice(Booking booking) async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('booking-updateStatusInvoice')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': booking.id,
          'booking_sid': booking.sID,
          'is_group': booking.group,
          'statusinvoice': booking.statusinvoice,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
          loadRevenues();
        });
  }

  Future<List<Booking>> getAllBookingForExporting() async {
    List<Booking> result = [];
    await getInitQueryBookingByOutDateRange(startDate, endDate)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> snapshotData =
            documentSnapshot.data() as Map<String, dynamic>;
        if (snapshotData.containsKey('group') &&
            documentSnapshot.get('group')) {
          Booking bookingGroup = Booking.groupFromSnapshot(documentSnapshot);
          bookingGroup.status = BookingStatus.checkout;
          int lengthStay = 0;
          for (var subBooking in bookingGroup.subBookings!.entries) {
            if (subBooking.value['status'] == BookingStatus.cancel ||
                subBooking.value['status'] == BookingStatus.noshow) {
              continue;
            }
            Booking subBookingTepm =
                Booking.fromBookingParent(subBooking.key, bookingGroup);
            lengthStay += subBookingTepm.lengthStay!;
          }
          bookingGroup.lengthStay = lengthStay;
          bookingGroup.roomTypeID = getListRoomTypeForGroup();
          result.add(bookingGroup);
        } else {
          result.add(Booking.fromSnapshot(documentSnapshot));
        }
      }
      rChargeTotal = result.fold(0,
          (previousValue, element) => previousValue + element.getRoomCharge());
      minibarTotal = result.fold(
          0, (previousValue, element) => previousValue + element.minibar!);
      extraHourTotal = result.fold(
          0,
          (previousValue, element) =>
              previousValue + element.extraHour!.total!);
      electricityTotal = result.fold(
          0, (previousValue, element) => previousValue + element.electricity!);
      waterTotal = result.fold(
          0.0, (previousValue, element) => previousValue + element.water!);
      extraGuestTotal = result.fold(
          0, (previousValue, element) => previousValue + element.extraGuest!);
      laudryTotal = result.fold(
          0, (previousValue, element) => previousValue + element.laundry);
      bikeRentalTotal = result.fold(
          0, (previousValue, element) => previousValue + element.bikeRental!);
      otherTotal = result.fold(
          0, (previousValue, element) => previousValue + element.other!);
      restaurantTotal = result.fold(
          0,
          (previousValue, element) =>
              previousValue + element.outsideRestaurant!);
      insideRestaurantTotal = result.fold(
          0,
          (previousValue, element) =>
              previousValue + element.insideRestaurant!);
      discountTotal = result.fold(
          0, (previousValue, element) => previousValue + element.discount!);

      mountnGuestTotal = result
              .where((element) => element.sourceID != "virtual")
              .fold(
                  0,
                  (previousValue, element) =>
                      previousValue + (element.adult as int)) +
          result.where((element) => element.sourceID != "virtual").fold(
              0, (previousValue, element) => previousValue + element.child!);

      roomSoldTotal =
          (result.where((element) => element.group == false).length +
              result.where((element) => element.group == true).fold(
                  0,
                  (previousValue, element) =>
                      previousValue +
                      (element.room!
                          .split(",")
                          .where((element) => element != " ")
                          .length)));

      roomTotal = RoomManager().rooms!.length *
          (endDate.difference(startDate).inDays + 1);

      roomAvailableTotal = roomTotal - roomSoldTotal;

      verageRatetotal = result.fold(
              0.0, (pre, data) => pre + (data.getRoomCharge() as double)) /
          result.fold(0.0, (pre, data) => pre + data.lengthStay!);

      occTotal = roomSoldTotal / roomTotal * 100;
    });
    costTotal = 0;
    for (var element in result) {
      costTotal += element.getTotalAmountCost();
      if (element.paymentDetails != null) {
        for (var data in element.paymentDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          if (descArray[0].isNotEmpty) {
            dataSetMethod.add(
                PaymentMethodManager().getPaymentMethodNameById(descArray[0]));
          }
        }
        for (var data in element.costDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          if (descArray[0].isNotEmpty) {
            dataSetTypeCost
                .add(AccountingTypeManager.getNameById(descArray[0])!);
          }
        }
      }
    }
    return result;
  }

  num get getAllSeverTotal =>
      (rChargeTotal +
          bikeRentalTotal +
          extraGuestTotal +
          electricityTotal +
          waterTotal +
          extraHourTotal +
          insideRestaurantTotal +
          restaurantTotal +
          minibarTotal +
          laudryTotal +
          otherTotal) -
      discountTotal;

  num getAverageRoomRate(Booking booking) {
    if (booking.getRoomCharge() == 0) return 0;
    return (booking.getRoomCharge() / booking.lengthStay!).round();
  }

  String getListRoomTypeForGroup() {
    String roomType = '';
    for (var element in setRoomType) {
      roomType += "$element, ";
    }
    return roomType;
  }
}
