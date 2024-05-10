import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/rateplanmanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/staydeclaration/countrydeclaration.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import '../../manager/roommanager.dart';
import '../../manager/roomtypemanager.dart';
import '../../manager/sourcemanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../modal/staydeclaration/staydeclaration.dart';
import '../../util/countryulti.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class BookingController extends ChangeNotifier {
  late final Booking booking;
  late String roomTypeID, bed, sourceID, _typeTourists, teCountry, sidOld;
  late bool breakfast, dinner, lunch, payAtHotel;
  List<String> rooms = [];
  late DateTime inDate, outDate;
  DateTime? outDateHour, inDateHour;
  late TimeOfDay hourFrameStart, hourFrameEnd;
  //inDate and out before changing
  late DateTime oldInDate, oldOutDate;
  TextEditingController? teName,
      teEmail,
      tePhone,
      teNotes,
      teSaler,
      teExternalSaler;
  // price = priceRaw * rate plan
  List<num> priceAfterMultipleRatePlan = [];
  List<String> listCountry = CountryUtil.getCountries();

  // priceRaw use to save price, flow staysday when change in day out day or roomtype
  List<num> priceRaw = [];
  Set<String> staysMonth = {};
  List<DateTime> staysDay = [], oldStaysDay = [];
  NeutronInputNumberController? teAdult, teChild;
  late TextEditingController teSID;
  late NeutronInputNumberController teTotalPrice;
  late String room;
  late String selectTypeBooking;
  late int statusBookingType;
  List<String> availableRooms = [], bedsOfRoomType = [];
  late bool isAddBooking,
      updating = false,
      isGroup,
      isNotHaveRoomTypeAndRoom = false,
      isDeclareForTax,
      isCheckEmail = false,
      isLoading = false;
  late int status;
  late String idBooking, ratePlanID;
  String emailSalerOld = '';
  late DateTime breakDate;
  //invoice detail for tax declaration
  Map<String, dynamic> declarationInvoiceDetail = {};
  //list guest for tax declaration
  List<StayDeclaration> declarationGuest = [];

  BookingController(this.booking, {bool addBookingGroup = false}) {
    init(addBookingGroup);
  }

  List<String> get listTypeTourists => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNKNOWN),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN)
      ];

  List<String> get listTypeBooking => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOURLY),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY),
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

  void setCountry(String value) {
    if (value == teCountry) return;
    teCountry = value;
    notifyListeners();
  }

  void init(bool addBookingGroup) async {
    if (RoomTypeManager().activedRoomTypes.isEmpty ||
        RoomManager().rooms!.isEmpty) {
      updating = false;
      isNotHaveRoomTypeAndRoom = true;
      return;
    }
    isGroup = booking.group!;
    updating = true;
    isAddBooking = booking.isEmpty!;
    final now = Timestamp.now().toDate();
    idBooking = booking.id ?? '';
    ratePlanID = RatePlanManager().getRatePLanDefault().title ?? '';
    teName = TextEditingController(text: booking.name ?? '');
    teCountry = booking.country ?? '';
    _typeTourists = booking.typeTourists ?? TypeTourists.unknown;
    teEmail = TextEditingController(text: booking.email ?? '');
    tePhone = TextEditingController(text: booking.phone ?? '');
    teNotes = TextEditingController(text: await booking.getNotes() ?? "");
    teSaler = TextEditingController(text: booking.saler ?? "");
    teExternalSaler = TextEditingController(text: booking.externalSaler ?? "");
    emailSalerOld = teSaler!.text;
    teSID = TextEditingController(text: booking.sID ?? "");
    sidOld = booking.sID ?? "";
    inDate = DateUtil.to12h(booking.inDate ?? now);
    outDate =
        DateUtil.to12h(booking.outDate ?? inDate.add(const Duration(days: 1)));
    oldInDate = inDate;
    oldOutDate = outDate;
    roomTypeID =
        booking.roomTypeID ?? RoomTypeManager().getFirstRoomType()?.id ?? '';
    final roomType = RoomTypeManager().getRoomTypeByID(roomTypeID);
    bed = booking.bed ?? roomType.getFirstBed();
    teAdult = NeutronInputNumberController(TextEditingController(
        text: (booking.adult ?? roomType.guest).toString()));
    teChild = NeutronInputNumberController(
        TextEditingController(text: (booking.child ?? 0).toString()));
    breakfast = booking.breakfast ?? false;
    lunch = booking.lunch ?? false;
    dinner = booking.dinner ?? false;
    payAtHotel = booking.payAtHotel ?? true;
    sourceID = booking.sourceID ?? SourceManager.directSource;
    room = booking.room ?? '';
    declarationInvoiceDetail['address'] =
        TextEditingController(text: booking.declareInfo!['address'] ?? '');
    declarationInvoiceDetail['email'] =
        TextEditingController(text: booking.declareInfo!['email'] ?? '');
    declarationInvoiceDetail['guest'] =
        TextEditingController(text: booking.declareInfo!['guest'] ?? '');
    declarationInvoiceDetail['phone'] =
        TextEditingController(text: booking.declareInfo!['phone'] ?? '');
    declarationInvoiceDetail['price'] = NeutronInputNumberController(
        TextEditingController(
            text: booking.declareInfo!['price']?.toString() ?? ''));
    declarationInvoiceDetail['tax_code'] =
        TextEditingController(text: booking.declareInfo!['tax_code'] ?? '');
    selectTypeBooking =
        booking.bookingType == null || booking.bookingType == BookingType.dayly
            ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)
            : booking.bookingType == BookingType.hourly
                ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOURLY)
                : UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTHLY);
    statusBookingType = booking.bookingType ?? BookingType.dayly;
    hourFrameStart = TimeOfDay(
        hour: booking.inTime?.hour ?? 0, minute: booking.inTime?.minute ?? 0);
    hourFrameEnd = TimeOfDay(
        hour: booking.outTime?.hour ?? 23,
        minute: booking.outTime?.minute ?? 0);
    if (booking.declareGuests!.isNotEmpty) {
      // ignore: avoid_function_literals_in_foreach_calls
      booking.declareGuests!.forEach((json) {
        declarationGuest.add(StayDeclaration.fromJson(json));
      });
    }
    isDeclareForTax = booking.isTaxDeclare ?? false;
    if (idBooking.isNotEmpty) {
      ratePlanID = booking.ratePlanID!;
      oldStaysDay = booking.bookingType == BookingType.monthly
          ? getDailyByBookingTypeMonth()
          : DateUtil.getStaysDay(oldInDate, oldOutDate);
      priceAfterMultipleRatePlan = booking.price!;
      if (booking.status == BookingStatus.checkin) {
        breakDate = DateUtil.to12h(now);
      }
    }

    await updatePriceAndAvailableRoomsNew(
        inDate, outDate, roomTypeID, ratePlanID, true);
    if (booking.bookingType == BookingType.monthly) {
      getDayByMonth();
    } else {
      staysDay = DateUtil.getStaysDay(inDate, outDate);
    }
    getBeds();
    teTotalPrice = NeutronInputNumberController(TextEditingController(
        text: booking.bookingType == BookingType.monthly
            ? addBookingGroup
                ? ""
                : ((getTotalPriceByBookingMonth(priceAfterMultipleRatePlan)
                            .fold(
                                0.0,
                                (previousValue, element) =>
                                    previousValue + element) /
                        getTotalPriceByBookingMonth(priceAfterMultipleRatePlan)
                            .length))
                    .round()
                    .toString()
            : getTotalPrice().toString()));

    if (addBookingGroup && booking.bookingType == BookingType.monthly) {
      priceAfterMultipleRatePlan.clear();
      for (var i = 1; i <= (staysDay.length + staysMonth.length); i++) {
        priceAfterMultipleRatePlan.add(0);
      }
    }
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler!.text) {
      isCheckEmail = true;
    }
    if (statusBookingType == BookingType.hourly) {
      inDateHour = booking.inTime ?? now;
      outDateHour = booking.outTime ?? now;
    }
  }

  void updateRoom() {
    if (roomTypeID == booking.roomTypeID) {
      room = booking.room ??
          RoomManager().getIdRoomByName(availableRooms.isNotEmpty
              ? availableRooms.first
              : RoomManager().nameNoneRoom!);
    } else {
      room = availableRooms.isNotEmpty
          ? RoomManager().getIdRoomByName(availableRooms.first)
          : RoomManager().idNoneRoom!;
    }
    if (!availableRooms.contains(RoomManager().getNameRoomById(room))) {
      availableRooms.add(RoomManager().getNameRoomById(room));
    }
  }

  List<String> getAvailableRooms(List<String> roomBooked) {
    if (booking.isRoomEditable()) {
      final List<String> rooms = RoomManager().getRoomIDsByType(roomTypeID);
      rooms.removeWhere((element) => roomBooked.contains(element));
      if (booking.status == BookingStatus.booked) {
        rooms.add(RoomManager().idNoneRoom!);
      }
      return rooms.map((room) => RoomManager().getNameRoomById(room)).toList();
    } else {
      return [RoomManager().getNameRoomById(room)];
    }
  }

  void disposeTextEditing() {
    teName?.dispose();
    teEmail?.dispose();
    tePhone?.dispose();
    teNotes?.dispose();
    teSaler?.dispose();
    teAdult?.controller.dispose();
    teSID.dispose();
    teChild?.controller.dispose();
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

  Future<void> updatePriceAndAvailableRoomsNew(
      DateTime inDayParam,
      DateTime outDayParam,
      String roomTypeIdParam,
      String ratePlanTitle,
      bool isUpdateFirstTime) async {
    final Map<String, dynamic> data = await DailyAllotmentStatic()
        .getPriceAndBookedRooms(inDayParam, outDayParam, roomTypeIdParam);
    priceRaw = data['price'];
    final List<String> roomBooked = data['booked'];
    availableRooms = getAvailableRooms(roomBooked);
    updateRoom();
    if (!isUpdateFirstTime || idBooking.isEmpty) {
      updatePriceWithRatePlan(ratePlanTitle, priceRaw);
    } else {
      updating = false;
      notifyListeners();
    }
  }

  void updatePriceWithRatePlan(String titleRatePlan, List<num> priceRawParam) {
    List<num> priceByRatePlan =
        RatePlanManager().getPriceWithRatePlanID(titleRatePlan, priceRawParam);
    priceAfterMultipleRatePlan = priceByRatePlan;
    updating = false;
    notifyListeners();
  }

  num getTotalPrice() {
    return priceAfterMultipleRatePlan.fold(
        0, (previousValue, element) => previousValue + element);
  }

  void setPrice(List<num> newPrice) {
    num newTotal = statusBookingType == BookingType.monthly
        ? getTotalPriceByBookingMonth(newPrice)
            .fold(0, (previousValue, element) => previousValue + element)
        : newPrice.fold(0, (previousValue, element) => previousValue + element);
    if (newTotal != getTotalPrice() ||
        statusBookingType == BookingType.monthly) {
      priceAfterMultipleRatePlan = newPrice;
      teTotalPrice.controller.text = statusBookingType == BookingType.monthly
          ? (newTotal / getTotalPriceByBookingMonth(newPrice).length)
              .round()
              .toString()
          : newTotal.toString();
      teTotalPrice.formatString();
    }
    notifyListeners();
  }

  List<num> getTotalPriceByBookingMonth(List<num> newPrice) {
    List<num> totalPrice = [];
    for (var i = 0; i < staysMonth.length; i++) {
      totalPrice.add(newPrice[i]);
    }
    return totalPrice;
  }

  List<num> getTotalPriceByBookingByDayly(List<num> newPrice) {
    List<num> totalPrice = [];
    if (staysMonth.length <= 1) {
      for (var i = staysDay.isEmpty ? 0 : staysMonth.length;
          i < (staysMonth.length + staysDay.length);
          i++) {
        totalPrice.add(newPrice[i]);
      }
    } else {
      for (var i = 0;
          i < (staysMonth.length - (staysDay.isEmpty ? 0 : 1));
          i++) {
        totalPrice.add(newPrice[i]);
      }
      if (staysDay.isNotEmpty) {
        for (var i = staysMonth.length;
            i < (staysMonth.length + staysDay.length);
            i++) {
          totalPrice.add(newPrice[i]);
        }
      }
    }

    return totalPrice;
  }

  void setPayAtHotel(bool payAtHotel) {
    if (payAtHotel != this.payAtHotel) {
      this.payAtHotel = payAtHotel;
      notifyListeners();
    }
  }

  void setRoom(String nameRoom) {
    if (nameRoom == RoomManager().nameNoneRoom &&
        booking.status != BookingStatus.booked) return;
    if (room != nameRoom) {
      room = RoomManager().getIdRoomByName(nameRoom);
      notifyListeners();
    }
  }

  void setBed(String bed) {
    if (bed != this.bed) {
      this.bed = SystemManagement().getBedIdByName(bed);
      notifyListeners();
    }
  }

  void getBeds() {
    if (!booking.isBedEditable()) {
      bedsOfRoomType = [bed];
    }
    final beds = RoomTypeManager()
            .getAllRoomTypeByID(roomTypeID)
            .beds
            ?.map((bed) => SystemManagement().getBedNameById(bed))
            .toList() ??
        [];
    bedsOfRoomType = beds;
  }

  void setRatePlan(String newRatePlan) async {
    if (ratePlanID != newRatePlan) {
      ratePlanID = newRatePlan;
      updatePriceWithRatePlan(ratePlanID, priceRaw);
      teTotalPrice.controller.text = getTotalPrice().toString();
      teTotalPrice.formatString();
    }
  }

  List<String> getRatePlans() {
    if (booking.isEditRatePlan()) {
      final List<String> result = [];
      for (var item in RatePlanManager().ratePlans.where((element) =>
          !element.isDelete! &&
          element.title != RatePlanManager().otaRatePlan)) {
        result.add(item.title!);
      }
      if (!result.contains(ratePlanID)) {
        result.add(ratePlanID);
      }
      return result;
    }
    return [ratePlanID];
  }

  void setSourceID(String sourceID) {
    if (sourceID != this.sourceID) {
      if (!SourceManager().isSourceOTA(sourceID) && !payAtHotel) {
        return;
      }
      this.sourceID = sourceID;
      notifyListeners();
    }
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

  DateTime getLastInDate() {
    return inDate.add(Duration(days: GeneralManager.maxLengthStayOta));
  }

  DateTime getLastDate() {
    return inDate.add(Duration(
        days: statusBookingType == BookingType.hourly
            ? 1
            : GeneralManager.maxLengthStayOta));
  }

// Update price and room here
  void setInDate(DateTime inDate, TimeOfDay? newStart) async {
    if (statusBookingType == BookingType.hourly && newStart != null) {
      inDateHour = DateTime(inDate.year, inDate.month, inDate.day,
          newStart.hour, newStart.minute);
      if (inDateHour!.isAfter(outDateHour!) ||
          TimeOfDayUtil.compare(newStart, hourFrameEnd) == 0) {
        outDateHour = DateTime(inDate.year, inDate.month, inDate.day,
            newStart.hour + 1, newStart.minute);
      }
      notifyListeners();
    }
    if (DateUtil.equal(inDate, this.inDate)) {
      return;
    }
    updating = true;
    notifyListeners();
    this.inDate = DateUtil.to12h(inDate);
    if (outDate.compareTo(this.inDate) <= 0) {
      outDate = this.inDate.add(const Duration(days: 1));
    }
    updatePriceByBookingType();
  }

// Update price and room here one time
  void setOutDate(DateTime outDate, TimeOfDay? newEnd) async {
    if (statusBookingType == BookingType.hourly && newEnd != null) {
      outDateHour = DateTime(
          outDate.year, outDate.month, outDate.day, newEnd.hour, newEnd.minute);
      if (outDateHour!.isBefore(inDateHour!)) {
        inDateHour = DateTime(outDate.year, outDate.month, outDate.day,
            newEnd.hour - 1, newEnd.minute);
        inDate = DateUtil.to12h(outDate);
        this.outDate = DateUtil.to12h(outDate.add(const Duration(days: 1)));
      }
      notifyListeners();
    }
    if (DateUtil.equal(outDate, this.outDate)) {
      return;
    }
    if (!outDate.isAfter(inDate)) {
      return;
    }
    updating = true;
    notifyListeners();
    final outDate12h = DateUtil.to12h(outDate);
    if (outDate12h.compareTo(inDate) <= 0) {
      updating = false;
      notifyListeners();
      return;
    }
    this.outDate = outDate12h;
    updatePriceByBookingType();
  }

  void setRoomTypeID(String roomTypeName) async {
    final roomTypeIDNew = RoomTypeManager().getRoomTypeIDByName(roomTypeName);
    if (roomTypeIDNew == roomTypeID) {
      return;
    }
    updating = true;
    notifyListeners();
    roomTypeID = roomTypeIDNew;
    final roomType = RoomTypeManager().getRoomTypeByID(roomTypeID);
    bed = roomType.getFirstBed();
    getBeds();
    teAdult!.controller.text = roomType.guest.toString();
    // case add
    if (idBooking.isEmpty) {
      await updatePriceAndAvailableRoomsNew(
          inDate, outDate, roomTypeIDNew, ratePlanID, false);
      if (statusBookingType == BookingType.monthly) {
        updatePriceByBookingType();
        teTotalPrice =
            NeutronInputNumberController(TextEditingController(text: ""));
      }
    } else {
      // case update with both status booked or checkin

      Map<String, dynamic> data = {};
      if (booking.status == BookingStatus.checkin) {
        data = await DailyAllotmentStatic()
            .getPriceAndBookedRooms(breakDate, outDate, roomTypeIDNew);
      } else {
        data = await DailyAllotmentStatic()
            .getPriceAndBookedRooms(inDate, outDate, roomTypeIDNew);
      }
      final List<String> roomBooked = data['booked'];
      availableRooms = getAvailableRooms(roomBooked);
      updateRoom();
    }
    teTotalPrice.controller.text = getTotalPrice().toString();
    teTotalPrice.formatString();
    updating = false;
    notifyListeners();
  }

  void setTaxDeclare(bool newValue) {
    if (newValue == isDeclareForTax) {
      return;
    }
    isDeclareForTax = newValue;
    notifyListeners();
  }

  Future<String> updateBooking() async {
    if (teSaler!.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    if (statusBookingType == BookingType.hourly &&
        inDateHour != null &&
        outDateHour != null &&
        outDateHour!.difference(inDateHour!).inDays > 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.CREATE_OVERHOUR_BOOKING);
    }
    if ((statusBookingType == BookingType.monthly ||
            statusBookingType == BookingType.hourly) &&
        teTotalPrice.controller.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_PRICE);
    }
    print(priceAfterMultipleRatePlan);
    if (isAddBooking) {
      final adult = int.tryParse(teAdult!.getRawString());
      final child = int.tryParse(teChild!.getRawString());
      String? tesid = teSID.text;
      final name = teName!.text;
      final email = teEmail!.text;
      if (name.isEmpty) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
      }
      String? validateSid = StringValidator.validateSid(tesid);
      if (validateSid != null && tesid.isNotEmpty) {
        return validateSid;
      }

      if (adult == null) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.ADULT_MUST_BE_NUMBER);
      }
      if (child == null) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.CHILD_MUST_BE_NUMBER);
      }
      if (StringValidator.validateNonRequiredEmail(email) != null) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_EMAIL);
      }

      Map<String, dynamic> mapInvoiceDetail = {};
      String? getInvoiceDetailResult =
          getValueOfInvoiceDetailForm(mapInvoiceDetail);
      if (getInvoiceDetailResult != null) {
        return MessageUtil.getMessageByCode(getInvoiceDetailResult);
      }
      print("$inDateHour ---- $inDate");
      print("$outDateHour ---- $outDate");
      List<dynamic> listGuest = declarationGuest.map((e) => e.toMap()).toList();
      updating = true;
      notifyListeners();
      // export backup here
      final result = await Booking(
              group: isGroup,
              price: priceAfterMultipleRatePlan,
              ratePlanID: ratePlanID,
              name: teName!.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
              email: teEmail!.text,
              phone: tePhone!.text,
              room: room,
              inDate: inDate,
              inTime: inDateHour ?? inDate,
              outDate: outDate,
              outTime: outDateHour ?? outDate,
              roomTypeID: roomTypeID,
              bed: bed,
              payAtHotel: payAtHotel,
              breakfast: breakfast,
              lunch: lunch,
              dinner: dinner,
              adult: adult,
              child: child,
              sourceID: sourceID,
              sID: teSID.text.trim(),
              status: UserManager.isPartnerAddBookingShowBooking()
                  ? BookingStatus.unconfirmed
                  : BookingStatus.booked,
              isTaxDeclare: isDeclareForTax,
              declareGuests: listGuest,
              declareInfo: mapInvoiceDetail,
              typeTourists: _typeTourists,
              country: teCountry,
              bookingType: statusBookingType,
              notes: teNotes!.text,
              saler: teSaler!.text,
              externalSaler: teExternalSaler!.text)
          .add();
      updating = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    } else {
      final adult = int.tryParse(teAdult!.getRawString());
      final child = int.tryParse(teChild!.getRawString());
      final tesid = teSID.text;
      final name = teName!.text;
      if (name.isEmpty) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
      }
      String? validateSid = StringValidator.validateSid(tesid);
      if (validateSid != null && tesid.isNotEmpty) {
        return validateSid;
      }
      if (adult == null) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.ADULT_MUST_BE_NUMBER);
      }
      if (child == null) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.CHILD_MUST_BE_NUMBER);
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
          teCountry != GeneralManager.hotel!.country) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.PLEASE_CHOOSE_RIGHT_COUNTRY);
      }

      if (sourceID != "di" && tesid != sidOld) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
      }

      Map<String, dynamic> mapInvoiceDetail = {};
      String? getInvoiceDetailResult =
          getValueOfInvoiceDetailForm(mapInvoiceDetail);
      if (getInvoiceDetailResult != null) {
        return MessageUtil.getMessageByCode(getInvoiceDetailResult);
      }
      List<dynamic> listGuest = declarationGuest.map((e) => e.toMap()).toList();

      updating = true;
      notifyListeners();
      String result = await booking.update(
        ratePlanID: ratePlanID,
        name: teName!.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        phone: tePhone!.text,
        email: teEmail!.text,
        room: room,
        inDateParam: inDate,
        outDateParam: outDate,
        inTimeParam: inDateHour ?? inDate,
        outTimeParam: outDateHour ?? outDate,
        roomTypeID: roomTypeID,
        priceParam: priceAfterMultipleRatePlan,
        breakfast: breakfast,
        dinner: dinner,
        lunch: lunch,
        bed: bed,
        payAtHotel: payAtHotel,
        adult: adult,
        child: child,
        sourceID: sourceID,
        sID: teSID.text.trim(),
        isTaxDeclare: isDeclareForTax,
        declarationInvoiceDetail: mapInvoiceDetail,
        listGuestDeclaration: listGuest,
        typeTouristsParam: _typeTourists,
        countryParam: teCountry,
        notes: teNotes!.text,
        saler: teSaler!.text,
        externalSaler: teExternalSaler!.text,
        bookingType: statusBookingType,
      );
      updating = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    }
  }

  List<String> getSourceNames() {
    String currentSource = SourceManager().getSourceNameByID(sourceID);
    if (booking.isSourceEditable()) {
      final List<String> sourceManager = SourceManager().getActiveSourceNames();
      if (!sourceManager.contains(currentSource)) {
        sourceManager.add(currentSource);
      }
      sourceManager.removeWhere((element) => element == 'virtual');
      return sourceManager;
    } else {
      return [currentSource];
    }
  }

  List<String?> getRoomTypeNames() => booking.isRoomTypeEditable()
      ? RoomTypeManager().getRoomTypeNamesActived()
      : [RoomTypeManager().getRoomTypeNameByID(roomTypeID)];

  void addGuestDeclaration(StayDeclaration guestDeclaration) {
    declarationGuest.add(guestDeclaration);
    isDeclareForTax = true;
    notifyListeners();
  }

  void removeGuestDeclaration(StayDeclaration object) {
    declarationGuest.remove(object);
    notifyListeners();
  }

  void updateGuestDeclaration(
      StayDeclaration oldGuest, StayDeclaration newGuest) {
    int index = declarationGuest.indexOf(oldGuest);
    declarationGuest.replaceRange(index, index + 1, [newGuest]);
    notifyListeners();
  }

  String? getValueOfInvoiceDetailForm(Map<String, dynamic> referenceMap) {
    String address =
        (declarationInvoiceDetail['address'] as TextEditingController)
            .text
            .trim();
    String email = (declarationInvoiceDetail['email'] as TextEditingController)
        .text
        .trim();
    String guest = (declarationInvoiceDetail['guest'] as TextEditingController)
        .text
        .trim();
    String taxCode =
        (declarationInvoiceDetail['tax_code'] as TextEditingController)
            .text
            .trim();

    if (address.isNotEmpty ||
        email.isNotEmpty ||
        guest.isNotEmpty ||
        taxCode.isNotEmpty) {
      if (guest.isEmpty) {
        return MessageCodeUtil.INPUT_INVOICE_NAME;
      } else if (guest.length > 256) {
        return MessageCodeUtil.OVER_NAME_INVOICE_MAX_LENGTH;
      }

      if (taxCode.isEmpty) {
        return MessageCodeUtil.INPUT_TAX_CODE;
      } else if (taxCode.length > 64) {
        return MessageCodeUtil.OVER_TAX_CODE_INVOICE_MAX_LENGTH;
      }

      if (email.isEmpty) {
        return MessageCodeUtil.INPUT_INVOICE_EMAIL;
      } else if (!StringValidator.emailRegex.hasMatch(email)) {
        return MessageCodeUtil.INVALID_EMAIL;
      }

      if (address.isEmpty) {
        return MessageCodeUtil.INPUT_INVOICE_ADDRESS;
      } else if (address.length > 256) {
        return MessageCodeUtil.OVER_ADDRESS_INVOICE_MAX_LENGTH;
      }
    }

    String priceString =
        (declarationInvoiceDetail['price'] as NeutronInputNumberController)
            .controller
            .text
            .replaceAll(',', '')
            .trim();

    if (priceString.split('.').length > 2) {
      return MessageCodeUtil.INVALID_PRICE;
    }

    referenceMap['address'] = address;
    referenceMap['email'] = email;
    referenceMap['guest'] = guest;
    referenceMap['tax_code'] = taxCode;
    referenceMap['phone'] =
        (declarationInvoiceDetail['phone'] as TextEditingController)
            .text
            .trim();
    referenceMap['price'] =
        num.tryParse(priceString.isEmpty ? '0' : priceString);

    return null;
  }

  void onChangeOfDeclareInfoFields(String value) {
    if (value.isNotEmpty && !isDeclareForTax) {
      isDeclareForTax = true;
      notifyListeners();
    }
  }

  bool addGuestDeclarationFromQRCode(String qrCode) {
    if (qrCode.isEmpty) {
      return false;
    }
    try {
      //048199000182|201772212|Hoàng Hạ Quỳnh|04071999|Nữ|Tổ 85, An Hải Bắc, Sơn Trà, Đà Nẵng|22042021
      //"CCCD|CMND|Name|date of birth ddmmyy|Gender: Nam/Nữ|detail address, commune, district, city|22042021"
      List<String> guestInfos = qrCode.split("|");
      List<String> addressInfos = guestInfos[5].split(',');
      String cityAddress = CountryDeclaration.vietnameseCountries.keys
          .firstWhere((element) =>
              element.contains(addressInfos[addressInfos.length - 1]));
      String districtAddress = CountryDeclaration
          .vietnameseCountries[cityAddress]!.keys
          .firstWhere((element) =>
              element.contains(addressInfos[addressInfos.length - 2]));
      String communeAddress = CountryDeclaration
          .vietnameseCountries[cityAddress]![districtAddress]!
          .firstWhere((element) =>
              element.contains(addressInfos[addressInfos.length - 3]));
      String detailAddress = guestInfos[5].substring(
          0, guestInfos[5].indexOf(addressInfos[addressInfos.length - 3]) - 1);

      declarationGuest.add(StayDeclaration(
        accuracyOfDob: "D - Date",
        bookingId: idBooking,
        nationalId: guestInfos[0],
        passport: "",
        otherDocId: "",
        name: guestInfos[2],
        dateOfBirth: DateUtil.shortStringDDMMYYYToDate12h(guestInfos[3]),
        gender: guestInfos[4] == "Nữ" ? "Giới tính nữ" : "Giới tính nam",
        nationality: CountryDeclaration.VIETNAM,
        nationalAddress: CountryDeclaration.VIETNAM,
        cityAddress: cityAddress,
        districtAddress: districtAddress,
        communeAddress: communeAddress,
        detailAddress: detailAddress,
        stayType: "Thường trú",
        reason: "Du lịch",
      ));
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void divideTotalPrice(String value) {
    num newTotalPrice = teTotalPrice.controller.text.isEmpty
        ? 0
        : num.parse(teTotalPrice.controller.text.replaceAll(',', '').trim());
    if (statusBookingType == BookingType.monthly) {
      int end = (staysMonth.length + staysDay.length);
      priceAfterMultipleRatePlan.clear();
      for (var i = 0; i < end; i++) {
        priceAfterMultipleRatePlan.add(newTotalPrice);
      }
      if (staysDay.isNotEmpty) {
        getPriceAverage(newTotalPrice);
      }
    } else {
      num pricePerDay = newTotalPrice / priceAfterMultipleRatePlan.length;
      num totalTemp = 0;
      priceAfterMultipleRatePlan =
          List<num>.generate(priceAfterMultipleRatePlan.length, (index) {
        if (index == priceAfterMultipleRatePlan.length - 1) {
          return newTotalPrice - totalTemp;
        }
        num numAfterRounded =
            index % 2 == 0 ? pricePerDay.ceil() : pricePerDay.floor();
        totalTemp += numAfterRounded;
        return numAfterRounded;
      });
    }
    notifyListeners();
  }

  bool get isReadonly =>
      booking.status == BookingStatus.checkout ||
      booking.status == BookingStatus.cancel ||
      booking.status == BookingStatus.noshow;

  bool get isShowBottomButton =>
      booking.status == BookingStatus.booked ||
      booking.status == BookingStatus.checkin ||
      booking.status == BookingStatus.unconfirmed;

  void setEmailSaler(String value) {
    isCheckEmail = value == emailSalerOld;
    notifyListeners();
  }

  void checkEmailExists() async {
    if (teSaler!.text.isNotEmpty) {
      isLoading = true;
      notifyListeners();
      await FirebaseFunctions.instance
          .httpsCallable('booking-getUsersInHotel')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'email': teSaler!.text
      }).then((value) {
        isCheckEmail = (value.data as bool);
        isLoading = false;
        notifyListeners();
      }).onError((error, stackTrace) {
        isLoading = false;
        isCheckEmail = false;
        notifyListeners();
      });
    }
  }

  void setBookingType(String newValue) {
    if (selectTypeBooking == newValue) return;
    if (booking.bookingType != null) return;
    selectTypeBooking = newValue;
    if (selectTypeBooking ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TODAY)) {
      statusBookingType = BookingType.dayly;
      updatePriceByBookingType();
      inDateHour = null;
      outDateHour = null;
    } else if (selectTypeBooking ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOURLY)) {
      statusBookingType = BookingType.hourly;
      teTotalPrice =
          NeutronInputNumberController(TextEditingController(text: ""));
      updatePriceByBookingType();
      inDateHour = DateTime(inDate.year, inDate.month, inDate.day,
          hourFrameStart.hour, hourFrameStart.minute);
      outDateHour = DateTime(inDate.year, inDate.month, inDate.day,
          hourFrameEnd.hour, hourFrameEnd.minute);
    } else {
      statusBookingType = BookingType.monthly;
      teTotalPrice =
          NeutronInputNumberController(TextEditingController(text: ""));
      updatePriceByBookingType();
      inDateHour = null;
      outDateHour = null;
    }
    notifyListeners();
  }

  List<DateTime> getDailyByBookingTypeMonth() {
    List<DateTime> staysDays = [];
    if (inDate.month == outDate.month) {
      staysDays = [DateTime(inDate.year, inDate.month)];
    } else {
      int startMonth = inDate.month;
      int endMonth = outDate.month;
      int startYear = inDate.year;
      int endYear = outDate.year;
      if (startYear == endYear) {
        for (var i = startMonth; i <= endMonth; i++) {
          staysDays.add(DateTime(endYear, i));
        }
      } else {
        for (var i = startMonth; i <= 12; i++) {
          staysDays.add(DateTime(startYear, i));
        }
        for (var i = 1; i <= endMonth; i++) {
          staysDays.add(DateTime(endYear, i));
        }
      }
    }
    return staysDays;
  }

  void updatePriceByBookingType() async {
    List<DateTime> staysDayOld = [...staysDay];
    staysDay.clear();
    staysMonth.clear();
    if (statusBookingType == BookingType.monthly) {
      getDayByMonth();
      if (isAddBooking) {
        priceAfterMultipleRatePlan.clear();
        for (var i = 0; i < (staysMonth.length + staysDay.length); i++) {
          priceAfterMultipleRatePlan.add(0);
        }
      } else {
        int tatolLength = staysMonth.length + staysDay.length;
        int length = staysMonth.length;
        List<num> priceOld = [...priceAfterMultipleRatePlan];
        priceAfterMultipleRatePlan.clear();
        for (var i = 0; i < length; i++) {
          if (i < (priceOld.length - staysDayOld.length)) {
            priceAfterMultipleRatePlan.add(priceOld[i]);
          } else {
            priceAfterMultipleRatePlan
                .add(priceOld[((priceOld.length - staysDayOld.length)) - 1]);
          }
        }
        if (staysDay.isNotEmpty) {
          for (var i = length; i < tatolLength; i++) {
            priceAfterMultipleRatePlan.add(0);
          }
          getPriceAverage(priceAfterMultipleRatePlan[staysMonth.length - 1]);
        }
      }
      teTotalPrice.controller.text =
          ((getTotalPriceByBookingMonth(priceAfterMultipleRatePlan).fold(0.0,
                      (previousValue, element) => previousValue + element) /
                  getTotalPriceByBookingMonth(priceAfterMultipleRatePlan)
                      .length))
              .round()
              .toString();
      teTotalPrice.formatString();
      print(priceAfterMultipleRatePlan);
    } else if (statusBookingType == BookingType.hourly) {
      priceAfterMultipleRatePlan.clear();
      staysDay = DateUtil.getStaysDay(inDate, outDate);
      num newTotalPrice = teTotalPrice.controller.text.isEmpty
          ? 0
          : num.parse(teTotalPrice.controller.text.replaceAll(',', '').trim());
      priceAfterMultipleRatePlan.add(newTotalPrice);
    } else {
      staysDay = DateUtil.getStaysDay(inDate, outDate);
      await updatePriceAndAvailableRoomsNew(
          inDate, outDate, booking.roomTypeID!, ratePlanID, false);
      if (idBooking.isNotEmpty) {
        for (var date in staysDay) {
          if (oldStaysDay.contains(date)) {
            priceAfterMultipleRatePlan[staysDay.indexOf(date)] =
                booking.price![oldStaysDay.indexOf(date)];
          }
        }
      }
      teTotalPrice.controller.text = getTotalPrice().toString();
      teTotalPrice.formatString();
    }
    updating = false;
    notifyListeners();
  }

  void getDayByMonth() {
    List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
    List<DateTime> staysDayMonth = getDailyByBookingTypeMonth();
    int index = 0;
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
        staysDay = DateUtil.getStaysDay(firstDay, outDate);
        staysMonth.add(
            "${DateUtil.dateToDayMonthYearString(firstDay)}-${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
      }
    } else {
      staysMonth.add(
          "${DateUtil.dateToDayMonthYearString(inDate)}-${DateUtil.dateToDayMonthYearString(DateTime(outDate.year, outDate.month, outDate.day - 1))}");
      staysDay = DateUtil.getStaysDay(inDate, outDate);
    }
  }

  void getPriceAverage(num newTotalPrice) {
    int start = staysMonth.length;
    int end = (staysMonth.length + staysDay.length);
    DateTime outDates = staysDay[staysDay.length - 1];
    if (staysDay[0].year != staysDay[staysDay.length - 1].year) {
      outDates = staysDay[0].month != staysDay[staysDay.length - 1].month
          ? DateTime(staysDay[staysDay.length - 1].year,
              staysDay[staysDay.length - 1].month, staysDay[0].day, 12)
          : DateTime(staysDay[staysDay.length - 1].year, staysDay[0].month + 1,
              staysDay[0].day, 12);
    } else {
      outDates = staysDay[0].month != staysDay[staysDay.length - 1].month
          ? DateTime(staysDay[0].year, staysDay[staysDay.length - 1].month,
              staysDay[0].day, 12)
          : DateTime(
              staysDay[0].year, staysDay[0].month + 1, staysDay[0].day, 12);
    }
    num priceMedium =
        (newTotalPrice / outDates.difference(staysDay[0]).inDays).round();
    for (var i = start; i < end; i++) {
      priceAfterMultipleRatePlan[i] = priceMedium;
    }
  }
}
