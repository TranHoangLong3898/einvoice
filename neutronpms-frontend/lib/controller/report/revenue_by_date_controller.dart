import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/util/dateutil.dart';
import '../../handler/firebasehandler.dart';
import '../../manager/roommanager.dart';
import '../../util/excelulti.dart';
import '../../util/messageulti.dart';

class RevenueByDateController extends ChangeNotifier {
  late DateTime now, startDate, endDate;
  bool isLoading = false;
  QueryDocumentSnapshot? inMonthSnapshot, outMonthSnapshot;
  Map<String, dynamic> contentRender = {};
  late num rChargeTotal,
      minibarTotal,
      extraHourTotal,
      electricityWaterTotal,
      extraGuestTotal,
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
      roomSoldTotal,
      roomTotal,
      nightTotal = 0;

  RevenueByDateController() {
    now = DateTime.now();
    startDate = DateUtil.to12h(now);
    endDate = startDate;
    loadRevenueByDate();
  }

  Query getInitQueryDailyDataByMonthID(
      DateTime startDateParam, DateTime endDateParam) {
    final inMonthID = DateUtil.dateToShortStringYearMonth(startDateParam);
    final outMonthID = DateUtil.dateToShortStringYearMonth(endDateParam);
    if (inMonthID == outMonthID) {
      return FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colDailyData)
          .where(FieldPath.documentId, isEqualTo: inMonthID);
    }
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colDailyData)
        .where(FieldPath.documentId, whereIn: [inMonthID, outMonthID]);
  }

  void loadRevenueByDate() {
    isLoading = true;
    notifyListeners();
    contentRender.clear();
    final inMonthID = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthID = DateUtil.dateToShortStringYearMonth(endDate);
    if (inMonthID != outMonthID) {
      if (![inMonthSnapshot?.id, outMonthSnapshot?.id].contains(inMonthID) ||
          ![inMonthSnapshot?.id, outMonthSnapshot?.id].contains(outMonthID)) {
        getInitQueryDailyDataByMonthID(startDate, endDate)
            .get()
            .then((value) => updateDataDaily(value));
      } else {
        final DateTime lastDateInMonth = DateUtil.getLastDateOfMonth(startDate);
        final DateTime firstDateOutMonth =
            DateUtil.getFirstDateOfMonth(endDate);

        final List<DateTime> stayDatesInMonth =
            DateUtil.getStaysDay(startDate, lastDateInMonth)
              ..add(lastDateInMonth);
        final List<DateTime> stayDatesOutMonth =
            DateUtil.getStaysDay(firstDateOutMonth, endDate)..add(endDate);
        updateDataRenderLocal(stayDatesInMonth, inMonthSnapshot!);
        updateDataRenderLocal(stayDatesOutMonth, outMonthSnapshot!);
      }
    } else {
      if (inMonthSnapshot?.id == inMonthID ||
          outMonthSnapshot?.id == inMonthID) {
        if (inMonthSnapshot!.id == inMonthID) {
          final List<DateTime> stayDates =
              DateUtil.getStaysDay(startDate, endDate);
          if (stayDates.length == 1) {
            if (!startDate.isAtSameMomentAs(endDate)) {
              stayDates.add(endDate);
            }
          } else {
            stayDates.add(endDate);
          }
          updateDataRenderLocal(stayDates, inMonthSnapshot!);
        } else {
          final List<DateTime> stayDates =
              DateUtil.getStaysDay(startDate, endDate);
          if (stayDates.length == 1) {
            if (!startDate.isAtSameMomentAs(endDate)) {
              stayDates.add(endDate);
            }
          } else {
            stayDates.add(endDate);
          }
          updateDataRenderLocal(stayDates, outMonthSnapshot!);
        }
      } else {
        // fetch data again here
        getInitQueryDailyDataByMonthID(startDate, endDate)
            .get()
            .then((value) => updateDataDaily(value));
      }
    }
    isLoading = false;
    notifyListeners();
  }

  num getTotal() {
    return contentRender.values
        .fold(0, (previousValue, element) => previousValue + element['total']);
  }

  void updateDataDaily(QuerySnapshot querySnapshot) {
    if (querySnapshot.size == 2) {
      inMonthSnapshot = querySnapshot.docs.first;
      outMonthSnapshot = querySnapshot.docs.last;
      final DateTime lastDateInMonth = DateUtil.getLastDateOfMonth(startDate);
      final DateTime firstDateOutMonth = DateUtil.getFirstDateOfMonth(endDate);

      final List<DateTime> stayDatesInMonth =
          DateUtil.getStaysDay(startDate, lastDateInMonth)
            ..add(lastDateInMonth);
      final List<DateTime> stayDatesOutMonth =
          DateUtil.getStaysDay(firstDateOutMonth, endDate)..add(endDate);

      updateDataRenderLocal(stayDatesInMonth, inMonthSnapshot!);
      updateDataRenderLocal(stayDatesOutMonth, outMonthSnapshot!);
    } else {
      inMonthSnapshot = querySnapshot.docs.first;
      final List<DateTime> stayDates = DateUtil.getStaysDay(startDate, endDate);

      if (stayDates.length == 1) {
        if (!startDate.isAtSameMomentAs(endDate)) {
          stayDates.add(endDate);
        }
      } else {
        stayDates.add(endDate);
      }

      updateDataRenderLocal(stayDates, inMonthSnapshot!);
    }
    isLoading = false;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to12h(newDate);
    startDate = newDate;
    if (endDate.compareTo(startDate) < 0) endDate = DateUtil.to12h(startDate);
    if (endDate.difference(startDate) > const Duration(days: 30)) {
      endDate = DateUtil.to12h(startDate.add(const Duration(days: 30)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to12h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  void updateDataRenderLocal(
      List<DateTime> stayingDate, QueryDocumentSnapshot queryDocumentSnapshot) {
    final Map<String, dynamic> data = queryDocumentSnapshot.get('data');
    for (var currentDate in stayingDate) {
      final String currentDateString =
          DateUtil.dateToShortStringDay(currentDate);

      final String dateIDKey = DateUtil.dateToDayMonthYearString(currentDate);

      contentRender[dateIDKey] = {};
      contentRender[dateIDKey]['room_charge'] = 0;
      contentRender[dateIDKey]['total'] = 0;
      contentRender[dateIDKey]['num'] = 0;
      contentRender[dateIDKey]['details'] = {};
      contentRender[dateIDKey]['bike_rental'] = 0;
      contentRender[dateIDKey]['minibar'] = 0;
      contentRender[dateIDKey]['laundry'] = 0;
      contentRender[dateIDKey]['other'] = 0;
      contentRender[dateIDKey]['extra_hours'] = 0;
      contentRender[dateIDKey]['extra_guest'] = 0;
      contentRender[dateIDKey]['inside_restaurant'] = 0;
      contentRender[dateIDKey]['restaurant'] = 0;
      contentRender[dateIDKey]['electricity_water'] = 0;

      contentRender[dateIDKey]['guest'] = 0;
      contentRender[dateIDKey]['discount'] = 0;
      contentRender[dateIDKey]['total_nightpayathotel'] = 0;
      contentRender[dateIDKey]['total_nightprepaid'] = 0;

      if (data[currentDateString] == null) {
        continue;
      }

      // room_charge
      if (data[currentDateString]['current_booking'] != null) {
        if (data[currentDateString]['current_booking']['pay_at_hotel'] !=
            null) {
          final Map<String, dynamic> dataFlowRoomType =
              data[currentDateString]['current_booking']['pay_at_hotel'];
          for (var roomType in dataFlowRoomType.entries) {
            final Map<String, dynamic> datFlowSource = roomType.value;
            for (var source in datFlowSource.entries) {
              if (contentRender[dateIDKey]['details'][roomType.key] == null) {
                contentRender[dateIDKey]['total_nightpayathotel'] +=
                    source.value['num'];
                contentRender[dateIDKey]['details'][roomType.key] = {
                  'num': source.value['num'],
                  'total': source.value['room_charge']
                };

                contentRender[dateIDKey]['room_charge'] +=
                    source.value['room_charge'];
                contentRender[dateIDKey]['num'] += source.value['num'];
              } else {
                contentRender[dateIDKey]['details'][roomType.key]['num'] +=
                    source.value['num'];
                contentRender[dateIDKey]['details'][roomType.key]['total'] +=
                    source.value['room_charge'];

                contentRender[dateIDKey]['room_charge'] +=
                    source.value['room_charge'];
                contentRender[dateIDKey]['num'] += source.value['num'];
                contentRender[dateIDKey]['total_nightpayathotel'] +=
                    source.value['num'];
              }
            }
          }
        }

        if (data[currentDateString]['current_booking']['prepaid'] != null) {
          final Map<String, dynamic> dataFlowRoomType =
              data[currentDateString]['current_booking']['prepaid'];
          for (var roomType in dataFlowRoomType.entries) {
            final Map<String, dynamic> datFlowSource = roomType.value;
            for (var source in datFlowSource.entries) {
              if (contentRender[dateIDKey]['details'][roomType.key] == null) {
                contentRender[dateIDKey]['details'][roomType.key] = {
                  'num': source.value['num'],
                  'total': source.value['room_charge']
                };

                contentRender[dateIDKey]['room_charge'] +=
                    source.value['room_charge'];
                contentRender[dateIDKey]['num'] += source.value['num'];
                contentRender[dateIDKey]['total_nightprepaid'] +=
                    source.value['num'];
              } else {
                contentRender[dateIDKey]['details'][roomType.key]['num'] +=
                    source.value['num'];
                contentRender[dateIDKey]['details'][roomType.key]['total'] +=
                    source.value['room_charge'];

                contentRender[dateIDKey]['room_charge'] +=
                    source.value['room_charge'];
                contentRender[dateIDKey]['num'] += source.value['num'];
                contentRender[dateIDKey]['total_nightprepaid'] +=
                    source.value['num'];
              }
            }
          }
        }
      }

      contentRender[dateIDKey]['total'] +=
          contentRender[dateIDKey]['room_charge'];

      if (data[currentDateString]['service'] != null) {
        // bike_rental
        if (data[currentDateString]['service']['bike_rental'] != null) {
          contentRender[dateIDKey]['bike_rental'] +=
              data[currentDateString]['service']['bike_rental']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['bike_rental'];
        }

        // minibar
        if (data[currentDateString]['service']['minibar'] != null) {
          contentRender[dateIDKey]['minibar'] +=
              data[currentDateString]['service']['minibar']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['minibar'];
        }

        // extra_hours
        if (data[currentDateString]['service']['extra_hours'] != null) {
          contentRender[dateIDKey]['extra_hours'] +=
              data[currentDateString]['service']['extra_hours']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['extra_hours'];
        }

        // extra_guest
        if (data[currentDateString]['service']['extra_guest'] != null) {
          contentRender[dateIDKey]['extra_guest'] +=
              data[currentDateString]['service']['extra_guest']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['extra_guest'];
        }

        // other
        if (data[currentDateString]['service']['other'] != null) {
          contentRender[dateIDKey]['other'] +=
              data[currentDateString]['service']['other']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['other'];
        }

        // laundry
        if (data[currentDateString]['service']['laundry'] != null) {
          contentRender[dateIDKey]['laundry'] +=
              data[currentDateString]['service']['laundry']['total'];
          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['laundry'];
        }

        // inside res
        if (data[currentDateString]['service']['inside_restaurant'] != null) {
          contentRender[dateIDKey]['inside_restaurant'] +=
              data[currentDateString]['service']['inside_restaurant']['total'];

          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['inside_restaurant'];
        }

        // outside res
        if (data[currentDateString]['service']['restaurant'] != null) {
          contentRender[dateIDKey]['restaurant'] +=
              data[currentDateString]['service']['restaurant']['total'];

          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['restaurant'];
        }

        // electricity_water
        if (data[currentDateString]['service']['electricity_water'] != null) {
          contentRender[dateIDKey]['electricity_water'] +=
              data[currentDateString]['service']['electricity_water']['total'];

          contentRender[dateIDKey]['total'] +=
              contentRender[dateIDKey]['electricity_water'];
        }
      }

      // guest_qty
      if (data[currentDateString]['guest'] != null) {
        contentRender[dateIDKey]['guest'] += data[currentDateString]['guest']
                ['adult'] +
            data[currentDateString]['guest']['child'];
      }

      // discounts
      if (data[currentDateString]['revenue'] != null) {
        contentRender[dateIDKey]['discount'] +=
            data[currentDateString]['revenue']['discount'];
        contentRender[dateIDKey]['total'] -=
            contentRender[dateIDKey]['discount'];
      }
    }
  }

  Future<void> getTotalAllRevenueByDate() async {
    rChargeTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['room_charge']);
    minibarTotal = contentRender.entries.fold(0,
        (previousValue, element) => previousValue + element.value['minibar']);
    extraHourTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['extra_hours']);
    extraGuestTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['extra_guest']);
    laudryTotal = contentRender.entries.fold(0,
        (previousValue, element) => previousValue + element.value['laundry']);
    bikeRentalTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['bike_rental']);
    otherTotal = contentRender.entries.fold(
        0, (previousValue, element) => previousValue + element.value['other']);
    restaurantTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['restaurant']);
    insideRestaurantTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['inside_restaurant']);
    discountTotal = contentRender.entries.fold(0,
        (previousValue, element) => previousValue + element.value['discount']);

    mountnGuestTotal = contentRender.entries.fold(
        0, (previousValue, element) => previousValue + element.value['guest']);

    roomSoldTotal = contentRender.entries.fold(
        0, (previousValue, element) => previousValue + element.value['num']);

    roomTotal = RoomManager().rooms!.length * contentRender.length;

    electricityWaterTotal = contentRender.entries.fold(
        0,
        (previousValue, element) =>
            previousValue + element.value['electricity_water']);

    roomAvailableTotal = roomTotal - roomSoldTotal;

    nightTotal = contentRender.entries.fold(
            0,
            (previousValue, element) =>
                previousValue +
                (element.value['total_nightpayathotel'] as int)) +
        contentRender.entries.fold(
            0,
            (previousValue, element) =>
                previousValue + element.value['total_nightprepaid']);

    verageRatetotal = rChargeTotal / nightTotal;

    occTotal =
        nightTotal / (RoomManager().rooms!.length * contentRender.length) * 100;
  }

  num get totalAllRevenueByDate =>
      (rChargeTotal +
          bikeRentalTotal +
          extraGuestTotal +
          extraHourTotal +
          insideRestaurantTotal +
          electricityWaterTotal +
          restaurantTotal +
          minibarTotal +
          laudryTotal +
          otherTotal) -
      discountTotal;

  String exportToExcel() {
    if (contentRender.keys.first !=
            DateUtil.dateToDayMonthYearString(startDate) ||
        contentRender.keys.last != DateUtil.dateToDayMonthYearString(endDate)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CLICK_REFRESH_BUTTON_FIRST);
    }

    // load refresh again before export to excel
    ExcelUlti.exportRevenueByDateReport(contentRender, startDate, endDate);
    return '';
  }
}
