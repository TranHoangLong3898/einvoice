import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../manager/generalmanager.dart';
import '../../modal/booking.dart';
import '../../util/dateutil.dart';

class RevenueByRoomReportController extends ChangeNotifier {
  int? maxTimePeriod;
  late DateTime startDate, endDate;
  bool? isLoading = false;
  num revenueTotal = 0;
  late DateTime now;
  List<Booking> bookings = [];
  List<String> years = [];
  List<DateTime> staysDate = [];
  List<DateTime> staysDate1To10 = [];
  List<DateTime> staysDate10To20 = [];
  List<DateTime> staysDate20To30 = [];
  List<DateTime> staysDate30To31 = [];
  Map<String, List<Booking>> mapDataBooking = {};
  Map<String, dynamic> totalService = {};
  Map<String, Map<String, dynamic>> serviceOther = {};
  Map<String, Map<String, dynamic>> serviceElectricity = {};
  Set<String> dataSetTypeCost = {};
  Set<String> dataSetMethod = {};
  Set<String> dataSetOther = {};
  Map<String, Map<String, dynamic>> mapPayment = {};
  late String selectYear;
  late String selectMonth;
  List<int> listStatusBooking = [
    BookingStatus.booked,
    BookingStatus.checkin,
    BookingStatus.checkout
  ];
  List<String> listMonth = DateUtil.listMonth;
  late String selectedPeriod;
  final List<String> periodTypes = [
    UITitleUtil.getTitleByCode(UITitleCode.THIS_MONTH),
    UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)
  ];

  List<String> listTypeBooking = [
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOURLY),
    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY),
  ];
  List<String> selectedTypeBooking = [];

  List<int> listTypeBookingStatus = [
    BookingType.dayly,
    BookingType.hourly,
    BookingType.monthly,
  ];

  RevenueByRoomReportController() {
    selectedTypeBooking.addAll(listTypeBooking);
    selectedPeriod = periodTypes.first;
    now = DateTime.now();
    int currentYear = now.year;
    int startYear = currentYear - 15; // Bắt đầu từ 20 năm trước
    int endYear = currentYear + 3; // Kết thúc 20 năm sau
    years = yearsList(startYear, endYear);
    selectYear = now.year.toString();
    selectMonth = now.month.toString();
    startDate = DateUtil.to0h(DateTime(now.year, now.month, 1));
    endDate = DateUtil.to24h(
        DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now)));
    maxTimePeriod = GeneralManager.hotel!.isAdvPackage() ? 30 : 7;
    // loadRevenues();
  }

  Query getInitQueryBookingFrom1To10Day() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContainsAny: staysDate1To10)
        .where('status', whereIn: listStatusBooking)
        .orderBy('room');
  }

  Query getInitQueryBookingFrom10To20Day() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContainsAny: staysDate10To20)
        .where('status', whereIn: listStatusBooking)
        .orderBy('room');
  }

  Query getInitQueryBookingFrom20To30Day() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContainsAny: staysDate20To30)
        .where('status', whereIn: listStatusBooking)
        .orderBy('room');
  }

  Query getInitQueryBookingFrom30To31Day() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBasicBookings)
        .where('stay_days', arrayContainsAny: staysDate30To31)
        .where('status', whereIn: listStatusBooking)
        .orderBy('room');
  }

  getDataColecttionBookingByID(String id) async {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(id)
        .get()
        .then((value) => value);
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

  void setPeriodType(String newValue) {
    if (newValue == selectedPeriod) return;
    selectedPeriod = newValue;
    notifyListeners();
  }

  void setBookingType(String statusName, bool check) {
    listTypeBookingStatus.clear();
    check
        ? selectedTypeBooking.add(statusName)
        : selectedTypeBooking.remove(statusName);
    for (var element in selectedTypeBooking) {
      if (element ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)) {
        listTypeBookingStatus.add(BookingType.dayly);
      } else if (element ==
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOURLY)) {
        listTypeBookingStatus.add(BookingType.hourly);
      } else {
        listTypeBookingStatus.add(BookingType.monthly);
      }
    }
    notifyListeners();
  }

  void setYear(String newDate) {
    if (selectYear == newDate) return;
    selectYear = newDate;
    DateTime dateTime =
        DateTime(int.parse(selectYear), int.parse(selectMonth), 1);
    startDate = DateUtil.to0h(DateTime(dateTime.year, dateTime.month, 1));
    endDate = DateUtil.to24h(DateTime(
        dateTime.year, dateTime.month, DateUtil.getLengthOfMonth(dateTime)));
    notifyListeners();
  }

  void setMonth(String newMonth) {
    if (selectMonth == newMonth) return;
    selectMonth = newMonth;
    DateTime dateTime =
        DateTime(int.parse(selectYear), int.parse(selectMonth), 1);
    startDate = DateUtil.to0h(DateTime(dateTime.year, dateTime.month, 1));
    endDate = DateUtil.to24h(DateTime(
        dateTime.year, dateTime.month, DateUtil.getLengthOfMonth(dateTime)));
    notifyListeners();
  }

  Future<void> updateRevenuesAndQueries(QuerySnapshot querySnapshot) async {
    for (var docs in querySnapshot.docs) {
      if (bookings.where((element) => element.id == docs.id).isEmpty &&
          listTypeBookingStatus.contains(docs.get("booking_type"))) {
        bookings.add(Booking.basicFromSnapshotByRoom(
            docs,
            await getDataColecttionBookingByID(
                docs.get("group")! ? docs.get("sid") : docs.id)));
      }
    }
    for (var booking in bookings) {
      Map<String, dynamic>? dataService = {};
      num totalDeposit = 0;
      num totalCost = 0;
      num totalDiscount = 0;
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
            if (dataService.containsKey(element.get("cat"))) {
              dataService[element.get("cat")] += element.get("total");
            } else {
              dataService[element.get("cat")] = element.get("total");
            }
          }
        }
      });
      if (booking.paymentDetails!.isNotEmpty) {
        for (var data in booking.paymentDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          DateTime timeCreate =
              DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(booking.inDate!) &&
                  int.parse(selectMonth) == booking.inDate!.month) ||
              (timeCreate.isAfter(booking.outDate!) &&
                  int.parse(selectMonth) == booking.outDate!.month)) {
            totalDeposit += num.parse(descArray[1]);
          }
        }
      }
      if (booking.costDetails!.isNotEmpty) {
        for (var data in booking.costDetails!.values) {
          List<String> descArray = data.toString().split(specificCharacter);
          DateTime timeCreate =
              DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[3]));
          if (((timeCreate.isAfter(startDate) &&
                      timeCreate.isBefore(endDate)) ||
                  (timeCreate.isBefore(booking.inDate!) &&
                      int.parse(selectMonth) == booking.inDate!.month) ||
                  (timeCreate.isAfter(booking.outDate!) &&
                      int.parse(selectMonth) == booking.outDate!.month)) &&
              descArray[2] == booking.room) {
            totalCost += num.parse(descArray[1]);
          }
        }
      }
      if (booking.discountDetails!.isNotEmpty) {
        for (var element in booking.discountDetails!.values) {
          DateTime timeCreate =
              (element["modified_time"] as Timestamp).toDate();
          if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
              (timeCreate.isBefore(booking.inDate!) &&
                  int.parse(selectMonth) == booking.inDate!.month) ||
              (timeCreate.isAfter(booking.outDate!) &&
                  int.parse(selectMonth) == booking.outDate!.month)) {
            totalDiscount += element["amount"];
          }
        }
      }

      booking.minibar = dataService[ServiceManager.MINIBAR_CAT] ?? 0;
      booking.extraGuest = dataService[ServiceManager.EXTRA_GUEST_CAT] ?? 0;
      booking.laundry = dataService[ServiceManager.LAUNDRY_CAT] ?? 0;
      booking.bikeRental = dataService[ServiceManager.BIKE_RENTAL_CAT] ?? 0;
      booking.other = dataService[ServiceManager.OTHER_CAT] ?? 0;
      booking.insideRestaurant =
          dataService[ServiceManager.INSIDE_RESTAURANT_CAT] ?? 0;
      booking.outsideRestaurant =
          dataService[ServiceManager.OUTSIDE_RESTAURANT_CAT] ?? 0;
      booking.electricity = dataService[ServiceManager.ELECTRICITY_CAT] ?? 0;
      booking.water = dataService[ServiceManager.WATER_CAT] ?? 0;
      booking.deposit = totalDeposit;
      booking.totalCost = totalCost;
      booking.discount = totalDiscount;
      int lengthStay = 1;
      List<DateTime> stayDayBookings = [];
      DateTime inDate = booking.inDate!;
      DateTime outDate = booking.outDate!;
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
        lengthStay = (inDate.month != outDate.month &&
                    booking.bookingType == BookingType.monthly
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
            // booking.bookingType == BookingType.monthly
            //     ? DateUtil.to12hDayAddOne(outDate)
            //     :
            DateUtil.to12h(outDate));
      }
      num tatoRoom = 0;
      if (booking.bookingType != BookingType.monthly) {
        for (var element in stayDayBookings) {
          tatoRoom += booking.price![booking.staydays!.indexOf(element)];
        }
      }
      booking.totalRoomCharge = booking.bookingType == BookingType.monthly
          ? booking.getRoomChargeByDateCostum(
              inDate: DateTime(stayDayBookings.first.year,
                  stayDayBookings.first.month, stayDayBookings.first.day),
              outDate: DateTime(stayDayBookings.last.year,
                  stayDayBookings.last.month, stayDayBookings.last.day + 1))
          : tatoRoom.round();
      print(
          "${booking.totalRoomCharge}==== ${booking.room} ==== ${booking.getRoomCharge()} ====${booking.lengthStay} === $lengthStay ===== $tatoRoom");
      booking.lengthRender = lengthStay;

      ///
      if (mapDataBooking.containsKey(booking.room)) {
        if (mapDataBooking[booking.room]!
            .where((element) => element.id == booking.id)
            .isEmpty) {
          mapDataBooking[booking.room]!.add(booking);
        }
      } else {
        mapDataBooking[booking.room!] = [booking];
      }
    }
    print("cuoi cùng ${mapDataBooking.length}");
    getTotalServiceOfBooking();
    notifyListeners();
  }

  void loadRevenues() async {
    isLoading = true;
    notifyListeners();
    print("$startDate ---- $endDate");
    staysDate.clear();
    staysDate1To10.clear();
    staysDate10To20.clear();
    staysDate20To30.clear();
    staysDate30To31.clear();
    getDate();
    print(staysDate1To10);
    print(staysDate10To20);
    print(staysDate20To30);
    print(staysDate30To31);
    List<QuerySnapshot<Object?>> querySnapshot = [];
    if (staysDate1To10.isNotEmpty) {
      querySnapshot.add(await getInitQueryBookingFrom1To10Day()
          .get()
          .then((QuerySnapshot querySnapshot) => querySnapshot));
    }
    if (staysDate10To20.isNotEmpty) {
      querySnapshot.add(await getInitQueryBookingFrom10To20Day()
          .get()
          .then((QuerySnapshot querySnapshot) => querySnapshot));
    }
    if (staysDate20To30.isNotEmpty) {
      querySnapshot.add(await getInitQueryBookingFrom20To30Day()
          .get()
          .then((QuerySnapshot querySnapshot) => querySnapshot));
    }
    if (staysDate30To31.isNotEmpty) {
      querySnapshot.add(await getInitQueryBookingFrom30To31Day()
          .get()
          .then((QuerySnapshot querySnapshot) => querySnapshot));
    }
    bookings.clear();
    mapDataBooking.clear();
    for (var element in querySnapshot) {
      await updateRevenuesAndQueries(element);
    }
    isLoading = false;
    notifyListeners();
  }

  getDate() {
    for (var element in DateUtil.getStaysDay(startDate, endDate)) {
      staysDate.add(DateTime(element.year, element.month, element.day, 12));
    }
    staysDate.add(DateTime(endDate.year, endDate.month, endDate.day, 12));

    ///- 1
    if (staysDate.length <= 7) {
      for (var i = 0; i < staysDate.length; i++) {
        staysDate1To10.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }

      ///- 2
    } else if (staysDate.length > 7 && staysDate.length <= 16) {
      for (var i = 0; i <= 7; i++) {
        staysDate1To10.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 8; i < staysDate.length; i++) {
        staysDate10To20.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }

      ///- 3
    } else if (staysDate.length > 16 && staysDate.length <= 24) {
      for (var i = 0; i <= 7; i++) {
        staysDate1To10.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 8; i < 16; i++) {
        staysDate10To20.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 16; i < staysDate.length; i++) {
        staysDate20To30.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }

      ///- 4
    } else {
      for (var i = 0; i <= 7; i++) {
        staysDate1To10.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 8; i < 16; i++) {
        staysDate10To20.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 16; i < 24; i++) {
        staysDate20To30.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
      for (var i = 24; i < staysDate.length; i++) {
        staysDate30To31.add(DateTime(
            staysDate[i].year, staysDate[i].month, staysDate[i].day, 12));
      }
    }
  }

  getTotalServiceOfBooking() {
    totalService.clear();
    revenueTotal = 0;
    for (var key in mapDataBooking.keys) {
      for (var booking in mapDataBooking[key]!) {
        revenueTotal += (booking.getServiceCharge() +
            (booking.totalRoomCharge ?? 0) -
            booking.discount!);
        if (totalService.containsKey(key)) {
          totalService[key]!["averageroom"] += getAverageRoomRate(booking);
          totalService[key]!["priceroom"] += booking.totalRoomCharge;
          totalService[key]!["minibar"] += booking.minibar;
          totalService[key]!["extra_hour"] += booking.extraHour?.total;
          totalService[key]!["extra_guest"] += booking.extraGuest;
          totalService[key]!["laundry"] += booking.laundry;
          totalService[key]!["bike"] += booking.bikeRental;
          totalService[key]!["other"] += booking.other;
          totalService[key]!["restaurant"] += booking.outsideRestaurant;
          totalService[key]!["inrestaurant"] += booking.insideRestaurant;
          totalService[key]!["electricity"] += (booking.electricity ?? 0);
          totalService[key]!["water"] += (booking.water ?? 0);
          totalService[key]!["total"] +=
              (booking.getServiceCharge() + (booking.totalRoomCharge ?? 0));
          totalService[key]!["discount"] += booking.discount;
          totalService[key]!["revenue"] += (booking.getServiceCharge() +
              (booking.totalRoomCharge ?? 0) -
              booking.discount!);
          totalService[key]!["cost"] += booking.totalCost;
          totalService[key]!["deposit"] += booking.deposit;
        } else {
          totalService[key] = {
            "averageroom": getAverageRoomRate(booking),
            "priceroom": booking.totalRoomCharge,
            "minibar": booking.minibar,
            "extra_hour": booking.extraHour?.total,
            "extra_guest": booking.extraGuest,
            "laundry": booking.laundry,
            "bike": booking.bikeRental,
            "other": booking.other,
            "restaurant": booking.outsideRestaurant,
            "inrestaurant": booking.insideRestaurant,
            "electricity": (booking.electricity ?? 0),
            "water": (booking.water ?? 0),
            "discount": booking.discount,
            "cost": booking.totalCost,
            'deposit': booking.deposit,
            "total":
                booking.getServiceCharge() + (booking.totalRoomCharge ?? 0),
            "revenue": booking.getServiceCharge() +
                (booking.totalRoomCharge ?? 0) -
                booking.discount!,
          };
        }
      }
    }
  }

  getAllBookingForExporting() async {
    serviceOther.clear();
    dataSetOther.clear();
    serviceElectricity.clear();
    for (var key in mapDataBooking.keys) {
      for (var booking in mapDataBooking[key]!) {
        if (booking.costDetails!.isNotEmpty) {
          for (var data in booking.costDetails!.values) {
            List<String> descArray = data.toString().split(specificCharacter);
            if (descArray[0].isNotEmpty) {
              dataSetTypeCost
                  .add(AccountingTypeManager.getNameById(descArray[0])!);
            }
          }
        }
        if (booking.paymentDetails != null) {
          for (var data in booking.paymentDetails!.values) {
            List<String> descArray = data.toString().split(specificCharacter);
            if (descArray[0].isNotEmpty) {
              dataSetMethod.add(PaymentMethodManager()
                  .getPaymentMethodNameById(descArray[0]));
            }
            DateTime timeCreate =
                DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
            if (descArray[0].isNotEmpty &&
                ((timeCreate.isAfter(startDate) &&
                        timeCreate.isBefore(endDate)) ||
                    (timeCreate.isBefore(booking.inDate!) &&
                        startDate.month == booking.inDate!.month) ||
                    (timeCreate.isAfter(booking.outDate!) &&
                        startDate.month == booking.outDate!.month))) {
              String depositPayment =
                  PaymentMethodManager().getPaymentMethodNameById(descArray[0]);
              if (mapPayment.containsKey(depositPayment)) {
                if (mapPayment[depositPayment]!.containsKey(booking.id)) {
                  mapPayment[depositPayment]![booking.id!] +=
                      double.parse(descArray[1]);
                } else {
                  mapPayment[depositPayment]![booking.id!] =
                      double.parse(descArray[1]);
                }
              } else {
                mapPayment[depositPayment] = {
                  booking.id!: double.parse(descArray[1])
                };
              }
            }
          }
        }
        await FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(booking.group! ? booking.sID : booking.id)
            .collection(FirebaseHandler.colServices)
            .where("cat", whereIn: [
              ServiceManager.OTHER_CAT,
              ServiceManager.ELECTRICITY_CAT
            ])
            .get()
            .then((service) {
              for (var element in service.docs) {
                DateTime timeCreate =
                    (element["created"] as Timestamp).toDate();
                if (((timeCreate.isAfter(startDate) &&
                            timeCreate.isBefore(endDate)) ||
                        (timeCreate.isBefore(booking.inDate!) &&
                            int.parse(selectMonth) == booking.inDate!.month) ||
                        (timeCreate.isAfter(booking.outDate!) &&
                            int.parse(selectMonth) ==
                                booking.outDate!.month)) &&
                    element["room"] == booking.room) {
                  if (element["cat"] == ServiceManager.OTHER_CAT) {
                    dataSetOther.add(
                        OtherManager().getServiceNameByID(element.get("type")));
                    if (serviceOther.containsKey(booking.id)) {
                      if (serviceOther[booking.id!]!.containsKey(OtherManager()
                          .getServiceNameByID(element.get("type")))) {
                        serviceOther[booking.id!]![OtherManager()
                                .getServiceNameByID(element.get("type"))] +=
                            element.get("total");
                      } else {
                        serviceOther[booking.id!]![OtherManager()
                                .getServiceNameByID(element.get("type"))] =
                            element.get("total");
                      }
                    } else {
                      serviceOther[booking.id!] = {
                        OtherManager().getServiceNameByID(element.get("type")):
                            element.get("total")
                      };
                    }
                  } else if (element["cat"] == ServiceManager.ELECTRICITY_CAT) {
                    if (serviceElectricity.containsKey(booking.id)) {
                      serviceElectricity[booking.id!]!["initial_number"] =
                          "${serviceElectricity[booking.id!]!["initial_number"]} - ${element.get("initial_number")}";
                      serviceElectricity[booking.id!]!["final_number"] =
                          "${serviceElectricity[booking.id!]!["final_number"]} - ${element.get("final_number")}";
                    } else {
                      serviceElectricity[booking.id!] = {
                        "initial_number": element.get("initial_number"),
                        "final_number": element.get("final_number"),
                      };
                    }
                  }
                }
              }
            });
      }
    }
  }

  void getRevenueByRoomReportNextPage() async {}

  void getRevenueByRoomReportPreviousPage() async {}

  void getRevenueByRoomReportFirstPage() {}

  void getRevenueByRoomReportLastPage() {}

  num getAverageRoomRate(Booking booking) {
    if (booking.totalRoomCharge == 0) return 0;
    return (booking.totalRoomCharge! / booking.lengthRender!).round();
  }

  List<String> yearsList(int startYear, int endYear) {
    List<String> years = [];
    for (int year = startYear; year <= endYear; year++) {
      years.add(year.toString());
    }
    return years;
  }
}
