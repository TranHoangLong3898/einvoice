// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';
import '../../modal/booking.dart';
import '../../modal/electricitywater.dart';
import '../../modal/group.dart';
import '../../modal/status.dart';

class GroupController extends ChangeNotifier {
  List<Booking> bookings = [];
  late Booking bookingParent;
  StreamSubscription? subscriptionBooking;
  bool processing = false;
  Map<String, int> dataMeal = {};
  Map<String, Booking> bookingDpf = {};
  Map<String, String> mapData = {};
  Set<String> listMonth = {};
  Map<String, String> dataPriceByMonth = {};
  Map<String, Set<String>> staysMonth = {};
  List<Booking> bookingsAllDPF = [];
  List<Other> servicesOther = [];
  List<Electricity> servicesElectricity = [];
  List<Water> servicesWater = [];
  late DateTime startDate, endDate, now;
  bool isDeposit = false;
  bool isDepositAllBooking = false;
  String selectMonth = UITitleUtil.getTitleByCode(UITitleCode.ALL);
  //false = get all bookings, true = only get bookings with tax_declare = true
  bool isFilter = false;

  GroupController(String sID, bool isStatus) {
    print("Search Booking - $isStatus");
    now = DateTime.now();
    startDate = DateUtil.to0h(DateTime(now.year, now.month, 1));
    endDate = DateUtil.to24h(
        DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now)));
    processing = true;
    notifyListeners();
    subscriptionBooking = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBookings)
        .doc(sID)
        .snapshots()
        .listen((doc) {
      print("asyncGroupBookings: $sID");
      bookings.clear();
      bookingDpf.clear();
      bookingsAllDPF.clear();
      bookingParent = Booking.groupFromSnapshot(doc);
      for (var idSubBooking in bookingParent.subBookings!.keys) {
        bookings.add(Booking.fromBookingParent(idSubBooking, bookingParent));
        if (bookingParent.subBookings![idSubBooking]["status"] !=
                BookingStatus.cancel &&
            bookingParent.subBookings![idSubBooking]["status"] !=
                BookingStatus.noshow) {
          bookingDpf[idSubBooking] =
              Booking.fromBookingParent(idSubBooking, bookingParent);
          bookingsAllDPF
              .add(Booking.fromBookingParent(idSubBooking, bookingParent));
        }
      }
      if ((bookingParent.status != BookingStatus.cancel ||
              bookingParent.status != BookingStatus.noshow) &&
          isStatus) {
        bookings.removeWhere((booking) => !booking.isLiveBooking());
      }
      processing = false;
      notifyListeners();
    }, onDone: () => print('asyncGroupBookings: Done'), cancelOnError: true);
  }

  void cancelStream() {
    subscriptionBooking?.cancel();
  }

  num getTotalDeposit() => bookingParent.deposit!;
  num getTotalRoomCharge() => bookingParent.getRoomCharge(isGroup: true);
  num getTotalService() => bookingParent.getServiceCharge();
  num getTotalCharge() => bookingParent.getTotalCharge(isGroup: true)!;
  num getTotalRemaining() => bookingParent.getRemaining(isGroup: true)!;
  num getTotalDiscount() => bookingParent.discount!;
  num getTotalTranfferred() => bookingParent.transferred!;
  num getTotalTransfferring() => bookingParent.transferring!;

  Future<String?> checkInGroup() async {
    if (processing) return null;
    processing = true;
    notifyListeners();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('booking-checkInAllGroup')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'booking_sid': bookingParent.id,
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (error) {
      processing = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(error.message);
    }
    processing = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  Future<String?> checkOutGroup() async {
    if (processing) return null;
    processing = true;
    notifyListeners();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('booking-checkOutAllGroup')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'booking_id': bookingParent.id,
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (error) {
      processing = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(error.message);
    }
    processing = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

//todo
  Future noShowGroup() async {
    if (processing) return null;
    processing = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('booking-noShowBookingGroup')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': bookingParent.id,
    }).then((value) {
      processing = false;
      notifyListeners();
      return value.data;
    }).onError((error, stackTrace) {
      processing = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(
          (error as FirebaseFunctionsException).message, [bookingParent.name!]);
    });
  }

  Future cancelGroup() async {
    if (processing) return null;
    processing = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('booking-cancelBookingGroup')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': bookingParent.id,
    }).then((value) {
      processing = false;
      notifyListeners();
      return value.data;
    }).onError((error, stackTrace) {
      processing = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(
          (error as FirebaseFunctionsException).message, [bookingParent.name!]);
    });
  }

  num getAdult() => bookings.fold(0, (prev, booking) => prev + booking.adult!);
  num getChild() => bookings.fold(0, (prev, booking) => prev + booking.child!);
  String getRooms() => bookings.fold(
      '',
      (prev, booking) =>
          '$prev${RoomManager().getNameRoomById(booking.room!)}${booking.breakfast! ? '(B)' : '(NB)'},${booking.lunch! ? '(L)' : '(NL)'},${booking.dinner! ? '(D)' : '(ND)'}. ');

  Group getGroup() {
    return Group(
        name: bookingParent.name,
        adult: getAdult(),
        child: getChild(),
        deposit: bookingParent.deposit,
        email: bookingParent.email,
        sID: bookingParent.sID,
        inDate: bookingParent.inDate,
        outDate: bookingParent.outDate,
        payAtHotel: bookingParent.payAtHotel,
        phone: bookingParent.phone,
        remaining: bookingParent.getRemaining(isGroup: true),
        room: getRooms(),
        roomCharge: bookingParent.getRoomCharge(isGroup: true),
        sourceID: bookingParent.sourceID,
        subBookings: bookings,
        service: bookingParent.getServiceCharge(),
        discount: bookingParent.discount);
  }

  void setFilter() {
    isFilter = !isFilter;
    notifyListeners();
  }

  List<Booking> getBookingsByFilter() {
    return bookings
        .where((element) => !isFilter || element.isTaxDeclare == true)
        .toList()
      ..sort((a, b) => a.room!.compareTo(b.room!));
  }

  Map<Booking?, int> getBookingsByRoomtypeAndArrivalAndDeparturFilter() {
    dataMeal["breakfast"] = 0;
    dataMeal["lunch"] = 0;
    dataMeal["dinner"] = 0;
    Map<Booking?, int> result = {};
    for (var booking in bookings.toList()) {
      Booking? tempBooking = result.keys.firstWhere((e) {
        return e?.roomTypeID == booking.roomTypeID &&
            e?.inDate == booking.inDate &&
            e?.outDate == booking.outDate &&
            e?.price?[0] == booking.price?[0];
      }, orElse: () => null);
      if (tempBooking != null) {
        result[tempBooking] = result[tempBooking]! + 1;
        tempBooking.adult = (tempBooking.adult! + booking.adult!);
        tempBooking.child = (tempBooking.child! + booking.child!);
        tempBooking.lengthStay = booking.lengthStay;
        tempBooking.price = booking.price;
      } else {
        result[Booking.clone(booking)] = 1;
      }
      dataMeal["breakfast"] =
          dataMeal["breakfast"]! + (booking.breakfast! ? 1 : 0);
      dataMeal["lunch"] = dataMeal["lunch"]! + (booking.lunch! ? 1 : 0);
      dataMeal["dinner"] = (dataMeal["dinner"]! + (booking.dinner! ? 1 : 0));
    }
    return result;
  }

  Future<String?> getNoteForBooking() async {
    return bookings.first.getNotes();
  }

  num getAvegageRoomChargeByBooking(Booking booking) =>
      (booking.getRoomCharge() ~/ booking.lengthStay!).round();

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

  Set<String> listMonthByAllBookings() {
    listMonth.clear();
    for (var booking in bookings) {
      for (var date in booking.getDayByMonth()) {
        listMonth.add(date);
      }
    }
    return listMonth;
  }

  // Map<String, String> getRoomChargeBookingMonthDetail() {
  //   Map<String, String> mapData = {};
  //   List<num> totalRooms = [];
  //   for (Booking booking in bookings) {
  //     totalRooms.addAll(booking.price!);
  //     List<DateTime> dateTime = booking.getBookingByTypeMonth();
  //     String key =
  //         "${DateUtil.dateToMonthYearString(dateTime[0])} - ${DateUtil.dateToMonthYearString(dateTime[dateTime.length - 1])}";
  //     mapData.containsKey(key)
  //         ? mapData[key] =
  //             "${mapData[key]}, ${RoomManager().getNameRoomById(booking.room!)}"
  //         : mapData[key] = RoomManager().getNameRoomById(booking.room!);
  //   }
  //   mapData["total"] = (totalRooms.fold(
  //               0.0, (previousValue, element) => previousValue + element) /
  //           totalRooms.length)
  //       .toString();
  //   return mapData;
  // }

  void setMonth(String value) {
    if (value == selectMonth) return;
    selectMonth = value;
    notifyListeners();
  }

  Future<Booking> exportDpfAndExcel(String idBooking) async {
    servicesOther.clear();
    servicesElectricity.clear();
    servicesWater.clear();
    if (selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)) {
      if (selectMonth != UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
        int dayStart = int.parse(selectMonth.split(' - ')[0].split("/")[0]);
        int monthStart = int.parse(selectMonth.split(' - ')[0].split("/")[1]);
        int yearStart = int.parse(selectMonth.split(' - ')[0].split("/")[2]);

        int dayEnd = int.parse(selectMonth.split(' - ')[1].split("/")[0]);
        int monthEnd = int.parse(selectMonth.split(' - ')[1].split("/")[1]);
        int yearEnd = int.parse(selectMonth.split(' - ')[1].split("/")[2]);

        startDate = DateTime(yearStart, monthStart, dayStart);
        endDate = DateTime(yearEnd, monthEnd, dayEnd);
      }
      Map<String, dynamic>? dataService = {};
      num totalDeposit = 0;
      num totalDiscount = 0;
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(bookingDpf[idBooking]!.group!
              ? bookingDpf[idBooking]!.sID
              : bookingDpf[idBooking]!.id)
          .collection(FirebaseHandler.colServices)
          .get()
          .then((service) {
        for (var element in service.docs) {
          DateTime timeCreate = (element["created"] as Timestamp).toDate();
          if (((timeCreate.isAfter(startDate) &&
                      timeCreate.isBefore(endDate)) ||
                  (timeCreate.isBefore(bookingDpf[idBooking]!.inDate!) &&
                      int.parse(selectMonth) ==
                          bookingDpf[idBooking]!.inDate!.month) ||
                  (timeCreate.isAfter(bookingDpf[idBooking]!.outDate!) &&
                      int.parse(selectMonth) ==
                          bookingDpf[idBooking]!.outDate!.month)) &&
              element["room"] == bookingDpf[idBooking]!.room) {
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
      if (bookingDpf[idBooking]!.paymentDetails != null) {
        for (var data in bookingDpf[idBooking]!.paymentDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          DateTime timeCreate =
              DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(bookingDpf[idBooking]!.inDate!) &&
                  int.parse(selectMonth) ==
                      bookingDpf[idBooking]!.inDate!.month) ||
              (timeCreate.isAfter(bookingDpf[idBooking]!.outDate!) &&
                  int.parse(selectMonth) ==
                      bookingDpf[idBooking]!.outDate!.month)) {
            totalDeposit += num.parse(descArray[1]);
          }
        }
        isDeposit = totalDeposit > 0;
      }

      if (bookingDpf[idBooking]!.discountDetails != null) {
        for (var element in bookingDpf[idBooking]!.discountDetails!.values) {
          DateTime timeCreate =
              (element["modified_time"] as Timestamp).toDate();
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(bookingDpf[idBooking]!.inDate!) &&
                  int.parse(selectMonth) ==
                      bookingDpf[idBooking]!.inDate!.month) ||
              (timeCreate.isAfter(bookingDpf[idBooking]!.outDate!) &&
                  int.parse(selectMonth) ==
                      bookingDpf[idBooking]!.outDate!.month)) {
            totalDiscount += element["amount"];
          }
        }
      }

      bookingDpf[idBooking]!.minibar =
          dataService[ServiceManager.MINIBAR_CAT] ?? 0;
      bookingDpf[idBooking]!.extraGuest =
          dataService[ServiceManager.EXTRA_GUEST_CAT] ?? 0;
      bookingDpf[idBooking]!.laundry =
          dataService[ServiceManager.LAUNDRY_CAT] ?? 0;
      bookingDpf[idBooking]!.bikeRental =
          dataService[ServiceManager.BIKE_RENTAL_CAT] ?? 0;
      bookingDpf[idBooking]!.other = dataService[ServiceManager.OTHER_CAT] ?? 0;
      bookingDpf[idBooking]!.insideRestaurant =
          dataService[ServiceManager.INSIDE_RESTAURANT_CAT] ?? 0;
      bookingDpf[idBooking]!.outsideRestaurant =
          dataService[ServiceManager.OUTSIDE_RESTAURANT_CAT] ?? 0;
      bookingDpf[idBooking]!.deposit = totalDeposit;
      bookingDpf[idBooking]!.discount = totalDiscount;
      bookingDpf[idBooking]!.electricity =
          dataService[ServiceManager.ELECTRICITY_CAT] ?? 0;
      bookingDpf[idBooking]!.water = dataService[ServiceManager.WATER_CAT] ?? 0;
      int lengthStay = 1;
      List<DateTime> stayDayBookings = [];
      DateTime inDate = bookingDpf[idBooking]!.inDate!;
      DateTime outDate = bookingDpf[idBooking]!.outDate!;
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
      bookingDpf[idBooking]!.totalRoomCharge =
          selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? bookingDpf[idBooking]!.getRoomChargeByDateCostum(
                  inDate: DateTime(stayDayBookings.first.year,
                      stayDayBookings.first.month, stayDayBookings.first.day),
                  outDate: DateTime(stayDayBookings.last.year,
                      stayDayBookings.last.month, stayDayBookings.last.day + 1))
              : bookingDpf[idBooking]!.getRoomChargeByDate(
                  inDate: DateTime(stayDayBookings.first.year,
                      stayDayBookings.first.month, stayDayBookings.first.day),
                  outDate: DateTime(
                      stayDayBookings.last.year,
                      stayDayBookings.last.month,
                      stayDayBookings.last.day + 1));
      bookingDpf[idBooking]!.lengthRender = lengthStay;
    } else {
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(bookingDpf[idBooking]!.group!
              ? bookingDpf[idBooking]!.sID
              : bookingDpf[idBooking]!.id)
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
    return bookingDpf[idBooking]!;
  }

  Future<Group> exportAllBookingDpfAndExcel() async {
    servicesOther.clear();
    dataPriceByMonth.clear();
    mapData.clear();
    num totalServie = 0;
    num totalDeposit = 0;
    num totalDiscount = 0;
    num totalTransferred = 0;

    num totalPriceRoom = 0;
    for (var booking in bookingsAllDPF) {
      if (selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)) {
        int dayStart = int.parse(selectMonth.split(' - ')[0].split("/")[0]);
        int monthStart = int.parse(selectMonth.split(' - ')[0].split("/")[1]);
        int yearStart = int.parse(selectMonth.split(' - ')[0].split("/")[2]);

        int dayEnd = int.parse(selectMonth.split(' - ')[1].split("/")[0]);
        int monthEnd = int.parse(selectMonth.split(' - ')[1].split("/")[1]);
        int yearEnd = int.parse(selectMonth.split(' - ')[1].split("/")[2]);

        String key =
            "$selectMonth, ${booking.price![booking.getDayByMonth().toList().indexOf(selectMonth)]}";
        mapData.containsKey(key)
            ? mapData[key] =
                "${mapData[key]}, ${RoomManager().getNameRoomById(booking.room!)}"
            : mapData[key] = RoomManager().getNameRoomById(booking.room!);
        startDate = DateTime(yearStart, monthStart, dayStart);
        endDate = DateTime(yearEnd, monthEnd, dayEnd);
        await FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(booking.group! ? booking.sID : booking.id)
            .collection(FirebaseHandler.colServices)
            .get()
            .then((service) {
          for (var element in service.docs) {
            DateTime timeCreate = (element["created"] as Timestamp).toDate();
            if (((timeCreate.isAfter(startDate) &&
                        timeCreate.isBefore(endDate)) ||
                    (timeCreate.isBefore(booking.inDate!) &&
                        int.parse(selectMonth) == booking.inDate!.month) ||
                    (timeCreate.isAfter(booking.outDate!) &&
                        int.parse(selectMonth) == booking.outDate!.month)) &&
                element["room"] == booking.room) {
              totalServie += element.get("total");
              if (ServiceManager.OTHER_CAT == element.get("cat") &&
                  element.get("room") == booking.room) {
                servicesOther.add(Other.fromSnapshot(element));
              }
            }
          }
        });
        if (booking.paymentDetails != null) {
          for (var data in booking.paymentDetails!.values) {
            List<String> descArray = data.toString().split(specificCharacter);
            DateTime timeCreate =
                DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
            if ((timeCreate.isAfter(startDate) &&
                    timeCreate.isBefore(endDate)) ||
                (timeCreate.isBefore(booking.inDate!) &&
                    int.parse(selectMonth) == booking.inDate!.month) ||
                (timeCreate.isAfter(booking.outDate!) &&
                    int.parse(selectMonth) == booking.outDate!.month)) {
              totalDeposit += num.parse(descArray[1]);
            }
          }
          isDepositAllBooking = totalDeposit > 0;
        }
        if (booking.discountDetails != null) {
          for (var element in booking.discountDetails!.values) {
            DateTime timeCreate =
                (element["modified_time"] as Timestamp).toDate();
            if ((timeCreate.isAfter(startDate) &&
                    timeCreate.isBefore(endDate)) ||
                (timeCreate.isBefore(booking.inDate!) &&
                    int.parse(selectMonth) == booking.inDate!.month) ||
                (timeCreate.isAfter(booking.outDate!) &&
                    int.parse(selectMonth) == booking.outDate!.month)) {
              totalDiscount += element["amount"];
            }
          }
        }
        totalTransferred += booking.transferred!;
        List<DateTime> stayDayBookings = [];
        DateTime inDate = booking.inDate!;
        DateTime outDate = booking.outDate!;
        //SS
        if ((inDate.isAfter(startDate) ||
                inDate.isAtSameMomentAs(DateUtil.to12h(startDate))) &&
            outDate.isAfter(endDate)) {
          print("SS");
          stayDayBookings = DateUtil.getStaysDay(
              DateUtil.to12h(inDate), DateUtil.to12hDayAddOne(endDate));
        }

        //TS
        if (inDate.isBefore(startDate) && outDate.isAfter(endDate)) {
          print("TS");
          stayDayBookings = DateUtil.getStaysDay(
              DateUtil.to12h(startDate), DateUtil.to12hDayAddOne(endDate));
        }
        //ST
        if ((inDate.isAfter(startDate) ||
                inDate.isAtSameMomentAs(DateUtil.to12h(startDate))) &&
            (outDate.isBefore(endDate) ||
                outDate.isAtSameMomentAs(DateUtil.to12h(endDate)))) {
          print("ST");
          stayDayBookings = DateUtil.getStaysDay(
              DateUtil.to12h(inDate), DateUtil.to12h(outDate));
        }
        //TT
        if (inDate.isBefore(startDate) && outDate.isBefore(endDate)) {
          print("TT");
          stayDayBookings = DateUtil.getStaysDay(
              DateUtil.to12h(startDate),
              DateUtil.to12hDayAddOne(
                  DateTime(outDate.year, outDate.month, outDate.day - 1)));
        }
        num price = booking.getRoomChargeByDateCostum(
            inDate: DateTime(stayDayBookings.first.year,
                stayDayBookings.first.month, stayDayBookings.first.day),
            outDate: DateTime(stayDayBookings.last.year,
                stayDayBookings.last.month, stayDayBookings.last.day + 1));

        totalPriceRoom += price;
        String keys = "$selectMonth, $price";
        dataPriceByMonth.containsKey(keys)
            ? dataPriceByMonth[keys] =
                "${dataPriceByMonth[keys]}, ${RoomManager().getNameRoomById(booking.room!)}"
            : dataPriceByMonth[keys] =
                "$selectMonth, ${RoomManager().getNameRoomById(booking.room!)}";
      } else {
        for (int i = 0; i < listMonth.length; i++) {
          String key = "${listMonth.toList()[i]}, ${booking.price![i]}";
          mapData.containsKey(key)
              ? mapData[key] =
                  "${mapData[key]}, ${RoomManager().getNameRoomById(booking.room!)}"
              : mapData[key] = RoomManager().getNameRoomById(booking.room!);
          DateTime inDate = booking.inDate!;
          DateTime outDate = booking.outDate!;
          num price =
              booking.getRoomChargeByDate(inDate: inDate, outDate: outDate);
          String keys = "${listMonth.toList()[i]}, $price";
          dataPriceByMonth.containsKey(keys)
              ? dataPriceByMonth[keys] =
                  "${dataPriceByMonth[keys]}, ${RoomManager().getNameRoomById(booking.room!)}"
              : dataPriceByMonth[keys] =
                  "${listMonth.toList()[i]}, ${RoomManager().getNameRoomById(booking.room!)}";
        }
        await FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(booking.group! ? booking.sID : booking.id)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.OTHER_CAT)
            .get()
            .then((service) {
          for (var element in service.docs) {
            if (booking.room == element.get("room")) {
              servicesOther.add(Other.fromSnapshot(element));
            }
          }
        });
      }
    }
    dataPriceByMonth = reverseMap(dataPriceByMonth);
    notifyListeners();
    print(
        "$totalPriceRoom ==$totalServie== $totalTransferred=== $totalDiscount ===$totalDeposit");
    print(totalPriceRoom +
        totalServie +
        totalTransferred -
        totalDiscount -
        totalDeposit);
    return Group(
        name: bookingParent.name,
        adult: getAdult(),
        child: getChild(),
        deposit: totalDeposit,
        email: bookingParent.email,
        sID: bookingParent.sID,
        inDate: bookingParent.inDate,
        outDate: bookingParent.outDate,
        payAtHotel: bookingParent.payAtHotel,
        phone: bookingParent.phone,
        remaining: totalPriceRoom +
            totalTransferred -
            totalDiscount -
            (totalDeposit / bookingsAllDPF.length),
        room: getRooms(),
        roomCharge: totalPriceRoom,
        sourceID: bookingParent.sourceID,
        subBookings: bookings,
        service: totalServie,
        discount: totalDiscount);
  }

  Map<String, String> reverseMap(Map<String, String> map) {
    return {for (var e in map.keys) map[e]!: e};
  }

  Map<String, Set<String>> getDayByMonth() {
    staysMonth.clear();
    for (var booking in bookings) {
      staysMonth[booking.id!] = {};
      DateTime inDate = booking.inDate!;
      DateTime outDate = booking.outDate!;
      List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
      List<DateTime> staysDayMonth = booking.getBookingByTypeMonth();
      int index = 0;
      DateTime lastDay = outDate;
      bool check = false;
      for (var i = 1; i < staysDayMonth.length; i++) {
        lastDay = DateTime(
            (inDate.year == outDate.year ? outDate.year : inDate.year),
            inDate.month + i,
            inDate.day - 1,
            inDate.hour);
        if (data.contains(lastDay)) {
          staysMonth[booking.id!]!.add(
              "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index, inDate.day))} - ${DateUtil.dateToDayMonthYearString(lastDay)}");
          check = true;
          index++;
        }
      }
      DateTime lastOutDate =
          DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
      if (lastOutDate.isBefore(outDate) || lastOutDate.isAfter(outDate)) {
        if (check) {
          staysMonth[booking.id!]!.remove(
              "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index - 1, inDate.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(lastDay.year, lastDay.month, lastDay.day, 12))}");
        }
        staysMonth[booking.id!]!.add(
            "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index - (check ? 1 : 0), inDate.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
      }
    }
    print(staysMonth);
    return staysMonth;
  }
}
