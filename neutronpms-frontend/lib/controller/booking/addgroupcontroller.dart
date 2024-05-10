import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/rateplanmanager.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/roomtypemanager.dart';
import '../../manager/sourcemanager.dart';
import '../../manager/usermanager.dart';
import '../../modal/status.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/countryulti.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class AddGroupController extends ChangeNotifier {
  TextEditingController? teName,
      teSourceID,
      teEmail,
      tePhone,
      teNotes,
      teSaler,
      teExternalSaler;
  late DateTime outDate, inDate;
  Map<String, NeutronInputNumberController> teNums = {};
  Map<String, dynamic> priceTotalAndQuantityRoomTotal = {};
  Map<String, List<num>> pricesPerNight = {};
  bool breakfast = false;
  bool dinner = false;
  bool lunch = false;
  bool payAtHotel = true;
  List<DateTime>? staysDate = [];
  Set<String> staysMonth = {};
  Map<String, List<String>?> availableRooms = {};
  Map<String, List<String>> roomPicks = {};
  List<String> listCountry = CountryUtil.getCountries();
  late String sourceID, _typeTourists, ratePlanID, teCountry;
  bool isLoading = false;
  bool isCheckEmail = false, isLoadingCheckEmail = false;
  String emailSalerOld = '';
  late String selectTypeBooking;
  late int statusBookingType;

  List<String> get listTypeTourists => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNKNOWN),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN)
      ];

  List<String> get listTypeBooking => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY),
        // UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY),
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

  AddGroupController() {
    isLoading = true;
    notifyListeners();
    inDate = DateUtil.to12h(Timestamp.now().toDate());
    outDate = inDate.add(const Duration(days: 1));
    teName = TextEditingController();
    teEmail = TextEditingController();
    tePhone = TextEditingController();
    teNotes = TextEditingController(text: "");
    teSaler = TextEditingController(text: "");
    teExternalSaler = TextEditingController(text: "");
    emailSalerOld = teSaler!.text;
    teCountry = '';
    _typeTourists = TypeTourists.unknown;
    teSourceID = TextEditingController(text: "");
    sourceID = SourceManager.directSource;
    ratePlanID = RatePlanManager().getRatePLanDefault().title!;
    for (var roomTypeID in RoomTypeManager().getRoomTypeIDsActived()) {
      teNums[roomTypeID!] =
          NeutronInputNumberController(TextEditingController(text: "0"));
      priceTotalAndQuantityRoomTotal[roomTypeID] = {};
      priceTotalAndQuantityRoomTotal[roomTypeID]['num'] = 0;
      priceTotalAndQuantityRoomTotal[roomTypeID]['price'] = 0;
    }
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler!.text) {
      isCheckEmail = true;
    }
    statusBookingType = BookingType.dayly;
    if (statusBookingType == BookingType.monthly) {
      getDayByMonth();
    } else {
      staysDate = DateUtil.getStaysDay(inDate, outDate);
    }
    selectTypeBooking =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY);
    updateAvailableRooms().then((_) {
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> setInDate(DateTime date) async {
    final newInDate = DateUtil.to12h(date);
    if (newInDate.compareTo(inDate) == 0) return;
    isLoading = true;
    notifyListeners();
    inDate = newInDate;
    if (outDate.difference(inDate).inDays <= 0) {
      outDate = inDate.add(const Duration(days: 1));
    }
    if (statusBookingType == BookingType.monthly) {
      getDayByMonth();
    } else {
      staysDate = DateUtil.getStaysDay(inDate, outDate);
    }
    await updatePriceWithRatePlanIdOrInDateOrOutDate();
    await updateAvailableRooms();
    isLoading = false;
    notifyListeners();
  }

  Future<void> setOutDate(DateTime date) async {
    final newOutDate = DateUtil.to12h(date);
    if (newOutDate.compareTo(outDate) == 0) return;
    if (newOutDate.isBefore(inDate)) return;
    isLoading = true;
    notifyListeners();
    outDate = newOutDate;
    if (statusBookingType == BookingType.monthly) {
      getDayByMonth();
    } else {
      staysDate = DateUtil.getStaysDay(inDate, outDate);
    }
    await updatePriceWithRatePlanIdOrInDateOrOutDate();
    await updateAvailableRooms();
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
      for (int i = 0;
          i <
              (pricesPerNight[roomTypeID]!.length < staysMonth.length
                  ? pricesPerNight[roomTypeID]!.length
                  : staysMonth.length);
          i++) {
        total += (pricesPerNight[roomTypeID]?[i] ?? 0);
      }
      return total;
    }
    return pricesPerNight[roomTypeID]!
        .fold(0, (previousValue, element) => previousValue + element);
  }

  Future<void> updatePriceWithRatePlanIdOrInDateOrOutDate() async {
    for (var roomTypeID in RoomTypeManager().getRoomTypeIDsActived()) {
      await updatePricePerNight(roomTypeID!,
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
      Map<String, dynamic> data = await DailyAllotmentStatic()
          .getPriceAndBookedRooms(inDate, outDate, roomTypeID);
      if (statusBookingType == BookingType.monthly) {
        pricesPerNight[roomTypeID]!.clear();
        for (var i = 0; i < (staysMonth.length + staysDate!.length); i++) {
          pricesPerNight[roomTypeID]!.add(0);
        }
      } else {
        pricesPerNight[roomTypeID] =
            RatePlanManager().getPriceWithRatePlanID(ratePlanID, data['price']);
      }
      num totalPriceOfRoomType = pricesPerNight[roomTypeID]!.fold(
          0,
          (previousValue, element) =>
              previousValue + element * num.parse(value));
      priceTotalAndQuantityRoomTotal[roomTypeID] = {};
      priceTotalAndQuantityRoomTotal[roomTypeID]['price'] =
          totalPriceOfRoomType;
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

  Future<void> updateAvailableRooms() async {
    availableRooms.clear();
    for (var roomTypeID in RoomTypeManager().getRoomTypeIDsActived()) {
      availableRooms[roomTypeID!] = [];
      availableRooms[roomTypeID] = await DailyAllotmentStatic()
          .getAvailableRoomsWithStaysDayAndRoomTypeiD(
              inDate, outDate, roomTypeID);
    }
  }

  String validateRoomToSecondPage() {
    final lengthStay = outDate.difference(inDate).inDays;
    if (lengthStay > GeneralManager.maxLengthStay &&
        statusBookingType == BookingType.dayly) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_MAX_LENGTHDAY_31);
    }
    if (lengthStay > 365 && statusBookingType == BookingType.monthly) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_MAX_LENGTHDAY_365);
    }
    if (outDate.compareTo(inDate) <= 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OUTDATE_MUST_LARGER_THAN_INDATE);
    }
    final now = Timestamp.now();
    final now12h = DateUtil.to12h(now.toDate());
    final yesterday = now12h.subtract(const Duration(days: 1));
    if (inDate.compareTo(yesterday) < 0 ||
        (inDate.compareTo(yesterday) == 0 &&
            now.toDate().compareTo(now12h) >= 0)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INDATE_MUST_NOT_IN_PAST);
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
      roomPicks[element.key] = element.value!
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

  Future<String> addGroup() async {
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
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('booking-addBookingGroup');
      final result = await callable({
        'map_room_types': roomPicks,
        'hotel_id': GeneralManager.hotelID,
        'price_per_night': pricesPerNight,
        'in_date': inDate.toString(),
        'out_date': outDate.toString(),
        'pay_at_hotel': payAtHotel,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'source_id': sourceID,
        'sID': teSourceID!.text.trim(),
        'name': teName!.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        'email': teEmail!.text,
        'phone': tePhone!.text,
        'rate_plan_id': ratePlanID,
        'type_tourists': _typeTourists,
        'country': teCountry,
        'notes': teNotes!.text,
        'partner': UserManager.isPartnerAddBookingShowBooking(),
        'saler': teSaler!.text,
        'external_saler': teExternalSaler!.text,
        'booking_type': statusBookingType,
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        isLoading = false;
        notifyListeners();
        return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
      }
    } on FirebaseFunctionsException catch (error) {
      print(error);
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(error.message);
    }
    isLoading = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  }

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
      updatePriceBookingType();
    } else {
      statusBookingType = BookingType.monthly;
      updatePriceBookingType();
    }
    notifyListeners();
  }

  updatePriceBookingType() {
    staysDate!.clear();
    if (statusBookingType == BookingType.monthly) {
      getDayByMonth();
    } else {
      staysDate = DateUtil.getStaysDay(inDate, outDate);
    }
    for (var roomTypeID in RoomTypeManager().getRoomTypeIDsActived()) {
      pricesPerNight[roomTypeID!] = [];
      for (var i = 1; i < (staysMonth.length + staysDate!.length); i++) {
        pricesPerNight[roomTypeID]!.add(0);
      }
      updatePricePerNight(roomTypeID, "");
      teNums[roomTypeID] =
          NeutronInputNumberController(TextEditingController(text: "0"));
    }
  }

  List<DateTime> updateStayDateByMonth() {
    List<DateTime>? staysDay = [];
    int startMonth = inDate.month;
    int endMonth = outDate.month;
    int startYear = inDate.year;
    int endYear = outDate.year;
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

  void getDayByMonth() {
    List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
    List<DateTime> staysDayMonth = updateStayDateByMonth();
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
}
