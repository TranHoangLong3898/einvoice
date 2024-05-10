import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

import '../../../manager/roomextramanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/extraguest.dart';
import '../../../util/dateutil.dart';
import 'addservicecontroller.dart';

class ExtraGuestController extends ChangeNotifier {
  List<ExtraGuest> extraGuests = [];
  final Booking booking;
  ExtraGuestController(this.booking) {
    update();
  }

  void update() async {
    extraGuests = await booking.getExtraGuests();
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}

class AddExtraGuestController extends AddServiceController {
  final Booking booking;
  bool adding = false;

  late String type = 'adult';
  late TextEditingController teNumber;
  late TextEditingController tePrice;
  late DateTime startDate;
  late DateTime endDate;
  late String total = '0';
  late TextEditingController teSaler;
  late String emailSalerOld = '';

  AddExtraGuestController(this.booking) {
    teNumber = TextEditingController(text: '');
    tePrice = TextEditingController(
        text: RoomExtraManager().getExtraGuestPrice(type).toString());

    startDate = booking.inDate!;
    endDate = booking.outDate!;
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    teNumber.dispose();
    tePrice.dispose();
  }

  void updateTotal() {
    total = NumberUtil.numberFormat.format(
        (int.tryParse(teNumber.text.replaceAll(',', '')) ?? 0) *
            (num.tryParse(tePrice.text.replaceAll(',', '')) ?? 0) *
            endDate.difference(startDate).inDays);
  }

  void setType(String newType) {
    String newTypeWithFormatted =
        newType == MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_ADULT)
            ? 'adult'
            : 'child';
    if (type == newTypeWithFormatted) return;

    type = newTypeWithFormatted;

    tePrice.text = NumberUtil.numberFormat
        .format(RoomExtraManager().getExtraGuestPrice(type));
    updateTotal();
    notifyListeners();
  }

  void updateValue() {
    updateTotal();
    notifyListeners();
  }

  void setStartDate(DateTime newStartDate) {
    newStartDate = DateUtil.to12h(newStartDate);
    if (DateUtil.equal(newStartDate, startDate)) return;
    if (newStartDate.compareTo(booking.outDate!) >= 0) return;

    if (newStartDate.compareTo(booking.inDate!) < 0) return;

    startDate = newStartDate;

    if (startDate.compareTo(endDate) >= 0) {
      endDate = startDate.add(const Duration(days: 1));
    }
    updateTotal();
    notifyListeners();
  }

  void setEndDate(DateTime newEndDate) {
    newEndDate = DateUtil.to12h(newEndDate);
    if (DateUtil.equal(newEndDate, endDate)) return;
    if (newEndDate.compareTo(booking.outDate!) > 0) return;
    if (newEndDate.compareTo(booking.inDate!) <= 0) return;
    if (newEndDate.compareTo(startDate) <= 0) return;

    endDate = newEndDate;

    updateTotal();
    notifyListeners();
  }

  Future<String> addExtraGuest() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }

    if (teNumber.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_AMOUNT);
    }
    if (tePrice.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_PRICE);
    }
    final number = int.tryParse(teNumber.text.replaceAll(',', ''));
    final price = num.tryParse(tePrice.text.replaceAll(',', ''));
    if (price == null || price <= 0) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_PRICE);
    }
    if (number == null || number <= 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INPUT_POSITIVE_AMOUNT);
    }

    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }

    final extraGuest = ExtraGuest(
        start: startDate,
        end: endDate,
        number: number,
        price: price,
        time: Timestamp.now(),
        total: num.tryParse(total.replaceAll(',', '')),
        type: type,
        name: booking.name,
        room: booking.room,
        saler: teSaler.text);
    adding = true;
    notifyListeners();
    String result = await booking
        .addService(extraGuest)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class UpdateExtraGuestController extends UpdateServiceController {
  Map<String, TextEditingController> teExtraGuestControllers = {};
  //key = id; value = alue of service's elementId
  Map<String, dynamic> oldItems = {};
  final Booking? booking;
  final ExtraGuest? service;
  late TextEditingController teSaler;
  String emailSalerOld = '';

  UpdateExtraGuestController({this.booking, this.service}) {
    teExtraGuestControllers['number'] =
        TextEditingController(text: service!.number.toString());
    teExtraGuestControllers['price'] =
        TextEditingController(text: service!.price.toString());

    teExtraGuestControllers['number']!.addListener(() {
      updateNumber(
          teExtraGuestControllers['number']!.text.replaceAll(',', '').isEmpty
              ? 0
              : num.parse(
                  teExtraGuestControllers['number']!.text.replaceAll(',', '')));
    });
    teExtraGuestControllers['price']!.addListener(() => updatePrice(
        teExtraGuestControllers['price']!.text.replaceAll(',', '').isEmpty
            ? 0
            : num.parse(
                teExtraGuestControllers['price']!.text.replaceAll(',', ''))));
    saveOldItems();
    teSaler = TextEditingController(text: service!.saler ?? "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  //set keys and values of oldItem = minibarItems
  @override
  void saveOldItems() {
    oldItems['type'] = service!.type;
    oldItems['number'] = service!.number;
    oldItems['start'] = service!.start;
    oldItems['end'] = service!.end;
    oldItems['price'] = service!.price;
  }

  //get list types of minibar-service
  @override
  List<String> getServiceItems() {
    return ['type', 'number', 'start', 'end', 'price'];
  }

  @override
  void updateService() {
    service!.total = (int.tryParse(
                teExtraGuestControllers['number']!.text.replaceAll(',', '')) ??
            0) *
        (int.tryParse(
                teExtraGuestControllers['price']!.text.replaceAll(',', '')) ??
            0) *
        service!.end!.difference(service!.start!).inDays;
  }

  void updateExtraGuestType(String newType) {
    String newTypeWithFormatted =
        newType == MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_ADULT)
            ? 'adult'
            : 'child';
    if (service!.type == newTypeWithFormatted) return;
    service!.type = newTypeWithFormatted;
    teExtraGuestControllers['price']!.text = NumberUtil.numberFormat
        .format(RoomExtraManager().getExtraGuestPrice(service!.type!));
    notifyListeners();
  }

  void updateStartDate(DateTime newStartDate) {
    newStartDate = DateUtil.to12h(newStartDate);
    if (DateUtil.equal(newStartDate, service!.start!)) return;
    if (newStartDate.compareTo(booking!.outDate!) >= 0) return;
    if (newStartDate.compareTo(booking!.inDate!) < 0) return;
    service!.start = newStartDate;
    notifyListeners();
  }

  void updateEndDate(DateTime newEndDate) {
    newEndDate = DateUtil.to12h(newEndDate);
    if (DateUtil.equal(newEndDate, service!.end!)) return;
    if (newEndDate.compareTo(booking!.outDate!) > 0) return;
    if (newEndDate.compareTo(booking!.inDate!) <= 0) return;
    if (newEndDate.compareTo(service!.start!) <= 0) return;
    service!.end = newEndDate;
    notifyListeners();
  }

  void updateNumber(num newNumber) {
    if (newNumber <= 0 || newNumber == service!.number) return;
    service!.number = newNumber;
  }

  void updatePrice(num newPrice) {
    if (newPrice <= 0 || newPrice == service!.price) return;
    service!.price = newPrice;
  }

  // return true if user changed amount of items in minibar
  // return false if user changed nothing
  @override
  bool isServiceItemsChanged() {
    return !(oldItems['type'] == service!.type &&
        oldItems['number'] == service!.number &&
        oldItems['start'] == service!.start &&
        oldItems['end'] == service!.end &&
        oldItems['price'] == service!.price &&
        emailSalerOld == teSaler.text);
  }

  @override
  Future<String> updateServiceToDatabase() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    if (!isServiceItemsChanged()) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (updating!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    setProgressUpdating();
    service!.saler = teSaler.text;
    String result = await booking!
        .updateService(service!)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());

    //result == '' means updating successfully. Then update oldItems = current minibarItems
    if (result == MessageCodeUtil.SUCCESS) {
      saveOldItems();
      notifyListeners();
    } else {
      service!.type = oldItems['type'];
      service!.number = oldItems['number'];
      service!.start = oldItems['start'];
      service!.end = oldItems['end'];
      service!.price = oldItems['price'];
      service!.total = service!.number! *
          service!.price! *
          service!.end!.difference(service!.start!).inDays;
      service!.saler = emailSalerOld;
    }
    setProgressDone();
    return MessageUtil.getMessageByCode(result);
  }
}
