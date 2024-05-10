// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../modal/booking.dart';
import '../../modal/electricitywater.dart';

class CheckOutController extends ChangeNotifier {
  Booking booking;
  late Booking bookingDpf;
  late DateTime startDate, endDate, now;
  bool isDeposit = false;
  StreamSubscription? subscription;
  bool isLoading = false;
  String selectMonth = UITitleUtil.getTitleByCode(UITitleCode.ALL);
  List<Other> servicesOther = [];
  List<Electricity> servicesElectricity = [];
  List<Water> servicesWater = [];
  Set<String> staysMonth = {};
  CheckOutController(this.booking) {
    now = DateTime.now();
    startDate = DateUtil.to0h(DateTime(now.year, now.month, 1));
    endDate = DateUtil.to24h(
        DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now)));
    isLoading = true;
    notifyListeners();
    subscription = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBookings)
        .doc(booking.id)
        .snapshots()
        .listen((doc) {
      print("asyncBooking: ${booking.id}");
      booking = Booking.fromSnapshot(doc);
      bookingDpf = Booking.fromSnapshot(doc);
      isLoading = false;
      notifyListeners();
    }, onDone: () => print('asyncBooking: Done'), cancelOnError: true);
  }

  Future<String> checkOut() async {
    if (booking == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.BOOKING_NOT_FOUND);
    }
    isLoading = true;
    notifyListeners();

    String result = booking.isVirtual!
        ? await booking.checkOutVirtual().then((value) => value).onError(
            (error, stackTrace) => (error as FirebaseException).message!)
        : await booking.checkOut().then((value) => value).onError(
            (error, stackTrace) => (error as FirebaseException).message!);
    isLoading = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(
        result, [booking.getRemaining().toString()]);
  }

  void cancelStream() {
    subscription?.cancel();
  }

  void setMonth(String value) {
    if (value == selectMonth) return;
    selectMonth = value;
    notifyListeners();
  }

  Future<Booking> exportDpfAndExcel() async {
    servicesOther.clear();
    servicesElectricity.clear();
    servicesWater.clear();
    if (selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)) {
      int monthS = 1;
      int monthE = 1;
      if (selectMonth != UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
        int dayStart = int.parse(selectMonth.split(' - ')[0].split("/")[0]);
        int monthStart = int.parse(selectMonth.split(' - ')[0].split("/")[1]);
        int yearStart = int.parse(selectMonth.split(' - ')[0].split("/")[2]);

        int dayEnd = int.parse(selectMonth.split(' - ')[1].split("/")[0]);
        int monthEnd = int.parse(selectMonth.split(' - ')[1].split("/")[1]);
        int yearEnd = int.parse(selectMonth.split(' - ')[1].split("/")[2]);

        startDate = DateTime(yearStart, monthStart, dayStart);
        endDate = DateTime(yearEnd, monthEnd, dayEnd);
        monthS = monthStart;
        monthE = monthEnd;
      } else {
        monthS = startDate.month;
        monthE = endDate.month;
      }
      Map<String, dynamic>? dataService = {};
      num totalDeposit = 0;
      num totalDiscount = 0;
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(bookingDpf.group! ? bookingDpf.sID : bookingDpf.id)
          .collection(FirebaseHandler.colServices)
          .get()
          .then((service) {
        for (var element in service.docs) {
          DateTime timeCreate = (element["created"] as Timestamp).toDate();
          if (((timeCreate.isAfter(startDate) &&
                      timeCreate.isBefore(endDate)) ||
                  (timeCreate.isBefore(bookingDpf.inDate!) &&
                      monthS == bookingDpf.inDate!.month) ||
                  (timeCreate.isAfter(bookingDpf.outDate!) &&
                      monthS == bookingDpf.outDate!.month)) &&
              element["room"] == bookingDpf.room) {
            if (dataService.containsKey(element.get("cat"))) {
              dataService[element.get("cat")] += element.get("total");
            } else {
              dataService[element.get("cat")] = element.get("total");
            }
            if (ServiceManager.OTHER_CAT == element.get("cat")) {
              servicesOther.add(Other.fromSnapshot(element));
            }
            if (ServiceManager.ELECTRICITY_CAT == element.get("cat")) {
              servicesElectricity.add(Electricity.fromSnapshot(element));
            }
            if (ServiceManager.WATER_CAT == element.get("cat")) {
              servicesWater.add(Water.fromSnapshot(element));
            }
          }
        }
      });
      if (bookingDpf.paymentDetails != null) {
        for (var data in bookingDpf.paymentDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          DateTime timeCreate =
              DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(bookingDpf.inDate!) &&
                  (monthS == bookingDpf.inDate!.month ||
                      monthE == bookingDpf.inDate!.month)) ||
              (timeCreate.isAfter(bookingDpf.outDate!) &&
                  (monthS == bookingDpf.outDate!.month ||
                      monthE == bookingDpf.outDate!.month))) {
            totalDeposit += num.parse(descArray[1]);
          }
        }
        isDeposit = totalDeposit > 0;
      }

      if (bookingDpf.discountDetails != null) {
        for (var element in bookingDpf.discountDetails!.values) {
          DateTime timeCreate =
              (element["modified_time"] as Timestamp).toDate();
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(bookingDpf.inDate!) &&
                  monthS == bookingDpf.inDate!.month) ||
              (timeCreate.isAfter(bookingDpf.outDate!) &&
                  monthS == bookingDpf.outDate!.month)) {
            totalDiscount += element["amount"];
          }
        }
      }
      bookingDpf.minibar = dataService[ServiceManager.MINIBAR_CAT] ?? 0;
      bookingDpf.extraGuest = dataService[ServiceManager.EXTRA_GUEST_CAT] ?? 0;
      bookingDpf.laundry = dataService[ServiceManager.LAUNDRY_CAT] ?? 0;
      bookingDpf.bikeRental = dataService[ServiceManager.BIKE_RENTAL_CAT] ?? 0;
      bookingDpf.other = dataService[ServiceManager.OTHER_CAT] ?? 0;
      bookingDpf.insideRestaurant =
          dataService[ServiceManager.INSIDE_RESTAURANT_CAT] ?? 0;
      bookingDpf.outsideRestaurant =
          dataService[ServiceManager.OUTSIDE_RESTAURANT_CAT] ?? 0;
      bookingDpf.electricity = dataService[ServiceManager.ELECTRICITY_CAT] ?? 0;
      bookingDpf.water = dataService[ServiceManager.WATER_CAT] ?? 0;
      bookingDpf.deposit = totalDeposit;
      bookingDpf.discount = totalDiscount;
      int lengthStay = 1;
      List<DateTime> stayDayBookings = [];
      DateTime inDate = bookingDpf.inDate!;
      DateTime outDate = bookingDpf.outDate!;
      //SS
      if ((inDate.isAfter(startDate) ||
              inDate.isAtSameMomentAs(DateUtil.to12h(startDate))) &&
          outDate.isAfter(endDate)) {
        print("SS");
        lengthStay = DateUtil.to12hDayAddOne(endDate)
            .difference(DateUtil.to12h(inDate))
            .inDays;
        stayDayBookings = DateUtil.getStaysDay(
            DateUtil.to12h(inDate), DateUtil.to12hDayAddOne(endDate));
      }

      //TS
      if (inDate.isBefore(startDate) && outDate.isAfter(endDate)) {
        print("TS");
        lengthStay = DateUtil.to12hDayAddOne(endDate)
            .difference(DateUtil.to12h(startDate))
            .inDays;
        stayDayBookings = DateUtil.getStaysDay(
            DateUtil.to12h(startDate), DateUtil.to12hDayAddOne(endDate));
      }
      //ST
      if ((inDate.isAfter(startDate) ||
              inDate.isAtSameMomentAs(DateUtil.to12h(startDate))) &&
          (outDate.isBefore(endDate) ||
              outDate.isAtSameMomentAs(DateUtil.to12h(endDate)))) {
        print("ST");
        lengthStay = (inDate.month != outDate.month
                ? DateUtil.to12hDayAddOne(outDate)
                : DateUtil.to12h(outDate))
            .difference(DateUtil.to12h(inDate))
            .inDays;
        stayDayBookings = DateUtil.getStaysDay(
            DateUtil.to12h(inDate), DateUtil.to12h(outDate));
      }
      //TT
      if (inDate.isBefore(startDate) && outDate.isBefore(endDate)) {
        print("TT");
        lengthStay = DateUtil.to12hDayAddOne(outDate)
            .difference(DateUtil.to12h(startDate))
            .inDays;
        stayDayBookings = DateUtil.getStaysDay(
            DateUtil.to12h(startDate),
            DateUtil.to12hDayAddOne(
                DateTime(outDate.year, outDate.month, outDate.day - 1)));
      }
      print("$startDate ==== $endDate");
      bookingDpf.totalRoomCharge =
          selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? bookingDpf.getRoomChargeByDateCostum(
                  inDate: DateTime(stayDayBookings.first.year,
                      stayDayBookings.first.month, stayDayBookings.first.day),
                  outDate: DateTime(stayDayBookings.last.year,
                      stayDayBookings.last.month, stayDayBookings.last.day + 1))
              : bookingDpf.getRoomChargeByDate(
                  inDate: DateTime(stayDayBookings.first.year,
                      stayDayBookings.first.month, stayDayBookings.first.day),
                  outDate: DateTime(
                      stayDayBookings.last.year,
                      stayDayBookings.last.month,
                      stayDayBookings.last.day + 1));
      bookingDpf.lengthRender = lengthStay;
    } else {
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(bookingDpf.group! ? bookingDpf.sID : bookingDpf.id)
          .collection(FirebaseHandler.colServices)
          .get()
          .then((service) {
        for (var element in service.docs) {
          if (ServiceManager.OTHER_CAT == element.get("cat")) {
            servicesOther.add(Other.fromSnapshot(element));
          }
          if (ServiceManager.ELECTRICITY_CAT == element.get("cat")) {
            servicesElectricity.add(Electricity.fromSnapshot(element));
          }
          if (ServiceManager.WATER_CAT == element.get("cat")) {
            servicesWater.add(Water.fromSnapshot(element));
          }
        }
      });
    }
    notifyListeners();
    return bookingDpf;
  }

  void setStartDate(DateTime newDate) {
    newDate = DateUtil.to0h(newDate);
    if (DateUtil.equal(newDate, startDate)) return;
    startDate = newDate;
    if (endDate.isBefore(startDate)) {
      endDate = DateUtil.to24h(newDate);
    } else if (endDate.difference(startDate).inDays > 31) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 31)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    newDate = DateUtil.to24h(newDate);
    if (DateUtil.equal(newDate, endDate)) return;
    if (newDate.compareTo(startDate) < 0) return;
    if (newDate.difference(startDate).inDays > 61) return;
    endDate = newDate;
    notifyListeners();
  }

  List<String> getDayByMonth() {
    DateTime inDate = bookingDpf.inDate!;
    DateTime outDate = bookingDpf.outDate!;
    List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
    List<DateTime> staysDayMonth = bookingDpf.getBookingByTypeMonth();
    int index = 0;
    DateTime lastDay = outDate;
    bool check = false;
    staysMonth.clear();
    for (var i = 1; i < staysDayMonth.length; i++) {
      lastDay = DateTime(
          (inDate.year == outDate.year ? outDate.year : inDate.year),
          inDate.month + i,
          inDate.day - 1,
          inDate.hour);
      if (data.contains(lastDay)) {
        staysMonth.add(
            "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index, inDate.day))} - ${DateUtil.dateToDayMonthYearString(lastDay)}");
        check = true;
        index++;
      }
    }
    DateTime lastOutDate =
        DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
    if (lastOutDate.isBefore(outDate) || lastOutDate.isAfter(outDate)) {
      if (check) {
        staysMonth.remove(
            "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index - 1, inDate.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(lastDay.year, lastDay.month, lastDay.day, 12))}");
      }
      staysMonth.add(
          "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index - (check ? 1 : 0), inDate.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
    }
    return staysMonth.toList();
  }
}
