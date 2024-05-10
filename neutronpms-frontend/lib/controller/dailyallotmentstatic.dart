import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:intl/intl.dart';

import '../handler/firebasehandler.dart';
import '../manager/roommanager.dart';
import '../manager/roomtypemanager.dart';
import '../util/dateutil.dart';

class DailyAllotmentStatic extends ChangeNotifier {
  DailyAllotmentStatic._singleton();

  static final DailyAllotmentStatic _instance =
      DailyAllotmentStatic._singleton();

  factory DailyAllotmentStatic() {
    return _instance;
  }

  late String _monthIDFirstDay;
  late String _monthIDLastDay;
  StreamSubscription? dailyAllotmentSubscription;
  Map<String, dynamic> dailyAllotments = {};

  void cancel() {
    dailyAllotmentSubscription?.cancel();
    dailyAllotments = {};
  }

  void changeHotel() {
    _monthIDFirstDay = '';
    _monthIDLastDay = '';
    dailyAllotments.clear();
  }

  void listenDailyAllotmentFromCloud(DateTime currentDate) {
    String startMonthID = DateUtil.dateToShortStringYearMonth(
        currentDate.subtract(const Duration(days: 1)));
    String endMonthID = DateUtil.dateToShortStringYearMonth(
        currentDate.add(Duration(days: GeneralManager.sizeDatesForBoard - 1)));
    if (startMonthID == endMonthID) {
      if (startMonthID != _monthIDFirstDay && endMonthID != _monthIDLastDay) {
        _monthIDFirstDay = startMonthID;
        _monthIDLastDay = endMonthID;
        dailyAllotmentSubscription?.cancel();
        dailyAllotmentSubscription = FirebaseHandler.hotelRef
            .collection('daily_allotment')
            .doc(_monthIDFirstDay)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            dailyAllotments[snapshot.id] = snapshot.get('data');
          }
          notifyListeners();
        });
      }
    } else {
      if (startMonthID != _monthIDFirstDay || endMonthID != _monthIDLastDay) {
        _monthIDFirstDay = startMonthID;
        _monthIDLastDay = endMonthID;
        dailyAllotmentSubscription?.cancel();
        dailyAllotmentSubscription = FirebaseHandler.hotelRef
            .collection('daily_allotment')
            .where(FieldPath.documentId,
                whereIn: [_monthIDFirstDay, _monthIDLastDay])
            .snapshots()
            .listen((snapshot) {
              if (snapshot.size != 0) {
                for (var dailyBooked in snapshot.docs) {
                  dailyAllotments[dailyBooked.id] = dailyBooked.get('data');
                }
              }
              notifyListeners();
            });
      }
    }
  }

  num getTotalCurrentBookingWithDate(DateTime date) {
    String monthID = DateUtil.dateToShortStringYearMonth(date);
    String dayID = date.day.toString();
    if (dailyAllotments[monthID] == null) {
      return 0;
    }
    Map<String, dynamic> dailyAllotmentInOneDay =
        Map.from(dailyAllotments[monthID][dayID]);
    dailyAllotmentInOneDay.removeWhere((key, value) => key == 'booked');
    dailyAllotmentInOneDay.removeWhere((key, value) => key == 'non_room');
    return dailyAllotmentInOneDay.values
        .where((element) => element['occ'] != null)
        .fold(0, (previousValue, element) => previousValue + element['occ']);
  }

  num getTotalCurrentBookingNonRoomWithDate(DateTime date) {
    String monthID = DateUtil.dateToShortStringYearMonth(date);
    String dayID = date.day.toString();
    if (dailyAllotments[monthID] == null) {
      return 0;
    }
    Map<String, dynamic> dailyAllotmentInOneDay =
        Map.from(dailyAllotments[monthID][dayID]);
    dailyAllotmentInOneDay.removeWhere((key, value) => key == 'booked');
    return dailyAllotmentInOneDay["non_room"] ?? 0;
  }

  String getTotalRoomWithDate(DateTime date) {
    String monthID = DateUtil.dateToShortStringYearMonth(date);
    String dayID = date.day.toString();
    if (dailyAllotments[monthID] == null) {
      return '0';
    }
    Map<String, dynamic> dailyAllotmentInOneDay =
        Map.from(dailyAllotments[monthID][dayID]);
    dailyAllotmentInOneDay.removeWhere((key, value) => key == 'booked');
    dailyAllotmentInOneDay.removeWhere((key, value) => key == 'non_room');
    return dailyAllotmentInOneDay.values
        .fold(0.0,
            (previousValue, element) => previousValue + (element['num'] ?? 0))
        .toString();
  }

  Future<void> getDailyAllotments(
      List<DateTime> stayDates, Map<String, dynamic> dailyAllotmentTepm) async {
    String inMonthID = DateUtil.dateToShortStringYearMonth(stayDates.first);
    String outMonthID = DateUtil.dateToShortStringYearMonth(stayDates.last);
    String dynamidInmonth =
        DateUtil.dateToShortStringYearMonth(stayDates.first);
    do {
      if (dailyAllotments[dynamidInmonth] == null) {
        final snapshot = await FirebaseHandler.hotelRef
            .collection('daily_allotment')
            .doc(dynamidInmonth)
            .get();
        dailyAllotmentTepm[dynamidInmonth] = snapshot.get('data');
      } else {
        dailyAllotmentTepm[dynamidInmonth] = dailyAllotments[dynamidInmonth];
      }
      dynamidInmonth = DateUtil.addMonthToYearMonth(dynamidInmonth);
    } while (dynamidInmonth != DateUtil.addMonthToYearMonth(outMonthID) &&
        inMonthID != outMonthID);
  }

  Future<List<dynamic>> getDailyAllotmentsByDate(
      DateTime startDate, DateTime endDate) async {
    final inDay = startDate.day;
    final outDay = endDate.day;
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    List<dynamic> result = [];
    if (inMonthId == outMonthId) {
      await FirebaseHandler.hotelRef
          .collection('daily_allotment')
          .doc(inMonthId)
          .get()
          .then((snapshot) {
        final data = snapshot.data()!['data'] as Map<String, dynamic>;
        for (var keyOfData in data.keys) {
          if (keyOfData == "default") continue;
          if (num.parse(keyOfData) >= inDay && num.parse(keyOfData) <= outDay) {
            result.add(data[keyOfData]);
          }
        }
      }).onError((error, stackTrace) => null);
    } else {
      int startMonth = int.parse(inMonthId.substring(4, 6));
      int endMonth = int.parse(outMonthId.substring(4, 6));
      String startYear = inMonthId.substring(0, 4);
      String endYear = outMonthId.substring(0, 4);
      List<String> monthIds = [];
      if (startYear == endYear) {
        for (var i = startMonth; i <= endMonth; i++) {
          monthIds.add("$endYear${i >= 10 ? i : "0$i"}");
        }
      } else {
        for (var i = startMonth; i <= 12; i++) {
          monthIds.add("$startYear${i >= 10 ? i : "0$i"}");
        }
        for (var i = 1; i <= endMonth; i++) {
          monthIds.add("$endYear${i >= 10 ? i : "0$i"}");
        }
      }
      print("daily:= $inDay --- $monthIds ---- $outDay");
      for (var monthId in monthIds) {
        await FirebaseHandler.hotelRef
            .collection('daily_allotment')
            .doc(monthId)
            .get()
            .then((snapshot) {
          final data = snapshot.data()!['data'] as Map<String, dynamic>;
          for (var keyOfData in data.keys) {
            if (keyOfData == "default") continue;
            if (monthIds.indexOf(monthId) == 0) {
              if (num.parse(keyOfData) >= inDay) {
                result.add(data[keyOfData]);
              }
            } else if (monthIds.indexOf(monthId) == (monthIds.length - 1)) {
              if (num.parse(keyOfData) <= outDay) {
                result.add(data[keyOfData]);
              }
            } else {
              result.add(data[keyOfData]);
            }
          }
        }).onError((error, stackTrace) => null);
      }
    }
    return result;
  }

  Future<List<String>> getAvailableRoomsWithStaysDayAndRoomTypeiD(
      DateTime inDay, DateTime outDay, String roomTypeID) async {
    final List<DateTime> staysDay = DateUtil.getStaysDay(inDay, outDay);
    final List<String> roomBooked = [];
    Map<String, dynamic> dailyAllotmentTepm = {};
    await getDailyAllotments(staysDay, dailyAllotmentTepm);

    for (var date in staysDay) {
      final monthID = DateUtil.dateToShortStringYearMonth(date);

      if (dailyAllotmentTepm[monthID][date.day.toString()]['booked'] != null) {
        for (var room in dailyAllotmentTepm[monthID][date.day.toString()]
            ['booked']) {
          if (!roomBooked.contains(room)) {
            roomBooked.add(room);
          }
        }
      }
    }

    final List<String> rooms = RoomManager().getRoomIDsByType(roomTypeID);
    rooms.removeWhere((element) => roomBooked.contains(element));
    return rooms;
  }

  String getPeformanceWithDate(DateTime date) {
    int totalRoom = RoomTypeManager()
        .activedRoomTypes
        .fold(0, (previousValue, element) => previousValue + element!.total!);
    if (totalRoom == 0) return '0%';
    num currentBooking = getTotalCurrentBookingWithDate(date);
    return '${(currentBooking * 100 / totalRoom).toStringAsFixed(0)}%';
  }

  num getTotalRoomWithDateAndRoomType(DateTime date, String roomTypeID) {
    String monthID = DateUtil.dateToShortStringYearMonth(date);
    String dayID = date.day.toString();
    if (dailyAllotments[monthID] == null) {
      return 0;
    }
    if (dailyAllotments[monthID][dayID][roomTypeID] == null) {
      return 0;
    }
    return dailyAllotments[monthID][dayID][roomTypeID]['num'];
  }

  Future<List<String>> getBookedRooms(DateTime inDay, DateTime outDay) async {
    List<DateTime> staysDay = DateUtil.getStaysDay(inDay, outDay);
    Map<String, dynamic> dailyAllotmentTepm = {};
    await getDailyAllotments(staysDay, dailyAllotmentTepm);
    final List<String> roomBooked = [];
    for (var date in staysDay) {
      final monthID = DateUtil.dateToShortStringYearMonth(date);
      // get booked room
      if (dailyAllotmentTepm[monthID][date.day.toString()]['booked'] != null) {
        for (var room in dailyAllotmentTepm[monthID][date.day.toString()]
            ['booked']) {
          if (!roomBooked.contains(room)) {
            roomBooked.add(room);
          }
        }
      }
    }
    return roomBooked;
  }

  Future<Map<String, dynamic>> getPriceAndBookedRooms(
      DateTime inDay, DateTime outDay, String roomTypeID) async {
    List<DateTime> staysDay = DateUtil.getStaysDay(inDay, outDay);
    Map<String, dynamic> data = {};
    Map<String, dynamic> dailyAllotmentTepm = {};
    await getDailyAllotments(staysDay, dailyAllotmentTepm);
    final List<num> prices = [];
    final List<String> roomBooked = [];
    for (var date in staysDay) {
      final monthID = DateUtil.dateToShortStringYearMonth(date);
      // get booked room
      if (dailyAllotmentTepm[monthID][date.day.toString()]['booked'] != null) {
        for (var room in dailyAllotmentTepm[monthID][date.day.toString()]
            ['booked']) {
          if (!roomBooked.contains(room)) {
            roomBooked.add(room);
          }
        }
      }
      // get price
      if (dailyAllotmentTepm[monthID][date.day.toString()][roomTypeID] !=
              null &&
          dailyAllotmentTepm[monthID][date.day.toString()][roomTypeID]
                  ['price'] !=
              null) {
        prices.add(dailyAllotmentTepm[monthID][date.day.toString()][roomTypeID]
            ['price']);
      } else {
        prices.add(dailyAllotmentTepm[monthID]['default'][roomTypeID]['price']);
      }
    }
    data['price'] = prices;
    data['booked'] = roomBooked;

    return data;
  }

  String getRankByDate(DateTime date) {
    switch (DateFormat('EEEE').format(date)) {
      case "Monday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_MONDAY);
      case "Tuesday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_TUESDAY);
      case "Wednesday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_WEDNESDAY);
      case "Thursday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_THURSDAY);
      case "Friday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_FRIDAY);
      case "Saturday":
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_SATURDAY);
      default:
        return UITitleUtil.getTitleByCode(UITitleCode.HEADER_SUNDAY);
    }
  }
}
