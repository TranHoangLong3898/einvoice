import 'dart:collection';

import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';

import '../manager/roomtypemanager.dart';
import '../manager/sourcemanager.dart';

class DailyData {
  String? date;
  DateTime? dateFull;

  final Map<String, dynamic>? revenue;
  final Map<String, dynamic>? breakfast;
  final Map<String, dynamic>? lunch;
  final Map<String, dynamic>? dinner;
  final Map<String, dynamic>? guest;
  final Map<String, dynamic>? deposit;
  final Map<String, dynamic>? depositPayment;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? currentBooking;
  final Map<String, dynamic>? newBooking;
  final Map<String, dynamic>? accounting;
  final Map<String, dynamic>? actualPayment;
  final Map<String, dynamic>? typeTourists;
  final SplayTreeMap<String, dynamic>? country = SplayTreeMap(
    (key1, key2) {
      if (key1 == 'unknown') {
        return -1;
      }
      if (key2 == 'unknown') {
        return 1;
      }
      return key1.compareTo(key2);
    },
  );

  num night = 0;
  num roomCharge = 0;
  //service
  num minibar = 0;
  num outsideRestaurant = 0;
  num insideRestaurant = 0;
  num extraGuest = 0;
  num laundry = 0;
  num bikeRental = 0;
  num other = 0;
  num extraHour = 0;
  num electricity = 0;
  num water = 0;
  //revenue
  num totalService = 0;
  num totalDeposit = 0;
  num discount = 0;
  num revenueByDate = 0;
  num cost = 0;

  DailyData({
    this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.guest,
    this.currentBooking,
    this.newBooking,
    this.revenue,
    this.service,
    this.deposit,
    this.depositPayment,
    this.accounting,
    this.actualPayment,
    this.typeTourists,
    Map<String, dynamic>? country,
  }) {
    dateFull = DateUtil.shortStringToDate12h(date!);
    date = date!.substring(6, 8);
    night = getRoomChargeOrNight(
        methodType: MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        roomTypeName:
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        sourceName:
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL));
    roomCharge = getRoomChargeOrNight(
        methodType: MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        roomTypeName:
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        sourceName: MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        roomCharge: true);

    minibar = _getServiceMinibar();
    outsideRestaurant = _getServiceRestaurantOutside();
    insideRestaurant = _getServiceRestaurantInside();
    extraGuest = _getServiceExtraGuest();
    laundry = _getServiceLaundry();
    other = _getServiceOther();
    bikeRental = _getServiceBikeRental();
    extraHour = _getServiceExtraHour();
    electricity = _getServiceElectricity();
    water = _getServiceWater();
    discount = getRevenueDiscount();
    cost = getCostData();

    totalService = minibar +
        insideRestaurant +
        outsideRestaurant +
        extraGuest +
        laundry +
        other +
        bikeRental +
        extraHour +
        electricity +
        water;
    totalDeposit = getDeposit();
    revenueByDate = roomCharge + totalService - discount;
    this.country?.addAll(country ?? {});
  }

  num getBreakfast() => breakfast != null
      ? (breakfast?['adult'] ?? 0) + (breakfast!['child'] ?? 0)
      : 0;

  num getLunch() =>
      lunch != null ? (lunch?['adult'] ?? 0) + (lunch!['child'] ?? 0) : 0;

  num getDinder() =>
      dinner != null ? (dinner?['adult'] ?? 0) + (dinner!['child'] ?? 0) : 0;

  num getBreakfastChild() => breakfast != null ? breakfast!['child'] ?? 0 : 0;
  num getBreakfastAdult() => breakfast != null ? breakfast!['adult'] ?? 0 : 0;

  num getLunchChild() => lunch != null ? lunch!['child'] ?? 0 : 0;
  num getLunchAdult() => lunch != null ? lunch!['adult'] ?? 0 : 0;

  num getDinnerChild() => dinner != null ? dinner!['child'] ?? 0 : 0;
  num getDinnerAdult() => dinner != null ? dinner!['adult'] ?? 0 : 0;

  num getGuest() =>
      guest != null ? (guest!['adult'] ?? 0) + (guest!['child'] ?? 0) : 0;
  num getGuestChild() => guest != null ? guest!['child'] ?? 0 : 0;
  num getGuestAdult() => guest != null ? guest!['adult'] ?? 0 : 0;

  num getRevenue() => revenue != null ? revenue!['total'] : 0;
  num getRevenueRoomCharge() =>
      revenue != null ? (revenue!['room_charge'] ?? 0) : 0;
  num getRevenueService() => revenue != null ? revenue!['service_charge'] : 0;
  num getRevenueDiscount() => revenue != null ? revenue!['discount'] : 0;
  num getRevenueLiquidation() => (revenue?.containsKey('liquidation') ?? false)
      ? revenue!['liquidation']
      : 0;

  num getCostData() {
    num totalCost = 0;
    if (accounting != null) {
      for (var value in accounting!.values) {
        for (var values in (value as Map).values) {
          for (var valueData in (values as Map).values) {
            totalCost += valueData;
          }
        }
      }
    }
    return totalCost;
  }

  num _getServiceMinibar() {
    if (service == null) return 0;
    if (service!.containsKey('minibar')) {
      return service?['minibar']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceRestaurantOutside() {
    if (service == null) return 0;
    if (service!.containsKey(ServiceManager.OUTSIDE_RESTAURANT_CAT)) {
      return service?[ServiceManager.OUTSIDE_RESTAURANT_CAT]['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceRestaurantInside() {
    if (service == null) return 0;
    if (service!.containsKey(ServiceManager.INSIDE_RESTAURANT_CAT)) {
      return service?[ServiceManager.INSIDE_RESTAURANT_CAT]['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceLaundry() {
    if (service == null) return 0;
    if (service!.containsKey('laundry')) {
      return service?['laundry']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceExtraGuest() {
    if (service == null) return 0;
    if (service!.containsKey('extra_guest')) {
      return service?['extra_guest']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceExtraHour() {
    if (service == null) return 0;
    if (service!.containsKey('extra_hours')) {
      return service?['extra_hours']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceElectricity() {
    if (service == null) return 0;
    if (service!.containsKey('electricity')) {
      return service?['electricity']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceWater() {
    if (service == null) return 0;
    if (service!.containsKey('water')) {
      return service?['water']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceBikeRental() {
    if (service == null) return 0;
    if (service!.containsKey('bike_rental')) {
      return service?['bike_rental']['total'] ?? 0;
    }
    return 0;
  }

  num _getServiceOther() {
    if (service == null) return 0;
    if (service!.containsKey('other')) {
      return service?['other']['total'] ?? 0;
    }
    return 0;
  }

  num getDeposit() {
    if (deposit == null) return 0;
    return deposit!.values.fold(
        0,
        (pre, method) =>
            pre +
            (method as Map).values.fold(0, (prev, value) => prev + value));
  }

  num getDepositPayment() {
    if (depositPayment == null) return 0;
    return depositPayment!.values.fold(0, (pre, method) => pre + method);
  }

  num getDepositByMethod(String methodName) {
    if (deposit == null) return 0;
    final methodID =
        PaymentMethodManager().getPaymentMethodIdByName(methodName);
    if (deposit!.containsKey(methodID)) {
      return (deposit?[methodID] as Map)
          .values
          .fold(0, (pre, value) => pre + value);
    } else {
      return 0;
    }
  }

  num getRoomChargeOrNight(
      {String? methodType,
      String? roomTypeName,
      String? sourceName,
      bool roomCharge = false}) {
    if (currentBooking == null) return 0;

    if (methodType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PAY_AT_HOTEL)) {
      return getRoomCharge1(
          data1: currentBooking?['pay_at_hotel'],
          roomTypeName: roomTypeName ?? '',
          sourceName: sourceName ?? "",
          roomCharge: roomCharge);
    } else if (methodType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PREPAID)) {
      return getRoomCharge1(
          data1: currentBooking?['prepaid'],
          roomTypeName: roomTypeName ?? "",
          sourceName: sourceName ?? "",
          roomCharge: roomCharge);
    } else {
      return getRoomCharge1(
              data1: currentBooking?['pay_at_hotel'],
              roomTypeName: roomTypeName ?? "",
              sourceName: sourceName ?? "",
              roomCharge: roomCharge) +
          getRoomCharge1(
              data1: currentBooking?['prepaid'],
              roomTypeName: roomTypeName ?? "",
              sourceName: sourceName ?? "",
              roomCharge: roomCharge);
    }
  }

  num getRoomCharge1(
      {Map? data1,
      String? roomTypeName,
      String? sourceName,
      bool roomCharge = false}) {
    if (data1 == null) return 0;
    if (roomTypeName ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return data1.values.fold(
          0,
          (pre, data2) =>
              pre +
              getRoomCharge2(
                  data2: data2,
                  sourceName: sourceName ?? "",
                  roomCharge: roomCharge));
    } else {
      final roomTypeID = RoomTypeManager().getRoomTypeIDByName(roomTypeName!);
      if (data1.containsKey(roomTypeID)) {
        return getRoomCharge2(
            data2: data1[roomTypeID],
            sourceName: sourceName ?? "",
            roomCharge: roomCharge);
      } else {
        return 0;
      }
    }
  }

  num getRoomCharge2(
      {Map? data2, String? sourceName, bool? roomCharge = false}) {
    if (data2 == null) return 0;
    if (sourceName ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return data2.values.fold(
          0,
          (pre, data3) =>
              pre + data3[(roomCharge ?? false) ? 'room_charge' : 'num']);
    } else {
      final sourceID = SourceManager().getSourceIDByName(sourceName!);
      if (data2.containsKey(sourceID)) {
        return data2[sourceID][(roomCharge ?? false) ? 'room_charge' : 'num'];
      } else {
        return 0;
      }
    }
  }

  num getNewBooking(
      {String? methodType, String? roomTypeName, String? sourceName}) {
    if (newBooking == null) return 0;
    roomTypeName ??=
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL);
    sourceName ??= MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL);

    if (methodType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PAY_AT_HOTEL)) {
      return getNewBooking1(
          data1: newBooking!['pay_at_hotel'],
          roomTypeName: roomTypeName,
          sourceName: sourceName);
    } else if (methodType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PREPAID)) {
      return getNewBooking1(
          data1: newBooking!['prepaid'],
          roomTypeName: roomTypeName,
          sourceName: sourceName);
    } else {
      return getNewBooking1(
              data1: newBooking!['pay_at_hotel'],
              roomTypeName: roomTypeName,
              sourceName: sourceName) +
          getNewBooking1(
              data1: newBooking!['prepaid'],
              roomTypeName: roomTypeName,
              sourceName: sourceName);
    }
  }

  num getNewBooking1({Map? data1, String? roomTypeName, String? sourceName}) {
    if (data1 == null) return 0;
    if (roomTypeName ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return data1.values.fold(
          0,
          (pre, data2) =>
              pre + getRoomCharge2(data2: data2, sourceName: sourceName));
    } else {
      final roomTypeID = RoomTypeManager().getRoomTypeIDByName(roomTypeName!);
      if (data1.containsKey(roomTypeID)) {
        return getRoomCharge2(data2: data1[roomTypeID], sourceName: sourceName);
      } else {
        return 0;
      }
    }
  }

  num getNewBooking2({Map? data2, String? sourceName}) {
    if (data2 == null) return 0;
    if (sourceName ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return data2.values.fold(0, (pre, data3) => pre + data3['num']);
    } else {
      final sourceID = SourceManager().getSourceIDByName(sourceName!);
      if (data2.containsKey(sourceID)) {
        return data2[sourceID]['num'];
      } else {
        return 0;
      }
    }
  }

  double getCostManagement({String? type, String? supplier, String? status}) {
    if (accounting == null || accounting!.isEmpty) {
      return 0;
    }
    double sum = 0;
    accounting!.forEach((typeId, mapValue1) {
      if (type != null && type != typeId) {
        return;
      }
      (mapValue1 as Map).forEach((supplierId, value2) {
        if (supplier != null && supplier != supplierId) {
          return;
        }
        (value2 as Map).forEach((statusId, amount) {
          if (status != null && status != statusId) {
            return;
          }
          sum += amount;
        });
      });
    });
    return sum;
  }

  double getActualPlayment(
      {String? type, String? supplier, String? status, String? method}) {
    if (actualPayment == null || actualPayment!.isEmpty) {
      return 0;
    }
    double sum = 0;
    actualPayment!.forEach((typeId, mapValue1) {
      if (type != null && type != typeId) {
        return;
      }
      (mapValue1 as Map).forEach((supplierId, mapValue2) {
        if (supplier != null && supplier != supplierId) {
          return;
        }
        (mapValue2 as Map).forEach((methodId, mapValue3) {
          if (method != null && method != methodId) {
            return;
          }
          (mapValue3 as Map).forEach((statusId, amount) {
            if (status != null && status != statusId) {
              return;
            }
            sum += amount;
          });
        });
      });
    });
    return sum;
  }

  Map<String, dynamic> getAmountRoomCharge() {
    if (currentBooking == null) return {};
    Map<String, dynamic> result = {};
    for (var key in currentBooking!.keys) {
      for (var key1 in currentBooking?[key].keys) {
        result[key1] = {};
        result[key1]["amount"] = 0;
        result[key1]["price"] = 0;
      }
    }
    for (var key in currentBooking!.keys) {
      for (var idRoomType in result.keys) {
        if (currentBooking?[key]?[idRoomType] != null) {
          for (var id in currentBooking?[key][idRoomType].keys) {
            result[idRoomType]['price'] +=
                currentBooking?[key]?[idRoomType]?[id]?["room_charge"] ?? 0;
            result[idRoomType]['amount'] +=
                currentBooking?[key]?[idRoomType]?[id]["num"] ?? 0;
          }
        }
      }
    }
    return result;
  }

  double get countryTotal =>
      country?.entries.fold(
          0, (previousValue, element) => previousValue! + element.value) ??
      0;

  double get typeTouristsTotal =>
      typeTourists?.entries.fold(
          0,
          (previousValue, element) =>
              previousValue! + element.value.toDouble()) ??
      0;

  double get domesticGuest {
    if (typeTourists?.containsKey('domestic') ?? false) {
      return typeTourists!['domestic'].toDouble();
    }
    return 0;
  }

  double get foreignGuest {
    if (typeTourists?.containsKey('foreign') ?? false) {
      return typeTourists!['foreign'].toDouble();
    }
    return 0;
  }

  double get unknownGuest {
    if (typeTourists?.containsKey('unknown') ?? false) {
      return typeTourists!['unknown'].toDouble();
    }
    return 0;
  }
}
