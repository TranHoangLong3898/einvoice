import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../manager/bookingmanager.dart';
import '../../manager/generalmanager.dart';
import '../../manager/rateplanmanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/countryulti.dart';
import '../../util/dateutil.dart';
import '../../util/messageulti.dart';
import '../dailyallotmentstatic.dart';

class UpdateGroupController extends ChangeNotifier {
  TextEditingController? teName,
      teSourceID,
      teEmail,
      tePhone,
      teNotes,
      teSaler,
      teExternalSaler;
  DateTime? outDate, inDate, inDateOld, outDateOld;
  Map<String, NeutronInputNumberController> teNums = {};
  Map<String, dynamic> priceTotalAndQuantityRoomTotal = {};
  Map<String, List<num>> pricesPerNight = {};
  bool breakfast = false;
  bool dinner = false;
  bool lunch = false;
  bool payAtHotel = true;
  bool isCheckUpdateDate = false;
  bool isCheckEmail = false, isLoadingCheckEmail = false;
  List<DateTime>? staysDate = [];
  Set<String> staysMonth = {};
  Map<String, Set<String>> availableRooms = {};
  Map<String, List<String>> roomPicks = {};
  List<String> listCountry = CountryUtil.getCountries();
  late String sourceID, _typeTourists, ratePlanID, teCountry;
  bool isLoading = false;
  List<num> price = [];
  List<Booking>? bookings;
  List<String> listID = [];
  Set<String> listRoomTypeID = {};
  Map<String, String> mapRoomIdAndTypeId = {};
  Map<String, List<String>> listStayDayBooking = {};
  Map<String, Map<String, String>> listIdBookingGroup = {};
  Map<String, Map<String, List<num>>> pricesPerNightUpdate = {};
  Map<String, Map<String, List<num>>> pricesPerNightCheckOut = {};
  String emailSalerOld = '';
  late String selectTypeBooking;
  late int statusBookingType;

  List<String> get listTypeBooking => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY),
      ];

  List<String> get listTypeTourists => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNKNOWN),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN)
      ];

  String getTypeTouristsNameByID() {
    if (_typeTourists == TypeTourists.domestic) {
      return UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC);
    }
    if (_typeTourists == TypeTourists.foreign) {
      return UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN);
    }
    return UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNKNOWN);
  }

  void setTypeTourists(String newTypeTourist) {
    if (newTypeTourist == getTypeTouristsNameByID()) return;
    if (newTypeTourist ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC)) {
      _typeTourists = TypeTourists.domestic;
      teCountry = GeneralManager.hotel!.country!;
    } else if (newTypeTourist ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN)) {
      _typeTourists = TypeTourists.foreign;
      teCountry = '';
    } else if (newTypeTourist ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNKNOWN)) {
      _typeTourists = TypeTourists.unknown;
      teCountry = '';
    }
    notifyListeners();
  }

  UpdateGroupController(
    this.bookings,
  ) {
    isLoading = true;
    notifyListeners();
    updateAvailableRooms().then((_) async {
      await init();
      isLoading = false;
      notifyListeners();
    });
  }

  init() async {
    if (getListBookingIn().isEmpty && getListBookingBooked().isEmpty) {
      Booking parent = bookings!
          .where((element) => element.status == BookingStatus.checkout)
          .first;
      inDateOld = parent.inDate!;
      outDateOld = parent.outDate!;
      inDate = parent.inDate!;
      outDate = parent.outDate!;
      teName = TextEditingController(text: parent.name);
      teEmail = TextEditingController(text: parent.email);
      tePhone = TextEditingController(text: parent.phone);
      teNotes = TextEditingController(text: await parent.getNotesBySid());
      teSourceID = TextEditingController(text: parent.sID);
      teSaler = TextEditingController(text: parent.saler ?? "");
      teExternalSaler = TextEditingController(text: parent.externalSaler ?? "");
      emailSalerOld = teSaler!.text;
      teCountry = parent.country!;
      _typeTourists = parent.typeTourists!;
      breakfast = parent.breakfast!;
      lunch = parent.lunch ?? false;
      dinner = parent.dinner ?? false;
      payAtHotel = parent.payAtHotel!;
      sourceID = parent.sourceID!;
      ratePlanID = parent.ratePlanID!;
      selectTypeBooking = parent.bookingType == null
          ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)
          : parent.bookingType == BookingType.dayly
              ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)
              : UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY);
      statusBookingType = parent.bookingType ?? BookingType.dayly;
      for (var roomTypeID in listRoomTypeID) {
        teNums[roomTypeID] = NeutronInputNumberController(TextEditingController(
            text: bookings!
                .where((element) => element.status == BookingStatus.checkout)
                .length
                .toString()));
        priceTotalAndQuantityRoomTotal[roomTypeID] = {};
        priceTotalAndQuantityRoomTotal[roomTypeID]['num'] = 0;
        priceTotalAndQuantityRoomTotal[roomTypeID]['price'] = 0;
        await updatePricePerNight(
            roomTypeID, teNums[roomTypeID]!.controller.text);
      }

      if (statusBookingType == BookingType.monthly) {
        getDayByMonth(inDate!, outDate!);
      } else {
        staysDate = DateUtil.getStaysDay(inDate!, outDate!);
      }
    } else {
      Booking parent = await BookingManager()
          .getBookingGroupByID(getListBookingInAndBooked().first.sID!);
      getDataBooking();
      inDateOld = parent.inDate!;
      outDateOld = parent.outDate!;
      inDate = parent.inDate!;
      outDate = parent.outDate!;
      teName = TextEditingController(text: parent.name);
      teEmail = TextEditingController(text: parent.email);
      tePhone = TextEditingController(text: parent.phone);
      teNotes = TextEditingController(text: await parent.getNotesBySid());
      teSourceID = TextEditingController(text: parent.sID);
      teSaler = TextEditingController(text: parent.saler ?? "");
      teExternalSaler = TextEditingController(text: parent.externalSaler ?? "");
      emailSalerOld = teSaler!.text;
      teCountry = getListBookingInAndBooked().first.country!;
      _typeTourists = getListBookingInAndBooked().first.typeTourists!;
      breakfast = getListBookingInAndBooked().first.breakfast!;
      lunch = getListBookingInAndBooked().first.lunch ?? false;
      dinner = getListBookingInAndBooked().first.dinner ?? false;
      payAtHotel = parent.payAtHotel!;
      sourceID = parent.sourceID!;
      ratePlanID = parent.ratePlanID!;
      selectTypeBooking = parent.bookingType == null
          ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)
          : parent.bookingType == BookingType.dayly
              ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)
              : UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY);
      statusBookingType = parent.bookingType ?? BookingType.dayly;
      for (var roomTypeID in listRoomTypeID) {
        teNums[roomTypeID] = NeutronInputNumberController(TextEditingController(
            text: getListBookingInAndBooked()
                .where((element) => element.roomTypeID == roomTypeID)
                .length
                .toString()));
        priceTotalAndQuantityRoomTotal[roomTypeID] = {};
        priceTotalAndQuantityRoomTotal[roomTypeID]['num'] = 0;
        priceTotalAndQuantityRoomTotal[roomTypeID]['price'] = 0;
        await updatePricePerNight(
            roomTypeID, teNums[roomTypeID]!.controller.text);
      }

      if (statusBookingType == BookingType.monthly) {
        getDayByMonth(inDate!, outDate!);
      } else {
        staysDate = DateUtil.getStaysDay(inDate!, outDate!);
      }
      if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler!.text) {
        isCheckEmail = true;
      }
    }
  }

  getDataBooking() {
    for (var booking in getListBookingInAndBooked()) {
      listRoomTypeID.add(booking.roomTypeID!);
      pricesPerNightUpdate[booking.room!] = {};
      pricesPerNightUpdate[booking.room]![booking.roomTypeID!] = booking.price!;
      listID.add(booking.id!);
    }
    for (var booking in getListBookingOut()) {
      pricesPerNightCheckOut[booking.room!] = {};
      pricesPerNightCheckOut[booking.room]![booking.roomTypeID!] =
          booking.price!;
    }
    for (var booking in bookings!.where((element) =>
        element.status == BookingStatus.checkout ||
        element.status == BookingStatus.booked ||
        element.status == BookingStatus.checkin)) {
      mapRoomIdAndTypeId[booking.room!] = booking.roomTypeID!;
    }
  }

  Future<void> setInDate(DateTime date) async {
    final newInDate = DateUtil.to12h(date);
    if (DateUtil.to12h(DateTime.now()).isAfter(newInDate)) return;
    if (newInDate.compareTo(inDate!) == 0) return;
    isLoading = true;
    notifyListeners();
    inDate = newInDate;
    if (outDate!.difference(inDate!).inDays <= 0) {
      outDate = inDate!.add(const Duration(days: 1));
    }
    isCheckUpdateDate = inDate != inDateOld || outDate != outDateOld;
    if (getListBookingIn().isNotEmpty) {
      for (var element in getListBookingIn()) {
        if (statusBookingType == BookingType.monthly) {
          getDayByMonth(element.inDate!, outDate!);
        } else {
          staysDate = DateUtil.getStaysDay(element.inDate!, outDate!);
        }
      }
    } else {
      if (statusBookingType == BookingType.monthly) {
        getDayByMonth(inDate!, outDate!);
      } else {
        staysDate = DateUtil.getStaysDay(inDate!, outDate!);
      }
    }
    await updatePriceWithRatePlanIdOrInDateOrOutDate();
    await updateAvailableRooms();
    isLoading = false;
    notifyListeners();
  }

  Future<void> setOutDate(DateTime date) async {
    final newOutDate = DateUtil.to12h(date);
    if (newOutDate.isBefore(inDate!)) return;
    if (newOutDate.compareTo(outDate!) == 0) return;
    isLoading = true;
    notifyListeners();
    outDate = newOutDate;
    isCheckUpdateDate = outDate != outDateOld || inDate != inDateOld;
    if (getListBookingIn().isNotEmpty) {
      for (var element in getListBookingIn()) {
        if (statusBookingType == BookingType.monthly) {
          getDayByMonth(element.inDate!, outDate!);
        } else {
          staysDate = DateUtil.getStaysDay(element.inDate!, outDate!);
        }
      }
    } else {
      if (statusBookingType == BookingType.monthly) {
        getDayByMonth(inDate!, outDate!);
      } else {
        staysDate = DateUtil.getStaysDay(inDate!, outDate!);
      }
    }
    await updatePriceWithRatePlanIdOrInDateOrOutDate();
    await updateAvailableRooms();
    if (bookings != null) {
      pricesPerNightUpdate.clear();
      for (var element in getListBookingInAndBooked()) {
        pricesPerNightUpdate[element.room!] = {};
        pricesPerNightUpdate[element.room]![element.roomTypeID!] =
            element.price!;
      }
    }
    isLoading = false;
    notifyListeners();
  }

  DateTime getFirstDate() {
    final now = Timestamp.now().toDate();
    final now12h = DateUtil.to12h(now);
    if (now.compareTo(now12h) >= 0) {
      return now12h;
    } else {
      return now12h.subtract(const Duration(days: 1));
    }
  }

  DateTime getLastDate() {
    final now = Timestamp.now().toDate();
    return now.add(const Duration(days: 499));
  }

  void setBreakfast(bool breakfast) {
    if (breakfast != this.breakfast) {
      this.breakfast = breakfast;
      notifyListeners();
    }
  }

  void setLunch(bool lunch) {
    if (lunch != this.lunch) {
      this.lunch = lunch;
      notifyListeners();
    }
  }

  void setDinner(bool dinner) {
    if (dinner != this.dinner) {
      this.dinner = dinner;
      notifyListeners();
    }
  }

  void setPayAtHotel(bool payAtHotel) {
    if (payAtHotel != this.payAtHotel) {
      this.payAtHotel = payAtHotel;
      notifyListeners();
    }
  }

  void setSourceID(String sourceID) {
    if (sourceID != this.sourceID) {
      this.sourceID = sourceID;
      notifyListeners();
    }
  }

  Future<void> setRatePlanID(String ratePlanID) async {
    if (ratePlanID != this.ratePlanID) {
      this.ratePlanID = ratePlanID;
      await updatePriceWithRatePlanIdOrInDateOrOutDate();
      notifyListeners();
    }
  }

  num getTotalPricePerNight(String roomTypeID) {
    if (statusBookingType == BookingType.monthly) {
      num total = 0;
      for (int i = 0; i < staysMonth.length; i++) {
        total += (pricesPerNight[roomTypeID]?[i] ?? 0);
      }
      return total;
    }
    return pricesPerNight[roomTypeID]!
        .fold(0, (previousValue, element) => previousValue + element);
  }

  Future<void> updatePriceWithRatePlanIdOrInDateOrOutDate() async {
    pricesPerNight.clear();
    for (var roomTypeID in listRoomTypeID) {
      await updatePricePerNight(roomTypeID,
          priceTotalAndQuantityRoomTotal[roomTypeID]['num'].toString());
    }
  }

  Future<void> updatePricePerNight(String roomTypeID, String value) async {
    value = value.replaceAll(',', '');
    final regex = RegExp(r'^[0]+$');
    if (value == '' || regex.allMatches(value).isNotEmpty) {
      pricesPerNight[roomTypeID] = [0];
      priceTotalAndQuantityRoomTotal[roomTypeID]['price'] = 0;
      priceTotalAndQuantityRoomTotal[roomTypeID]['num'] = 0;
    } else {
      Map<String, Map<String, dynamic>> data = {};
      for (var element in getListBookingInAndBooked()) {
        data[element.roomTypeID!] = {};
      }
      if (getListBookingIn().isNotEmpty && getListBookingBooked().isNotEmpty) {
        for (var bookingBook in getListBookingBooked()) {
          for (var element in getListBookingIn()) {
            data[roomTypeID] = await DailyAllotmentStatic()
                .getPriceAndBookedRooms(element.inDate!, outDate!, roomTypeID);
            for (var i = 0;
                i < inDate!.difference(element.inDate!).inDays;
                i++) {
              if (data[bookingBook.roomTypeID]!['price'] != null &&
                  element.roomTypeID != bookingBook.roomTypeID) {
                data[bookingBook.roomTypeID]!['price'][i] = 0;
              }
            }
          }
        }
      } else {
        data[roomTypeID] = await DailyAllotmentStatic()
            .getPriceAndBookedRooms(inDate!, outDate!, roomTypeID);
      }
      Map<String, dynamic> totalPriceOfRoomType = {roomTypeID: 0};
      if (statusBookingType == BookingType.monthly) {
        // ///old
        pricesPerNight[roomTypeID] = [];

        ///new
        Map<String, List<num>> pricesPerNightNews = {};
        pricesPerNightNews[roomTypeID] = [];
        pricesPerNightNews[roomTypeID] = pricesPerNightUpdate.entries
            .where((element) => element.value.containsKey(roomTypeID))
            .first
            .value[roomTypeID]!;

        int tatolLength = staysMonth.length + staysDate!.length;
        if (staysMonth.length <
            (pricesPerNightNews[roomTypeID]!.length - staysDate!.length)) {
          for (var i = 0; i < staysMonth.length; i++) {
            pricesPerNight[roomTypeID]!.add(pricesPerNightNews[roomTypeID]![0]);
          }
        } else {
          for (var i = 0; i < staysMonth.length; i++) {
            pricesPerNight[roomTypeID]!.add(pricesPerNightNews[roomTypeID]![0]);
          }
        }
        if (staysDate!.isNotEmpty) {
          if (staysDate!.length < pricesPerNightNews[roomTypeID]!.length) {
            for (var i = staysMonth.length; i < tatolLength; i++) {
              pricesPerNight[roomTypeID]!
                  .add(pricesPerNightNews[roomTypeID]![i]);
            }
          } else {
            for (var i = staysMonth.length; i < tatolLength; i++) {
              pricesPerNight[roomTypeID]!.add(
                  i >= pricesPerNightNews[roomTypeID]!.length
                      ? pricesPerNightNews[roomTypeID]![
                          pricesPerNightNews[roomTypeID]!.length - 1]
                      : pricesPerNightNews[roomTypeID]![i]);
            }
          }
          getPriceAverage(
              pricesPerNight[roomTypeID]![staysMonth.length - 1], roomTypeID);
        }

        ///tính tổng
        if (staysMonth.length <= 1) {
          for (var i = staysDate!.isEmpty ? 0 : staysMonth.length;
              i < (staysMonth.length + staysDate!.length);
              i++) {
            totalPriceOfRoomType[roomTypeID] +=
                (pricesPerNight[roomTypeID]?[i] ?? 0);
          }
        } else {
          for (var i = 0;
              i < (staysMonth.length - (staysDate!.isEmpty ? 0 : 1));
              i++) {
            totalPriceOfRoomType[roomTypeID] +=
                (pricesPerNight[roomTypeID]?[i] ?? 0);
          }
          if (staysDate!.isNotEmpty) {
            for (var i = staysMonth.length;
                i < (staysMonth.length + staysDate!.length);
                i++) {
              totalPriceOfRoomType[roomTypeID] +=
                  (pricesPerNight[roomTypeID]?[i] ?? 0);
            }
          }
        }
        totalPriceOfRoomType[roomTypeID] =
            (totalPriceOfRoomType[roomTypeID] * num.parse(value));
      } else {
        pricesPerNight[roomTypeID] = RatePlanManager()
            .getPriceWithRatePlanID(ratePlanID, data[roomTypeID]!['price']);
        totalPriceOfRoomType[roomTypeID] = pricesPerNight[roomTypeID]!.fold(
            0.0,
            (previousValue, element) =>
                previousValue + element * num.parse(value));
      }
      priceTotalAndQuantityRoomTotal[roomTypeID] = {};
      priceTotalAndQuantityRoomTotal[roomTypeID]['price'] =
          totalPriceOfRoomType[roomTypeID];
      priceTotalAndQuantityRoomTotal[roomTypeID]['num'] = num.parse(value);
    }
    notifyListeners();
  }

  num getTotalPrices() {
    return (priceTotalAndQuantityRoomTotal.entries.fold(
        0, (previousValue, element) => previousValue + element.value['price']));
  }

  void updatePricePerNightWithPriceDialog(
      List<num> priceModifed, String roomTypeID) {
    pricesPerNight[roomTypeID] = priceModifed;
    num totalPriceOfRoomType = 0;
    if (statusBookingType == BookingType.monthly) {
      if (staysMonth.length <= 1) {
        for (var i = staysDate!.isEmpty ? 0 : staysMonth.length;
            i < (staysMonth.length + staysDate!.length);
            i++) {
          totalPriceOfRoomType += (pricesPerNight[roomTypeID]?[i] ?? 0);
        }
      } else {
        for (var i = 0;
            i < (staysMonth.length - (staysDate!.isEmpty ? 0 : 1));
            i++) {
          totalPriceOfRoomType += (pricesPerNight[roomTypeID]?[i] ?? 0);
        }
        if (staysDate!.isNotEmpty) {
          for (var i = staysMonth.length;
              i < (staysMonth.length + staysDate!.length);
              i++) {
            totalPriceOfRoomType += (pricesPerNight[roomTypeID]?[i] ?? 0);
          }
        }
      }
      totalPriceOfRoomType = totalPriceOfRoomType *
          priceTotalAndQuantityRoomTotal[roomTypeID]['num'];
    } else {
      totalPriceOfRoomType = priceModifed.fold(
          0,
          (previousValue, element) =>
              previousValue +
              element * priceTotalAndQuantityRoomTotal[roomTypeID]['num']);
    }
    priceTotalAndQuantityRoomTotal[roomTypeID]['price'] = totalPriceOfRoomType;
    notifyListeners();
  }

  Future<void> checkAvailableRoomsOfInOutBooking() async {
    for (var booked in getListBookingInAndBooked()) {
      availableRooms[booked.roomTypeID!] = {};
    }
    for (var booked in getListBookingInAndBooked()) {
      if (inDate != null && outDate != null) {
        if (inDate == booked.inDate) {
          print("line--347 -- có thực hiện --- ${booked.room}");
          availableRooms[booked.roomTypeID]!.add(booked.room!);
          if (inDateOld == inDate &&
              outDate != outDateOld &&
              outDate != booked.outDate &&
              outDate!.isAfter(booked.outDate!)) {
            List<String> roomBook = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!);
            if (roomBook.contains(booked.room)) {
              print("line---359 -- chưa thực thực -- ${booked.room}");
            } else {
              availableRooms[booked.roomTypeID]!.remove(booked.room);
              print("line---363 -- Có thực hiện -- ${booked.room}");
            }
          }
        } else {
          if (inDate!.isBefore(booked.inDate!)) {
            List<String> roomBookIn = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(inDate!),
                    DateUtil.to12h(booked.inDate!),
                    booked.roomTypeID!);
            if (roomBookIn.contains(booked.room)) {
              print("line---357 -- Có thực hiện -- ${booked.room}");
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          }
          if (inDate!.isAfter(booked.inDate!)) {
            print("line---362 -- có thực hiện -- ${booked.room}");
            availableRooms[booked.roomTypeID]!.add(booked.room!);
          }
        }
        if (outDate == booked.outDate) {
          print("line---367 -- chưa thực hiện -- ${booked.room}");
          if (inDateOld != booked.inDate) {
            List<String> roomBookIn = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(inDate!),
                    DateUtil.to12h(booked.inDate!),
                    booked.roomTypeID!);
            if (roomBookIn.contains(booked.room)) {
              print("line--- 375 -- chưa thực hiện -- ${booked.room}");
            } else {
              if (booked.outDate != outDate) {
                print("line---378 -- Có thực hiện -- ${booked.room}");
                availableRooms[booked.roomTypeID]!.remove(booked.room);
              }
            }
          }
        } else {
          if (outDate!.isAfter(booked.outDate!)) {
            List<String> roomBook = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!);
            if (roomBook.contains(booked.room)) {
              print("line---391 -- Có thực hiện -- ${booked.room}");
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          }
          if (outDateOld!.isBefore(booked.outDate!)) {
            print("line---396 -- chưa thực hiện -- ${booked.room}");
          }
          if (outDateOld!.isAfter(booked.outDate!) &&
              outDate!.isAfter(booked.outDate!)) {
            List<String> roomBook = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!);
            if (roomBook.contains(booked.room)) {
              print("line---406 -- có thực thực -- ${booked.room}");
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            } else {
              availableRooms[booked.roomTypeID]!.remove(booked.room);
              print("line---410 -- Có thực hiện -- ${booked.room}");
            }
            if (inDateOld != booked.inDate && inDateOld == inDate) {
              List<String> roomBookIn = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(inDate!),
                      DateUtil.to12h(booked.inDate!),
                      booked.roomTypeID!);
              if (roomBookIn.contains(booked.room)) {
                print("line--- 419 -- chưa thực hiện -- ${booked.room}");
              } else {
                print("line---421 -- Có thực hiện --- ${booked.room}");
                availableRooms[booked.roomTypeID]!.remove(booked.room);
              }
            }
          }
          if (outDate!.isBefore(booked.outDate!) && inDate == booked.inDate) {
            availableRooms[booked.roomTypeID]!.add(booked.room!);
            print("line---428 -- có thực hiện --- ${booked.room}");
          } else {
            print("line--- 430 -- chưa thực hiện -- ${booked.room}");
            if (inDate != booked.inDate && inDate!.isBefore(booked.inDate!)) {
              List<String> roomBookIn = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(inDate!),
                      DateUtil.to12h(booked.inDate!),
                      booked.roomTypeID!);
              if (roomBookIn.contains(booked.room)) {
                print("line--- 438 -- chưa thực hiện -- ${booked.room}");
              } else {
                print("line---440 -- có thực hiện --- ${booked.room}");
                availableRooms[booked.roomTypeID]!.remove(booked.room);
              }
            }
            if (outDateOld!.isAfter(booked.outDate!) &&
                outDate!.isAfter(booked.outDate!)) {
              List<String> roomBook = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(booked.outDate!),
                      DateUtil.to12h(outDate!),
                      booked.roomTypeID!);
              if (roomBook.contains(booked.room)) {
                print("line---459 -- có thực hiện --- ${booked.room}");
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              } else {
                List<String> roomBook = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(inDate!),
                        DateUtil.to12h(outDate!),
                        booked.roomTypeID!);
                if (roomBook.contains(booked.room)) {
                  print("line---461 -- có thực thực --- ${booked.room}");
                  availableRooms[booked.roomTypeID]!.add(booked.room!);
                } else {
                  print("line---464-- Chưa thực hiện --- ${booked.room}");
                }
              }
            }
            if (inDate != booked.inDate &&
                outDate != booked.outDate &&
                inDate!.isBefore(booked.inDate!) &&
                outDate!.isAfter(booked.outDate!) &&
                booked.inDate == inDateOld &&
                booked.outDate == outDateOld) {
              List<String> roomBook = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(inDate!),
                      DateUtil.to12h(outDate!),
                      booked.roomTypeID!);
              if (roomBook.contains(booked.room)) {
                print("line---478 -- chưa thực thực --- ${booked.room}");
              } else {
                print("line---480 -- Có thực hiện --- ${booked.room}");
                availableRooms[booked.roomTypeID]!.remove(booked.room);
              }
            }
          }
        }
      }
    }
  }

  Future<void> checkAvailableRoomsOfInOutBooking2() async {
    for (var booked in getListBookingBooked()) {
      availableRooms[booked.roomTypeID!] = {};
    }
    for (var booked in getListBookingIn()) {
      availableRooms[booked.roomTypeID!] = {};
    }

    for (var booked in getListBookingBooked()) {
      print("------------ line 350 BOOKED---------------");
      if (outDate != null &&
          outDate != booked.outDate &&
          outDate!.isAfter(booked.outDate!)) {
        if (inDate != booked.inDate && outDate != booked.outDate) {
          print("line--364");
          if (booked.outDate!.isBefore(outDateOld!)) {
            /////
            print(booked.outDate!.isBefore(inDate!));
            if (inDateOld == booked.inDate &&
                outDateOld != booked.outDate &&
                (booked.outDate == inDate ||
                    booked.outDate!.isBefore(inDate!))) {
              print("line--375");
              print(booked.room);
              List<String> roomBook = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(inDate!),
                      DateUtil.to12h(outDate!),
                      booked.roomTypeID!);
              if (roomBook.contains(booked.room)) {
                print(booked.room);
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            } else {
              if (listRoomTypeID.length == 1) {
                print("line--387");
                List<String> roomInDate = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(inDate!),
                        DateUtil.to12h(booked.inDate!),
                        booked.roomTypeID!);
                List<String> roomBook = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(booked.outDate!),
                        DateUtil.to12h(outDate!),
                        booked.roomTypeID!);
                if (roomBook.contains(booked.room) &&
                    roomInDate.contains(booked.room)) {
                  availableRooms[booked.roomTypeID]!.add(booked.room!);
                }
              }
              if (listRoomTypeID.length > 1 &&
                  inDate!.isAfter(booked.inDate!) &&
                  inDateOld != inDate) {
                print("line--571");
                print(booked.room);
                List<String> roomBook = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(booked.outDate!),
                        DateUtil.to12h(outDate!),
                        booked.roomTypeID!);
                if (roomBook.contains(booked.room)) {
                  availableRooms[booked.roomTypeID]!.add(booked.room!);
                }
              }
            }
          }
          if (booked.inDate!.isAfter(inDateOld!) &&
              !booked.outDate!.isBefore(outDateOld!)) {
            print("line--370");
            if ((inDate == booked.outDate ||
                    inDate!.isBefore(booked.outDate!)) &&
                ////
                inDate == inDateOld) {
              if (inDate != inDateOld) {
                print("line--371");
                List<String> roomBook = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(booked.outDate!),
                        DateUtil.to12h(outDate!),
                        booked.roomTypeID!);
                if (roomBook.contains(booked.room)) {
                  availableRooms[booked.roomTypeID]!.add(booked.room!);
                }
              } else {
                print("line--384");
                List<String> roomInDate = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(inDate!),
                        DateUtil.to12h(booked.inDate!),
                        booked.roomTypeID!);
                List<String> roomOutDate = await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(booked.outDate!),
                        DateUtil.to12h(outDate!),
                        booked.roomTypeID!);
                if (roomInDate.contains(booked.room) &&
                    roomOutDate.contains(booked.room)) {
                  availableRooms[booked.roomTypeID]!.add(booked.room!);
                  print("${availableRooms[booked.roomTypeID]} ----> line-396");
                }
              }
              //bat suw check lecjk in khac nhau in book
            } else {
              print("line--403");
              print(booked.room);
              if (outDate == inDateOld) {
                await DailyAllotmentStatic()
                    .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                        DateUtil.to12h(inDate!),
                        DateUtil.to12h(booked.inDate!),
                        booked.roomTypeID!)
                    .then((value) {
                  if (value.contains(booked.room)) {
                    availableRooms[booked.roomTypeID]!.add(booked.room!);
                  }
                });
              }
            }
          }
          if (booked.inDate!.isAfter(inDateOld!) &&
              booked.outDate!.isBefore(outDateOld!)) {
            print("line--418");
            if (inDate == booked.outDate ||
                inDate!.isBefore(booked.outDate!) ||
                inDate!.isAfter(booked.outDate!)) {
              print("line--422");
              //bat suw check lecjk in khac nhau in book
              List<String> roomBook = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(booked.outDate!),
                      DateUtil.to12h(outDate!),
                      booked.roomTypeID!);
              if (roomBook.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            } else {
              print("line--433");
              List<String> roomInDate = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(inDate!),
                      DateUtil.to12h(booked.inDate!),
                      booked.roomTypeID!);
              List<String> roomOutDate = await DailyAllotmentStatic()
                  .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                      DateUtil.to12h(booked.outDate!),
                      DateUtil.to12h(outDate!),
                      booked.roomTypeID!);
              if (roomInDate.contains(booked.room) &&
                  roomOutDate.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
                print("${availableRooms[booked.roomTypeID]} ----> line-396");
              }
            }
          }
        }
        if (inDate == booked.inDate) {
          print("line--453");
          if (booked.outDate!.isBefore(outDateOld!)) {
            print("line--455");
            await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!)
                .then((value) {
              if (value.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            });
          } else {
            print("line--467");
            await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!)
                .then((value) {
              if (value.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            });
          }
        }
      }

      if (inDate != null &&
          inDate != booked.inDate &&
          inDate!.isBefore(booked.inDate!)) {
        if (inDate != booked.inDate && outDate != booked.outDate) {
          print("line--486");
          if (booked.inDate!.isAfter(inDateOld!) &&
              outDate!.isBefore(outDateOld!) &&
              outDate != outDateOld) {
            print("line--505");
            await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(inDate!),
                    DateUtil.to12h(booked.inDate!),
                    booked.roomTypeID!)
                .then((value) {
              if (value.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            });
          }
          if (!booked.inDate!.isAfter(inDateOld!) &&
              booked.outDate!.isBefore(outDateOld!)) {
            print("line--522");
            ////
            List<String> roomInDate = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(inDate!),
                    DateUtil.to12h(booked.inDate!),
                    booked.roomTypeID!);
            List<String> roomOutDate = await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(booked.outDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!);
            if (roomInDate.contains(booked.room) &&
                roomOutDate.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          }
        }
        if (outDate == booked.outDate) {
          print("line--503");
          await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(inDate!),
                  DateUtil.to12h(booked.inDate!),
                  booked.roomTypeID!)
              .then((value) {
            if (value.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          });
        }
      }
      if ((inDate != null &&
              outDate == booked.outDate &&
              inDate != booked.inDate &&
              inDate != inDateOld &&
              !inDate!.isBefore(booked.inDate!)) ||
          (outDate != null &&
              inDate == booked.inDate &&
              outDate != booked.outDate &&
              outDate != outDateOld &&
              !outDate!.isAfter(booked.outDate!))) {
        print("line--- 528");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (inDate != null &&
          booked.inDate == inDate &&
          inDate != inDateOld &&
          outDate == booked.outDate) {
        print("line--- 535");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (outDate != null &&
          booked.outDate == outDate &&
          outDate != outDateOld &&
          inDate == booked.inDate) {
        print("line--- 542");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (inDate != null &&
          outDate != null &&
          inDate != booked.inDate &&
          outDate != booked.outDate &&
          inDate != inDateOld &&
          outDate != outDateOld) {
        print(
            "line-552 ---------  inDate != booked.inDate &&outDate != booked.outDate");
        if (inDate!.isBefore(booked.inDate!) &&
            outDate!.isAfter(booked.outDate!)) {
          print("line-554");
          List<String> roomInDate = await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(inDate!),
                  DateUtil.to12h(booked.inDate!),
                  booked.roomTypeID!);
          List<String> roomOutDate = await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(booked.outDate!),
                  DateUtil.to12h(outDate!),
                  booked.roomTypeID!);

          if (roomInDate.contains(booked.room) &&
              roomOutDate.contains(booked.room)) {
            availableRooms[booked.roomTypeID]!.add(booked.room!);
            print("${availableRooms[booked.roomTypeID]} ----> line-502");
          }
        }
        if (inDate!.isBefore(booked.inDate!) &&
            !outDate!.isAfter(booked.outDate!)) {
          print("line-579");
          await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(inDate!),
                  DateUtil.to12h(booked.inDate!),
                  booked.roomTypeID!)
              .then((value) {
            if (value.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          });
        }
        if (!inDate!.isBefore(booked.inDate!) &&
            outDate!.isAfter(booked.outDate!)) {
          // if (listRoomTypeID.length == 1) {
          print("line-89");
          await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(booked.outDate!),
                  DateUtil.to12h(outDate!),
                  booked.roomTypeID!)
              .then((value) {
            if (value.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          });
          // }
          if (listRoomTypeID.length > 1) {
            print("line-602");
            await DailyAllotmentStatic()
                .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                    DateUtil.to12h(inDate!),
                    DateUtil.to12h(outDate!),
                    booked.roomTypeID!)
                .then((value) {
              print(value);
              print(booked.room);
              if (value.contains(booked.room)) {
                availableRooms[booked.roomTypeID]!.add(booked.room!);
              }
            });
          }
        }
        if (!inDate!.isBefore(booked.inDate!) &&
            !outDate!.isAfter(booked.outDate!)) {
          print("line-619");
          print(booked.room);
          availableRooms[booked.roomTypeID]!.add(booked.room!);
        }
      }
      if (inDate == booked.inDate &&
          outDate == booked.outDate &&
          inDate != null &&
          outDate != null &&
          inDate != inDateOld &&
          outDate != outDateOld) {
        print("line-630");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
    }
    print("----------- $availableRooms ---->line 583");
    for (var booked in getListBookingIn()) {
      print("------------ line 636 IN---------------");
      if (outDate != null &&
          outDate != booked.outDate &&
          outDate!.isAfter(booked.outDate!)) {
        print(599);
        if (inDate == booked.inDate) {
          print("line--651");
          await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(booked.outDate!),
                  DateUtil.to12h(outDate!),
                  booked.roomTypeID!)
              .then((value) {
            if (value.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          });
        } else {
          print("line--663");
          await DailyAllotmentStatic()
              .getAvailableRoomsWithStaysDayAndRoomTypeiD(
                  DateUtil.to12h(booked.outDate!),
                  DateUtil.to12h(outDate!),
                  booked.roomTypeID!)
              .then((value) {
            if (value.contains(booked.room)) {
              availableRooms[booked.roomTypeID]!.add(booked.room!);
            }
          });
        }
      }
      if ((inDate != null &&
              outDate == booked.outDate &&
              inDate != booked.inDate &&
              inDate != inDateOld &&
              !inDate!.isBefore(booked.inDate!)) ||
          (outDate != null &&
              inDate == booked.inDate &&
              outDate != booked.outDate &&
              outDate != outDateOld &&
              !outDate!.isAfter(booked.outDate!))) {
        print("line--- 686");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (inDate != null &&
          booked.inDate == inDate &&
          inDate != inDateOld &&
          outDate == booked.outDate) {
        print("line--- 693");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (outDate != null &&
          booked.outDate == outDate &&
          outDate != outDateOld &&
          inDate == booked.inDate) {
        print("line--- 700");
        availableRooms[booked.roomTypeID]!.add(booked.room!);
      }
      if (inDate != null &&
          outDate != null &&
          inDate != booked.inDate &&
          outDate != booked.outDate &&
          inDate != inDateOld &&
          outDate != outDateOld) {
        print(
            "line-710 ---------  inDate != booked.inDate &&outDate != booked.outDate");
        if (!inDate!.isBefore(booked.inDate!) &&
            !outDate!.isAfter(booked.outDate!)) {
          print("line-777");
          print(booked.room);
          availableRooms[booked.roomTypeID]!.add(booked.room!);
        }
      }
    }
  }

  Future<void> updateAvailableRooms() async {
    availableRooms.clear();
    listIdBookingGroup.clear();
    listStayDayBooking.clear();
    await checkAvailableRoomsOfInOutBooking2();
    for (var roomTypeID in listRoomTypeID) {
      print("${availableRooms[roomTypeID]} ---->line 563");
      for (var element in availableRooms.keys) {
        for (var roomID in availableRooms[element]!) {
          for (var element in getListBookingInAndBooked()
              .where((element) => element.room == roomID)) {
            listIdBookingGroup[element.room!] = {};
            listIdBookingGroup[element.room]!["id"] = element.id!;
            listIdBookingGroup[element.room]!["inDate"] =
                element.inDate.toString();
            listIdBookingGroup[element.room]!["outDate"] =
                element.outDate.toString();
            listIdBookingGroup[element.room]!["status"] =
                element.status.toString();
            listIdBookingGroup[element.room]!["roomtype"] = element.roomTypeID!;
            listStayDayBooking[element.id!] =
                (await element.getStayDayById(element.id!))!;
          }
        }
      }
    }
  }

  String validateRoomToSecondPage() {
    final lengthStay = outDate!.difference(inDate!).inDays;
    if (lengthStay > GeneralManager.maxLengthStay &&
        statusBookingType == BookingType.dayly) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_MAX_LENGTHDAY_31);
    }
    if (lengthStay > 365 && statusBookingType == BookingType.monthly) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_MAX_LENGTHDAY_365);
    }
    if (outDate!.compareTo(inDate!) <= 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OUTDATE_MUST_LARGER_THAN_INDATE);
    }
    isLoading = true;
    notifyListeners();
    num isRoomTypeHaveNum = 0;
    for (var roomTypeID in availableRooms.keys) {
      if (priceTotalAndQuantityRoomTotal[roomTypeID]['num'] > 0) {
        isRoomTypeHaveNum++;
        if (priceTotalAndQuantityRoomTotal[roomTypeID]['num'] >
            availableRooms[roomTypeID]!.length) {
          isLoading = false;
          notifyListeners();
          return MessageUtil.getMessageByCode(
              MessageCodeUtil.BOOKING_GROUP_NOT_ENOUGH_ROOM);
        }
      }
    }
    if (isRoomTypeHaveNum == 0) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_VALID_ROOM);
    }
    isLoading = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  void updateRoomPick() {
    for (var element in availableRooms.entries) {
      roomPicks[element.key] = [];
      roomPicks[element.key] = element.value
          .toList()
          .getRange(0, priceTotalAndQuantityRoomTotal[element.key]['num'])
          .toList();
    }
  }

  void onTapRoomPick(String roomtypeID, String roomID) {
    if (roomPicks[roomtypeID]!.contains(roomID)) {
      roomPicks[roomtypeID]!.removeWhere((element) => element == roomID);
    } else {
      roomPicks[roomtypeID]!.add(roomID);
    }
    notifyListeners();
  }

  void setCountry(String country) {
    if (teCountry == country) return;
    teCountry = country;
    notifyListeners();
  }

  void clearData() {
    if (bookings != null) {
      pricesPerNightUpdate.clear();
      pricesPerNightCheckOut.clear();
      price.clear();
    }
    notifyListeners();
  }

  Future<String> updateGroup() async {
    if (await checkHaveChangeBooking()) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (teSaler!.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    // check room pick here
    for (var element in roomPicks.entries) {
      if (element.value.length !=
          priceTotalAndQuantityRoomTotal[element.key]['num']) {
        isLoading = false;
        notifyListeners();
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.BOOKING_GROUP_ROOM_PICK_INVALID);
      }
    }

    if (!listCountry.contains(teCountry) &&
        _typeTourists != TypeTourists.unknown) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CHOOSE_RIGHT_COUNTRY);
    }

    if (_typeTourists == TypeTourists.foreign && teCountry == '') {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CHOOSE_COUNTRY);
    }

    if (_typeTourists == TypeTourists.domestic &&
        teCountry != GeneralManager.hotel!.country!) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PLEASE_CHOOSE_RIGHT_COUNTRY);
    }
    isLoading = true;
    notifyListeners();
    try {
      updatePriceOfBookingByRoomAndRomType();
      print("End $pricesPerNightUpdate");
      print("END12:$price");
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('booking-updateAllBookingGroup');
      final result = await callable({
        'map_room_types': roomPicks,
        'hotel_id': GeneralManager.hotelID,
        'price_per_night': pricesPerNightUpdate,
        'in_date': inDate.toString(),
        'out_date': outDate.toString(),
        'in_date_old': inDateOld.toString(),
        'out_date_old': outDateOld.toString(),
        'pay_at_hotel': payAtHotel,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'source_id': sourceID,
        'sID': teSourceID!.text,
        'name': teName!.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        'email': teEmail!.text,
        'phone': tePhone!.text,
        'rate_plan_id': ratePlanID,
        'type_tourists': _typeTourists,
        'country': teCountry,
        'notes': teNotes!.text,
        'id_booking': listIdBookingGroup,
        'price': price,
        'stay_day': listStayDayBooking,
        'check_booking': isCheckChangeBooking(),
        'list_id': listID,
        'saler': teSaler!.text,
        'external_saler': teExternalSaler!.text,
        'booking_type': statusBookingType,
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        clearData();
        isLoading = false;
        notifyListeners();
        return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
      }
    } on FirebaseFunctionsException catch (error) {
      print(error);
      clearData();
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(error.message);
    }
    isLoading = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  }

  updatePriceOfBookingByRoomAndRomType() {
    price.clear();
    for (var roomTypeID in roomPicks.keys) {
      for (var room in roomPicks[roomTypeID]!) {
        if (pricesPerNightUpdate[room]![roomTypeID]!.length !=
            pricesPerNight[roomTypeID]!.length) {
          //cux vs < moiw
          if (pricesPerNightUpdate[room]![roomTypeID]!.length <
              pricesPerNight[roomTypeID]!.length) {
            for (var i = pricesPerNightUpdate[room]![roomTypeID]!.length;
                i < pricesPerNight[roomTypeID]!.length;
                i++) {
              pricesPerNightUpdate[room]![roomTypeID]!
                  .insert(i, pricesPerNight[roomTypeID]![i]);
            }
          } else {
            pricesPerNightUpdate[room]![roomTypeID]!.removeRange(
                pricesPerNight[roomTypeID]!.length,
                pricesPerNightUpdate[room]![roomTypeID]!.length);
          }
        }
      }
    }

    for (var bookingOut in getListBookingBooked()) {
      for (var bookingIn in getListBookingIn()) {
        for (var i = 0; i < inDate!.difference(bookingIn.inDate!).inDays; i++) {
          pricesPerNightUpdate[bookingOut.room]![bookingOut.roomTypeID]![i] = 0;
        }
      }
    }

    // / KIỂM TRA DỘ DÀI NGÀY Ở DÀI NHẤT UDATPE PRICE
    int maxLengthBooke = -1;
    int maxLengthOut = -1;
    int maxLengthIn = -1;
    List<num> longestArrayBooke = [];
    List<num> longestArrayOut = [];
    List<num> longestArrayIn = [];
    for (var element in getListBookingOut()) {
      if (element.price!.length > maxLengthOut) {
        maxLengthOut = element.price!.length;
        longestArrayOut = element.price!;
      }
    }
    for (var element in getListBookingIn()) {
      if (element.price!.length > maxLengthIn) {
        maxLengthIn = element.price!.length;
        longestArrayIn = element.price!;
      }
    }
    for (var element in getListBookingBooked()) {
      if (element.price!.length > maxLengthBooke) {
        maxLengthBooke = element.price!.length;
        longestArrayBooke = element.price!;
      }
    }

    if (longestArrayOut.length > longestArrayIn.length &&
        longestArrayOut.length > longestArrayBooke.length) {
      for (var i = 0; i < longestArrayOut.length; i++) {
        price.add(0);
      }
    }

    if (longestArrayIn.length > longestArrayOut.length &&
        longestArrayIn.length > longestArrayBooke.length) {
      for (var i = 0; i < longestArrayIn.length; i++) {
        price.add(0);
      }
    }
    if (longestArrayBooke.length > longestArrayIn.length &&
        longestArrayBooke.length > longestArrayOut.length) {
      for (var i = 0; i < longestArrayBooke.length; i++) {
        price.add(0);
      }
    }
    if (getListBookingOut().isEmpty &&
        getListBookingIn().isNotEmpty &&
        getListBookingBooked().isNotEmpty &&
        longestArrayIn.length == longestArrayBooke.length) {
      for (var i = 0; i < longestArrayBooke.length; i++) {
        price.add(0);
      }
    }

    if (getListBookingOut().isNotEmpty &&
        getListBookingIn().isEmpty &&
        getListBookingBooked().isNotEmpty &&
        longestArrayOut.length == longestArrayBooke.length) {
      for (var i = 0; i < longestArrayOut.length; i++) {
        price.add(0);
      }
    }

    if (getListBookingOut().isNotEmpty &&
        getListBookingIn().isNotEmpty &&
        getListBookingBooked().isEmpty &&
        longestArrayOut.length == longestArrayIn.length) {
      for (var i = 0; i < longestArrayIn.length; i++) {
        price.add(0);
      }
    }
    if (getListBookingOut().isNotEmpty &&
        getListBookingIn().isNotEmpty &&
        getListBookingBooked().isNotEmpty) {
      if (longestArrayBooke.length == longestArrayIn.length &&
          longestArrayBooke.length == longestArrayOut.length) {
        for (var i = 0; i < longestArrayIn.length; i++) {
          price.add(0);
        }
      }
      if (longestArrayBooke.length == longestArrayIn.length &&
          longestArrayBooke.length > longestArrayOut.length) {
        for (var i = 0; i < longestArrayBooke.length; i++) {
          price.add(0);
        }
      }
      if (longestArrayBooke.length == longestArrayOut.length &&
          longestArrayBooke.length > longestArrayIn.length) {
        for (var i = 0; i < longestArrayOut.length; i++) {
          price.add(0);
        }
      }
      if (longestArrayOut.length == longestArrayIn.length &&
          longestArrayOut.length > longestArrayBooke.length) {
        for (var i = 0; i < longestArrayIn.length; i++) {
          price.add(0);
        }
      }
    }

    /// lây tổng tiền tất cả booking in out book
    bool isCheckChangeInOROut = true;
    for (var element in mapRoomIdAndTypeId.keys) {
      if ((inDate != inDateOld || outDate != outDateOld)) {
        if (pricesPerNightUpdate[element] != null) {
          for (var i = 0;
              i < pricesPerNight[mapRoomIdAndTypeId[element]]!.length;
              i++) {
            price[i] +=
                pricesPerNightUpdate[element]![mapRoomIdAndTypeId[element]]![i];
          }
        }
        if (pricesPerNightCheckOut[element] != null) {
          num indexOut =
              pricesPerNightCheckOut[element]![mapRoomIdAndTypeId[element]]!
                  .length;
          for (var i = 0; i < indexOut; i++) {
            price[i] += pricesPerNightCheckOut[element]![
                mapRoomIdAndTypeId[element]]![i];
          }
        }
      } else {
        price.clear();
        isCheckChangeInOROut = false;
      }
    }
    if (isCheckChangeInOROut) {
      for (var bookingBooke in getListBookingBooked()) {
        for (var i = 0;
            i < pricesPerNight[bookingBooke.roomTypeID]!.length;
            i++) {
          price.remove(0);
          pricesPerNightUpdate[bookingBooke.room]![bookingBooke.roomTypeID]!
              .remove(0);
        }
      }
    }
    print("Start: $price");
    if (statusBookingType == BookingType.monthly) {
      for (var key in pricesPerNightUpdate.keys) {
        for (var key2 in pricesPerNightUpdate[key]!.keys) {
          if (pricesPerNight[key2]!.isNotEmpty) {
            pricesPerNightUpdate[key]![key2] = pricesPerNight[key2]!;
          }
        }
      }
      price.clear();
      List<num> tempList = [];
      pricesPerNightUpdate.forEach((key, value) {
        // Lấy danh sách số nguyên từ mỗi cặp key-value
        value.forEach((key, value) {
          tempList = value;
        });
        // Kiểm tra xem kích thước của mảng sumList có đủ lớn không
        // Nếu không, thêm các phần tử 0 vào mảng sumList để có cùng kích thước
        if (price.length < tempList.length) {
          price.addAll(List.filled(tempList.length - price.length, 0));
        }
        // Tính tổng các phần tử tương ứng
        for (int i = 0; i < tempList.length; i++) {
          price[i] += tempList[i];
        }
      });
    }
    print("End: $price");
  }

  Future<bool> checkHaveChangeBooking() async {
    Booking parent = await BookingManager()
        .getBookingGroupByID(getListBookingInAndBooked().first.sID!);
    return inDate == parent.inDate &&
        outDate == parent.outDate &&
        teName!.text == parent.name &&
        teEmail!.text == parent.email &&
        tePhone!.text == parent.phone &&
        teNotes!.text == await parent.getNotesBySid() &&
        teSourceID!.text == parent.sID &&
        teSaler!.text == parent.saler &&
        teCountry == getListBookingInAndBooked().first.country &&
        _typeTourists == getListBookingInAndBooked().first.typeTourists &&
        breakfast == getListBookingInAndBooked().first.breakfast &&
        lunch == getListBookingInAndBooked().first.lunch &&
        dinner == getListBookingInAndBooked().first.dinner &&
        payAtHotel == parent.payAtHotel &&
        sourceID == parent.sourceID &&
        ratePlanID == parent.ratePlanID;
  }

  bool isCheckChangeBooking() {
    Set<num> listStatus = {};
    for (var element in getListBookingInAndBooked()) {
      listStatus.add(element.status!);
    }
    if (listStatus.length > 1) {
      return false;
    }
    return true;
  }

  bool get checkAllBookingBookeIn =>
      (getListBookingIn().isEmpty && getListBookingBooked().isNotEmpty) ||
      (getListBookingIn().isNotEmpty && getListBookingBooked().isNotEmpty);

  bool get checkAllBookingOut =>
      (getListBookingIn().isNotEmpty &&
          getListBookingBooked().isNotEmpty &&
          getListBookingOut().isNotEmpty) ||
      (getListBookingIn().isEmpty &&
          getListBookingBooked().isNotEmpty &&
          getListBookingOut().isNotEmpty) ||
      (getListBookingIn().isNotEmpty &&
          getListBookingBooked().isEmpty &&
          getListBookingOut().isNotEmpty) ||
      (getListBookingIn().isNotEmpty &&
          getListBookingBooked().isNotEmpty &&
          getListBookingOut().isEmpty) ||
      (getListBookingIn().isEmpty &&
          getListBookingBooked().isNotEmpty &&
          getListBookingOut().isEmpty) ||
      (getListBookingIn().isNotEmpty &&
          getListBookingBooked().isEmpty &&
          getListBookingOut().isEmpty);

  List<Booking> getListBookingInAndBooked() => bookings!
      .where((element) =>
          element.status == BookingStatus.booked ||
          element.status == BookingStatus.checkin)
      .toList();

  List<Booking> getListBookingIn() => bookings!
      .where((element) => element.status == BookingStatus.checkin)
      .toList();

  List<Booking> getListBookingBooked() => bookings!
      .where((element) => element.status == BookingStatus.booked)
      .toList();

  List<Booking> getListBookingOut() => bookings!
      .where((element) => element.status == BookingStatus.checkout)
      .toList();

  void setEmailSaler(String value) {
    isCheckEmail = value == emailSalerOld;
    notifyListeners();
  }

  void checkEmailExists() async {
    if (teSaler!.text.isNotEmpty) {
      isLoadingCheckEmail = true;
      notifyListeners();
      await FirebaseFunctions.instance
          .httpsCallable('booking-getUsersInHotel')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'email': teSaler!.text
      }).then((value) {
        isCheckEmail = (value.data as bool);
        isLoadingCheckEmail = false;
        notifyListeners();
      }).onError((error, stackTrace) {
        isLoadingCheckEmail = false;
        isCheckEmail = false;
        notifyListeners();
      });
    }
  }

  void setBookingType(String newValue) {
    if (selectTypeBooking == newValue) return;
    selectTypeBooking = newValue;
    if (selectTypeBooking ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)) {
      statusBookingType = BookingType.dayly;
    } else {
      statusBookingType = BookingType.monthly;
    }
    notifyListeners();
  }

  List<DateTime> updateStayDateByMonth(DateTime inDay, DateTime outDay) {
    List<DateTime>? staysDay = [];
    int startMonth = inDay.month;
    int endMonth = outDay.month;
    int startYear = inDay.year;
    int endYear = outDay.year;
    if (startMonth == endMonth) {
      staysDay = [DateTime(startYear, startMonth)];
    } else {
      if (startYear == endYear) {
        for (var i = startMonth; i <= endMonth; i++) {
          staysDay.add(DateTime(endYear, i));
        }
      } else {
        for (var i = startMonth; i <= 12; i++) {
          staysDay.add(DateTime(startYear, i));
        }
        for (var i = 1; i <= endMonth; i++) {
          staysDay.add(DateTime(endYear, i));
        }
      }
    }
    return staysDay;
  }

  void getDayByMonth(DateTime inDate, DateTime outDate) {
    List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
    List<DateTime> staysDayMonth = updateStayDateByMonth(inDate, outDate);
    int index = 0;
    staysDate!.clear();
    staysMonth.clear();
    if (staysDayMonth.length > 1) {
      DateTime lastDay = outDate;
      for (var i = 1; i < staysDayMonth.length; i++) {
        lastDay = DateTime(
            (inDate.year == outDate.year ? outDate.year : inDate.year),
            inDate.month + i,
            inDate.day - 1,
            12);
        if (data.contains(lastDay)) {
          staysMonth.add(
              "${DateUtil.dateToDayMonthYearString(DateTime(inDate.year, inDate.month + index, inDate.day))}-${DateUtil.dateToDayMonthYearString(lastDay)}");
          index++;
        }
      }
      bool checkOtherYear =
          !(inDate.year != outDate.year && inDate.day == outDate.day);
      DateTime lastOutDate =
          DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
      if ((lastOutDate.isBefore(outDate) || lastOutDate.isAfter(outDate)) &&
          checkOtherYear) {
        DateTime firstDay =
            DateTime(inDate.year, inDate.month + index, inDate.day, 12);
        staysDate = DateUtil.getStaysDay(firstDay, outDate);
        staysMonth.add(
            "${DateUtil.dateToDayMonthYearString(firstDay)}-${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
      }
    } else {
      staysMonth.add(
          "${DateUtil.dateToDayMonthYearString(inDate)}-${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
      staysDate = DateUtil.getStaysDay(inDate, outDate);
    }
  }

  void getPriceAverage(num newTotalPrice, String roomTypeID) {
    int start = staysMonth.length;
    int end = (staysMonth.length + staysDate!.length);
    DateTime outDates = staysDate![staysDate!.length - 1];
    if (staysDate![0].year != staysDate![staysDate!.length - 1].year) {
      outDates = staysDate![0].month != staysDate![staysDate!.length - 1].month
          ? DateTime(staysDate![staysDate!.length - 1].year,
              staysDate![staysDate!.length - 1].month, staysDate![0].day, 12)
          : DateTime(staysDate![staysDate!.length - 1].year,
              staysDate![0].month + 1, staysDate![0].day, 12);
    } else {
      outDates = staysDate![0].month != staysDate![staysDate!.length - 1].month
          ? DateTime(staysDate![0].year,
              staysDate![staysDate!.length - 1].month, staysDate![0].day, 12)
          : DateTime(staysDate![0].year, staysDate![0].month + 1,
              staysDate![0].day, 12);
    }
    num priceMedium =
        (newTotalPrice / outDates.difference(staysDate![0]).inDays).round();
    for (var i = start; i < end; i++) {
      pricesPerNight[roomTypeID]![i] = priceMedium;
    }
    // print(pricesPerNight);
  }
}
